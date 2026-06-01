package com.sandboxol.blocky.router;

import android.content.Context;

import com.mcpeonline.multiplayer.router.Client;
import com.sandboxol.blockmango.EchoesActivity;
import com.sandboxol.blockmango.EchoesRenderer;
import com.sandboxol.blocky.activity.StartMcActivity;
import com.sandboxol.blocky.utils.VoicePlayUtil;

/**
 * Created by Mr.Luo on 16/8/10.
 */
public class RealmsController extends Controller {

    private static RealmsController mMe = null;

    private RealmsController(Context context) {
        super(context);
    }

    public static RealmsController getMe() {
        return mMe;
    }

    public static void setMe(RealmsController object) {
        RealmsController.mMe = object;
    }

    public static RealmsController newInstance(Context context) {
        if (mMe == null) {
            mMe = new RealmsController(context);
        } else {
            mMe.setContext(context);
        }
        return mMe;
    }

    @Override
    protected void initClient() {
        if (this.isInit)
            return;
        this.isInit = true;
        Client.setHandler(this);
        try {
            mStartMcResultCode = Client.Start(
                    false,
                    mMeNickName,
                    "0.9.5",
                    1,
                    1,
                    mMeUserId,
                    getEnterRealmsResult().getUserToken(),
                    getEnterRealmsResult().getGameAddr(),
                    getEnterRealmsResult().getTimestamp()
            );
            startMiniGame();
            VoicePlayUtil.init();
        } catch (Exception e) {
            e.printStackTrace();
            sendEmptyMessageDelayed(mStartMcResultCodeWhat, mStartMcResultCodeTimeout);
        }

        if (mStartMcResultCode != 0) {
            sendEmptyMessageDelayed(mStartMcResultCodeWhat, mStartMcResultCodeTimeout);
        }
    }

    @Override
    protected void initBlockMan() {
        if (this.isInit)
            return;
        this.isInit = true;
        Client.setHandler(this);
        startMiniGame();
        VoicePlayUtil.init();
        sendEmptyMessageDelayed(mStartBlockManMsgWhat, 0);
    }

    private void startMiniGame() {
//        WebApi.startMiniGame(mContext, mEnterRealmsResult.getGame().getType(), new ApiCallback<HttpResult>() {
//            @Override
//            public void onSuccess(HttpResult response) {
//                log("startMiniGame onSuccess " + new Gson().toJson(response));
//
//            }
//
//            @Override
//            public void onError(String errorBody) {
//                log(" startMiniGame onError " + errorBody);
//            }
//        });
    }

    @Override
    protected void stopClient() {
        mMe = null;
    }

    @Override
    public void onError(int code) {
        if (mContext == null)
            return;
        if (mContext instanceof StartMcActivity) {
            ((StartMcActivity) mContext).setRouterConnectionFails();
//            showDialog(mContext.getString(R.string.networkErr));
        }
        switch (code) {
            case Client.RCErr_UNKNOWN:

                break;
            case Client.RCErr_Network:
//                menu.msgDialog(mContext.getString(R.string.networkErr), true);
                break;
            case Client.RCErr_Proxy:
                break;
            case Client.RCErr_Connect:
                break;
            case Client.RCErr_ConnectAuth:
                break;
            case Client.RCErr_ConnectTimeout:
//                menu.msgDialog(mContext.getString(R.string.networkErr), true);
                break;
            case Client.RCErr_Disconnect:
//                menu.msgDialog(mContext.getString(R.string.realms_disconnect_for_server), true);
                break;
            case Client.RCErr_HostOff:
                break;
            case Client.RCErr_HostKick:
                break;
            case Client.RCErr_MultiLogin:
//                menu.msgDialog(mContext.getString(R.string.aLongDistanceLogin), true);
                break;
            case Client.RCErr_GameOff:
                break;
            case Client.RCErr_ProxyBuild:
                break;
            case Client.RCErr_LaunchTimeout:
                break;
            default:
                break;
        }
    }

    @Override
    public void onUserIn(String s) {
    }

    @Override
    public void onUserOut(long l) {
    }

    @Override
    public void onPlaySound(int soundId) {
        VoicePlayUtil.init().voicePay(soundId);
    }

    @Override
    public void onHungerGameResult(int kills, int exps, int goldCoins, int activeValues) {
//        if (RealmsWindow.getMe() != null) {
//            RealmsWindow.getMe().rewardDialog(kills, exps, goldCoins, activeValues);
//        }
    }

    @Override
    public int getPing() {
        if (mContext instanceof EchoesActivity) {
            return EchoesRenderer.getPing();
        } else {
            return Client.HostPing() + Client.SelfPing();
        }
    }

}
