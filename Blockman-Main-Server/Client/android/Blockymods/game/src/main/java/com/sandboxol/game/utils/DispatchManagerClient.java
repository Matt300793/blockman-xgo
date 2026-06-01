package com.sandboxol.game.utils;

import android.os.Handler;
import android.os.Message;

import com.sandboxol.clw.dispatcher.DispatcherGrpc;
import com.sandboxol.clw.dispatcher.ServerListRequest;
import com.sandboxol.clw.dispatcher.ServerListResponse;

import java.util.concurrent.TimeUnit;

import io.grpc.ManagedChannel;
import io.grpc.ManagedChannelBuilder;
import io.grpc.Metadata;
import io.grpc.Status;
import io.grpc.stub.MetadataUtils;
import io.grpc.stub.StreamObserver;

/**
 * Created by Mr.Luo on 2016/10/28.
 */

public class DispatchManagerClient extends Handler {

    private final ManagedChannel channel;
    private static DispatchManagerClient mMe;
    private DispatcherGrpc.DispatcherStub asyncStub;

    private StreamObserver<ServerListRequest> mServerListRequestStreamObserver;
    private OnEnterTribeWarListener mOnEnterTribeWarListener;

    public static DispatchManagerClient newInstance(String host, int port, long userId, String userToken, OnEnterTribeWarListener onEnterTribeWarListener) {
        if (mMe == null)
            mMe = new DispatchManagerClient(host, port, userId, userToken, onEnterTribeWarListener);
        return mMe;
    }

    public static DispatchManagerClient getMe() {
        return mMe;
    }

    private DispatchManagerClient(String host, int port, long userId, String userToken, OnEnterTribeWarListener onEnterTribeWarListener) {
        this(ManagedChannelBuilder.forAddress(host, port).idleTimeout(2, TimeUnit.SECONDS).usePlaintext(true), String.valueOf(userId), userToken, onEnterTribeWarListener);
    }

    private DispatchManagerClient(ManagedChannelBuilder<?> channelBuilder, String userId, String userToken, OnEnterTribeWarListener onEnterTribeWarListener) {
        this.channel = channelBuilder.build();
        this.asyncStub = DispatcherGrpc.newStub(channel);
        this.mOnEnterTribeWarListener = onEnterTribeWarListener;
        Metadata metadata = new Metadata();
        Metadata.Key<String> uid = Metadata.Key.of("uid", getAsciiMarshaller());
        Metadata.Key<String> token = Metadata.Key.of("token", getAsciiMarshaller());
        metadata.put(uid, userId);
        metadata.put(token, userToken);
        this.asyncStub = MetadataUtils.attachHeaders(asyncStub, metadata);
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

    public void shutdown() throws InterruptedException {
        if (mServerListRequestStreamObserver != null) {
            mServerListRequestStreamObserver.onCompleted();
            mServerListRequestStreamObserver = null;
        }
        channel.shutdown();
        mOnEnterTribeWarListener = null;
        mMe = null;
    }

    public void tribeWarRequest(final ServerListRequest request) throws InterruptedException {
        new Thread(new Runnable() {
            @Override
            public void run() {
                if (mServerListRequestStreamObserver == null) {
                    mServerListRequestStreamObserver = asyncStub.serverList(new StreamObserver<ServerListResponse>() {
                        @Override
                        public void onNext(ServerListResponse response) {
                            Message msg = new Message();
                            msg.what = ENTER_TRIBE_WAR_ON_NEXT;
                            msg.obj = response;
                            sendMessage(msg);
                        }

                        @Override
                        public void onError(Throwable t) {
                            Status status = Status.fromThrowable(t);
                            Message msg = new Message();
                            msg.what = ENTER_TRIBE_WAR_ON_ERROR;
                            msg.obj = status;
                            sendMessage(msg);
                        }

                        @Override
                        public void onCompleted() {
                            sendEmptyMessage(ENTER_TRIBE_WAR_COMPLETED);
                        }
                    });
                }

                try {
                    mServerListRequestStreamObserver.onNext(request);
                } catch (RuntimeException e) {
                    mServerListRequestStreamObserver.onError(e);
                } catch (Exception e) {
                    e.printStackTrace();
                }
            }
        }).start();
    }

    private static final int ENTER_TRIBE_WAR_ON_NEXT = 1;
    private static final int ENTER_TRIBE_WAR_ON_ERROR = 2;
    private static final int ENTER_TRIBE_WAR_COMPLETED = 3;

    @Override
    public void handleMessage(Message msg) {
        if (mOnEnterTribeWarListener == null)
            return;
        switch (msg.what) {
            case ENTER_TRIBE_WAR_ON_NEXT:
                mOnEnterTribeWarListener.onEnterTribeWarNext((ServerListResponse) msg.obj);
                break;
            case ENTER_TRIBE_WAR_ON_ERROR:
                mOnEnterTribeWarListener.onEnterTribeWarError((Status) msg.obj);
                break;
            case ENTER_TRIBE_WAR_COMPLETED:
                mOnEnterTribeWarListener.onEnterTribeWarCompleted();
                break;
        }
    }

    public boolean isShutdown() {
        return channel == null || channel.isShutdown() || channel.isTerminated();
    }

    public interface OnEnterTribeWarListener {
        void onEnterTribeWarNext(ServerListResponse response);

        void onEnterTribeWarError(Status status);

        void onEnterTribeWarCompleted();
    }
}
