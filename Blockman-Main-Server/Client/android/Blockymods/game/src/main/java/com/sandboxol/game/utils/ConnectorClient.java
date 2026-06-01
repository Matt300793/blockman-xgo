/*
 * Copyright 2015, Google Inc. All rights reserved.
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions are
 * met:
 *
 *    * Redistributions of source code must retain the above copyright
 * notice, this list of conditions and the following disclaimer.
 *    * Redistributions in binary form must reproduce the above
 * copyright notice, this list of conditions and the following disclaimer
 * in the documentation and/or other materials provided with the
 * distribution.
 *
 *    * Neither the name of Google Inc. nor the names of its
 * contributors may be used to endorse or promote products derived from
 * this software without specific prior written permission.
 *
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
 * "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
 * LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR
 * A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT
 * OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
 * SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT
 * LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
 * DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY
 * THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
 * (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
 * OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */

package com.sandboxol.game.utils;

import android.os.Handler;
import android.os.Message;

import com.sandboxol.game.interfaces.IConnectorListener;
import com.sandboxol.mgs.connector.ConnectorGrpc;
import com.sandboxol.mgs.connector.QueueRequest;
import com.sandboxol.mgs.connector.QueueResponse;
import com.sandboxol.mgs.connector.TeamQueueRequest;
import com.sandboxol.mgs.connector.TeamQueueResponse;

import java.util.Timer;
import java.util.TimerTask;
import java.util.concurrent.CountDownLatch;
import java.util.concurrent.TimeUnit;

import io.grpc.ManagedChannel;
import io.grpc.ManagedChannelBuilder;
import io.grpc.Metadata;
import io.grpc.Status;
import io.grpc.stub.MetadataUtils;
import io.grpc.stub.StreamObserver;

/**
 * Sample client code that makes gRPC calls to the server.
 */
public class ConnectorClient extends Handler {

    private final ManagedChannel channel;
    private ConnectorGrpc.ConnectorStub asyncStub;
    private IConnectorListener mIConnectorListener;
    private CountDownLatch mFinishLatch;
    private Timer mTimer;
    private int mCount = 0;
    private StreamObserver<QueueRequest> mRequestObserver;

    private CountDownLatch mTeamQueueRequestFinishLatch;
    private StreamObserver<TeamQueueRequest> mTeamQueueRequestStreamObserver;

    /**
     * Construct client for accessing RouteGuide server at {@code host:port}.
     */
    public ConnectorClient(String host, int port, long userId, String userToken, IConnectorListener iConnectorListener) {
        this(ManagedChannelBuilder.forAddress(host, port).idleTimeout(2, TimeUnit.SECONDS).usePlaintext(true), String.valueOf(userId), userToken, iConnectorListener);
    }

    /**
     * Construct client for accessing RouteGuide server using the existing channel.
     */
    private ConnectorClient(ManagedChannelBuilder<?> channelBuilder, String userId, String userToken, IConnectorListener iConnectorListener) {
        mIConnectorListener = iConnectorListener;
        channel = channelBuilder.build();
        asyncStub = ConnectorGrpc.newStub(channel);
        Metadata metadata = new Metadata();
        Metadata.Key<String> uid = Metadata.Key.of("uid", getAsciiMarshaller());
        Metadata.Key<String> token = Metadata.Key.of("token", getAsciiMarshaller());
        metadata.put(uid, userId);
        metadata.put(token, userToken);
        asyncStub = MetadataUtils.attachHeaders(asyncStub, metadata);
        startTimer();
    }

    private Metadata.AsciiMarshaller<String> getAsciiMarshaller(){
        return new Metadata.AsciiMarshaller<String>() {
            @Override
            public String toAsciiString(String value) {
                return value;
            }

            @Override
            public String parseAsciiString(String serialized) {
                return serialized;
            }
        };
    }

    private void startTimer() {
        if (mTimer == null) {
            mTimer = new Timer();
            mTimer.schedule(new TimerTask() {
                @Override
                public void run() {
                    mCount++;
                    sendEmptyMessage(3);
                }
            }, 1000, 1000);
        }
    }

