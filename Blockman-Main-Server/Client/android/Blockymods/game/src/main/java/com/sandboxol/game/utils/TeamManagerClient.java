package com.sandboxol.game.utils;

import android.os.Handler;
import android.os.Message;

import com.sandboxol.game.interfaces.ITeamManagerListener;
import com.sandboxol.mgs.teammgr.LocalTeamsRequest;
import com.sandboxol.mgs.teammgr.LocalTeamsResponse;
import com.sandboxol.mgs.teammgr.TeamRequest;
import com.sandboxol.mgs.teammgr.TeamResponse;
import com.sandboxol.mgs.teammgr.TeammgrGrpc;

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

public class TeamManagerClient extends Handler {

    private static TeamManagerClient mMe;
    private final ManagedChannel channel;
    private TeammgrGrpc.TeammgrStub asyncStub;
    private ITeamManagerListener mITeamManagerListener;
    private StreamObserver<TeamRequest> mTeamRequestStreamObserver;
    private StreamObserver<LocalTeamsRequest> mLocalTeamsRequestStreamObserver;

    public static TeamManagerClient newInstance(String host, int port, long userId, String userToken, ITeamManagerListener iTeamManagerListener) {
        if (mMe == null)
            mMe = new TeamManagerClient(host, port, userId, userToken, iTeamManagerListener);
        return mMe;
    }

    public static TeamManagerClient getMe() {
        return mMe;
    }

    private TeamManagerClient(String host, int port, long userId, String userToken, ITeamManagerListener iTeamManagerListener) {
        this(ManagedChannelBuilder.forAddress(host, port).idleTimeout(2, TimeUnit.SECONDS).usePlaintext(true), String.valueOf(userId), userToken, iTeamManagerListener);
    }

    private TeamManagerClient(ManagedChannelBuilder<?> channelBuilder, String userId, String userToken, ITeamManagerListener iTeamManagerListener) {
        this.channel = channelBuilder.build();
        this.asyncStub = TeammgrGrpc.newStub(channel);
        this.mITeamManagerListener = iTeamManagerListener;
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
        if (mTeamRequestStreamObserver != null) {
            mTeamRequestStreamObserver.onCompleted();
        }

        if (mLocalTeamsRequestStreamObserver != null) {
            mLocalTeamsRequestStreamObserver.onCompleted();
        }
        channel.shutdown();
        mITeamManagerListener = null;
        mMe = null;
    }


    public void team(final TeamRequest request) throws InterruptedException {
        new Thread(new Runnable() {
            @Override
            public void run() {
                if (mTeamRequestStreamObserver == null) {
                    mTeamRequestStreamObserver = asyncStub.team(new StreamObserver<TeamResponse>() {
                        @Override
                        public void onNext(TeamResponse response) {
                            Message msg = new Message();
                            msg.what = TEAM_ON_NEXT;
                            msg.obj = response;
                            sendMessage(msg);

                            if (response.getStateCase() == TeamResponse.StateCase.DONE && response.getDone().getDone() < 3) {
                                mTeamRequestStreamObserver = null;
                            }
                        }

                        @Override
                        public void onError(Throwable t) {
                            Status status = Status.fromThrowable(t);
                            Message msg = new Message();
                            msg.what = TEAM_ON_ERROR;
                            msg.obj = status;
                            sendMessage(msg);
                        }

                        @Override
                        public void onCompleted() {
                            sendEmptyMessage(TEAM_ON_COMPLETED);
                        }
                    });
                }

                try {
                    mTeamRequestStreamObserver.onNext(request);
                } catch (RuntimeException e) {
                    mTeamRequestStreamObserver.onError(e);
                } catch (Exception e) {
                    e.printStackTrace();
                }
            }
        }).start();

    }

    public void localTeams(final LocalTeamsRequest request) throws InterruptedException {
        new Thread(new Runnable() {
            @Override
            public void run() {
                if (mLocalTeamsRequestStreamObserver == null) {
                    mLocalTeamsRequestStreamObserver = asyncStub.localTeams(new StreamObserver<LocalTeamsResponse>() {
                        @Override
                        public void onNext(LocalTeamsResponse response) {
                            Message msg = new Message();
                            msg.what = LOCAL_TEAMS_ON_NEXT;
                            msg.obj = response;
                            sendMessage(msg);
                        }

                        @Override
                        public void onError(Throwable t) {
                            Status status = Status.fromThrowable(t);
                            Message msg = new Message();
                            msg.what = LOCAL_TEAMS_ON_ERROR;
                            msg.obj = status;
                            sendMessage(msg);
                        }

                        @Override
                        public void onCompleted() {
                            sendEmptyMessage(LOCAL_TEAMS_ON_COMPLETED);
                        }
                    });
                }

                try {
                    mLocalTeamsRequestStreamObserver.onNext(request);
                } catch (RuntimeException e) {
                    mLocalTeamsRequestStreamObserver.onError(e);
                } catch (Exception e) {
                    e.printStackTrace();
                }
            }
        }).start();
    }

    private static final int TEAM_ON_NEXT = 1;
    private static final int TEAM_ON_ERROR = 2;
    private static final int TEAM_ON_COMPLETED = 3;

    private static final int LOCAL_TEAMS_ON_NEXT = 4;
    private static final int LOCAL_TEAMS_ON_ERROR = 5;
    private static final int LOCAL_TEAMS_ON_COMPLETED = 6;


    @Override
    public void handleMessage(Message msg) {
        if (mITeamManagerListener == null)
            return;
        switch (msg.what) {
            case TEAM_ON_NEXT:
                mITeamManagerListener.onTeamNext((TeamResponse) msg.obj);
                break;
            case TEAM_ON_ERROR:
                mITeamManagerListener.onTeamError((Status) msg.obj);
                break;
            case TEAM_ON_COMPLETED:
                mITeamManagerListener.onTeamCompleted();
                break;
            case LOCAL_TEAMS_ON_NEXT:
                mITeamManagerListener.onLocalTeamsNext((LocalTeamsResponse) msg.obj);
                break;
            case LOCAL_TEAMS_ON_ERROR:
                mITeamManagerListener.onLocalTeamsError((Status) msg.obj);
                break;
            case LOCAL_TEAMS_ON_COMPLETED:
                mITeamManagerListener.onLocalTeamsCompleted();
                break;
            default:
                break;

        }
    }
}
