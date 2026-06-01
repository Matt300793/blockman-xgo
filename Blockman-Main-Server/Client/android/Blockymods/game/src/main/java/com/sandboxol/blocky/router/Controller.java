package com.sandboxol.blocky.router;

import android.app.Activity;
import android.content.ComponentName;
import android.content.Context;
import android.content.Intent;
import android.content.ServiceConnection;
import android.os.IBinder;
import android.os.Message;
import android.util.Log;

import com.mcpeonline.multiplayer.router.Client;
import com.mcpeonline.multiplayer.router.RouterClientHandler;
import com.sandboxol.blockmango.EchoesActivity;
import com.sandboxol.blocky.entity.EnterRealmsResult;
import com.sandboxol.blocky.activity.StartMcActivity;
import com.sandboxol.blocky.mceditor.ServerManager;
import com.sandboxol.blocky.service.McProcessChangeDataService;
import com.sandboxol.blocky.utils.GameSharedUtils;
import com.sandboxol.common.utils.CommonHelper;
import com.sandboxol.game.IMcProcessChangeDataInterface;
import com.sandboxol.game.entity.GameData;
import com.sandboxol.game.entity.UserData;

import java.util.ArrayList;
import java.util.List;

/**
 * Created by Mr.Luo on 16/5/18.
 */
public abstract class Controller extends RouterClientHandler {

    public static ControllerType mControllerType;
    public final int mStartMcMsgWhat = 10087;
    public final int mStartBlockManMsgWhat = 10088;
    protected final int mStartMcResultCodeTimeout = 9000;
    protected final int mStartMcResultCodeWhat = 18825;
    protected final int mcProcessHeartbeatCode = 1999;
    public int mStartMcResultCode = 0;
    protected int mGameMode;
    protected long mHostId;
    protected long mMeUserId;
    protected long mClickTime;
    protected long mDelayMillis = 1000;
    protected Context mContext;
    protected String mGameId;
    protected String mHostName;
    protected String mGameName;
    protected String mMeNickName;
    protected String mChatRoomId;
    protected boolean isHost = false;
    protected boolean isInit = false;
    protected boolean isVisitor = false;
    protected GameData mGameData = null;
    protected List<UserData> mList = null;
    private EnterRealmsResult mEnterRealmsResult = null;

    private IMcProcessChangeDataInterface mIMcProcessChangeDataInterface;
    private ServiceConnection mServiceConnection = new ServiceConnection() {
        @Override
        public void onServiceConnected(ComponentName name, IBinder service) {
            if (mIMcProcessChangeDataInterface == null) {
                mIMcProcessChangeDataInterface = IMcProcessChangeDataInterface.Stub.asInterface(service);
                sendEmptyMessageDelayed(mcProcessHeartbeatCode, 5000);
            }
            log("onServiceConnected");
        }

        @Override
        public void onServiceDisconnected(ComponentName name) {
            mIMcProcessChangeDataInterface = null;
            log("onServiceDisconnected");
        }
    };

    protected Controller(Context context) {
        this.mContext = context;
        this.mList = new ArrayList<>();
        String gameInfo = GameSharedUtils.newInstance().getStartGameInfo();
        EnterRealmsResult result = CommonHelper.formatObject(gameInfo, EnterRealmsResult.class);
        mMeUserId = result.getUserId();
        mMeNickName = result.getUserName();
        bindMcService();

    }

    public boolean isInit() {
        return isInit;
    }

    public void setContext(Context context) {
        mContext = context;
    }

    public EnterRealmsResult getEnterRealmsResult() {
        return mEnterRealmsResult;
    }

    public int getPing() {
        return 999;
    }

    public long getMeUserId() {
        return mMeUserId;
    }

    public String getMeNickName() {
        return mMeNickName == null ? "" : mMeNickName;
    }

    protected abstract void initClient();

    protected void initBlockMan() {

    }

    protected void stopClient() {

    }

    public <T extends Controller> T setEnterRealmsResult(ControllerType type, EnterRealmsResult realmsResult) {
        mControllerType = ControllerType.REALMS;
        this.mEnterRealmsResult = realmsResult;
        this.mGameName = mEnterRealmsResult.getGame().getGameName();
        if (type == ControllerType.BLOCK_MAN) {
            initBlockMan();
        } else {
            initClient();
        }
        return (T) this;
    }

    @Override
    public void handleMsg(Message msg) {
        switch (msg.what) {
            case mStartBlockManMsgWhat:
                if (mContext instanceof StartMcActivity) {
                    removeMessages(mStartMcResultCodeWhat);
                    StartMcActivity activity = (StartMcActivity) mContext;
                    activity.getIntent().setComponent(new ComponentName(mContext, EchoesActivity.class));
                    activity.startActivityForResult(activity.getIntent(), StartMcActivity.FINISH_MAIN_ACTIVITY_ACTIVITY);
                } else {
                    if (mContext != null)
                        ((Activity) mContext).finish();
                }
                break;
            case mcProcessHeartbeatCode:
                if (mIMcProcessChangeDataInterface != null) {
                    try {
                        mIMcProcessChangeDataInterface.doHeartBeat();
                    } catch (Exception e) {
                        e.printStackTrace();
                    }
                }
                sendEmptyMessageDelayed(mcProcessHeartbeatCode, 5000);
                break;
        }
    }

    public void stop() {
        ServerManager.DeleteServer("127.0.0.1");
        Client.setHandler(null);
        mControllerType = null;
        this.mContext = null;
        this.isHost = false;
        this.mGameData = null;
        this.mList = null;
        this.isInit = false;
        stopClient();
        Client.Stop();
    }

    public void log(String msg) {
        Log.e("router-jni", msg);
    }

    @Override
    protected void onRouting() {
        super.onRouting();
        log(" onRouting ");
    }

    @Override
    protected void onLaunching() {
        log(" onLaunching ");
        sendEmptyMessageDelayed(mStartMcMsgWhat, mDelayMillis);
    }

    @Override
    public void onNewMCPELinked() {

    }

    private boolean bindMcService() {
        Intent intent = new Intent(mContext, McProcessChangeDataService.class);
        return mContext.bindService(intent, mServiceConnection, Context.BIND_AUTO_CREATE);
    }

    private void unbindMcService() {
        try {
            if (mServiceConnection != null) {
                mContext.unbindService(mServiceConnection);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

}