    public void shutdown() throws InterruptedException {
        if (mRequestObserver != null)
            mRequestObserver.onCompleted();

        if (mTeamQueueRequestStreamObserver != null) {
            mTeamQueueRequestStreamObserver.onCompleted();
        }
        cancelTimer();
        channel.shutdown();
    }

    @Override
    public void handleMessage(Message msg) {
        super.handleMessage(msg);
        switch (msg.what) {
            case 0:
                QueueResponse response = (QueueResponse) msg.obj;
                if (mIConnectorListener != null)
                    mIConnectorListener.onNext(response);
                break;
            case 1:
                Status status = (Status) msg.obj;
                if (mIConnectorListener != null)
                    mIConnectorListener.onError(status);
                break;
            case 2:
                if (mIConnectorListener != null)
                    mIConnectorListener.onCompleted();
                break;
            case 3:
                if (mIConnectorListener != null) {
                    int seconds = mCount % 60;
                    int minutes = mCount / 60;
                    String s = seconds < 10 ? ("0" + seconds) : String.valueOf(seconds);
                    String m = minutes < 10 ? ("0" + minutes) : String.valueOf(minutes);
                    mIConnectorListener.onTiming(String.format("%s:%s", m, s));
                }
                break;

            case 4:
                TeamQueueResponse teamQueueResponse = (TeamQueueResponse) msg.obj;
                if (mIConnectorListener != null)
                    mIConnectorListener.onTeamNext(teamQueueResponse);
                break;
        }
    }

    /**
     * Bi-directional example, which can only be asynchronous. Send some chat messages, and print any
     * chat messages that are sent from the server.
     */
    public void queue(QueueRequest request) throws InterruptedException {
        mFinishLatch = new CountDownLatch(1);
        mRequestObserver = asyncStub.queue(new StreamObserver<QueueResponse>() {
            @Override
            public void onNext(QueueResponse response) {
                if (response.getStateCase() == QueueResponse.StateCase.DONE) {
                    cancelTimer();
                }
                Message msg = new Message();
                msg.what = 0;
                msg.obj = response;
                sendMessage(msg);
            }

            @Override
            public void onError(Throwable t) {
                t.printStackTrace();
                mFinishLatch.countDown();
                cancelTimer();
                Status status = Status.fromThrowable(t);
                Message msg = new Message();
                msg.what = 1;
                msg.obj = status;
                sendMessage(msg);
            }

            @Override
            public void onCompleted() {
                mFinishLatch.countDown();
                cancelTimer();
                sendEmptyMessage(2);
            }
        });

        try {
            mRequestObserver.onNext(request);
        } catch (RuntimeException e) {
            mRequestObserver.onError(e);
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    private void cancelTimer() {
        if (mTimer != null) {
            mTimer.cancel();
            mTimer = null;
        }
    }

    public void teamQueue(TeamQueueRequest teamQueueRequest) throws InterruptedException {
        if (mTeamQueueRequestFinishLatch == null || mTeamQueueRequestStreamObserver == null) {
            mTeamQueueRequestFinishLatch = new CountDownLatch(1);
            mTeamQueueRequestStreamObserver = asyncStub.teamQueue(new StreamObserver<TeamQueueResponse>() {
                @Override
                public void onNext(TeamQueueResponse response) {
                    if (response.getStateCase() == TeamQueueResponse.StateCase.DONE) {
                        cancelTimer();
                    }
                    Message msg = new Message();
                    msg.what = 4;
                    msg.obj = response;
                    sendMessage(msg);
                }

                @Override
                public void onError(Throwable t) {
                    t.printStackTrace();
                    mTeamQueueRequestFinishLatch.countDown();
                    cancelTimer();
                    Status status = Status.fromThrowable(t);
                    Message msg = new Message();
                    msg.what = 1;
                    msg.obj = status;
                    sendMessage(msg);
                }

                @Override
                public void onCompleted() {
                    mFinishLatch.countDown();
                    cancelTimer();
                    sendEmptyMessage(2);
                }
            });
        }
        try {
            mTeamQueueRequestStreamObserver.onNext(teamQueueRequest);
        } catch (RuntimeException e) {
            mTeamQueueRequestStreamObserver.onError(e);
        } catch (Exception e) {
            e.printStackTrace();
        }
    }
}
