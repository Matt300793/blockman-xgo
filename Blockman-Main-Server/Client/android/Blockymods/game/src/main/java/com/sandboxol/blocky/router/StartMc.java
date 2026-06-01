package com.sandboxol.blocky.router;

import android.app.Activity;
import android.content.ComponentName;
import android.content.Context;
import android.content.Intent;

import com.google.gson.Gson;
import com.sandboxol.blocky.activity.StartMcActivity;
import com.sandboxol.blocky.entity.EnterRealmsResult;
import com.sandboxol.blocky.utils.GameSharedUtils;
import com.sandboxol.common.utils.CommonHelper;

/**
 * Created by luoweiyi on 16/2/24.
 */
public class StartMc {

    private static StartMc instance = null;
    private boolean isInGame = false;

    public static StartMc newInstance() {
        if (instance == null) {
            instance = new StartMc();
        }
        return instance;
    }

    public boolean isInGame() {
        return isInGame;
    }

    private void setInGame(boolean isInGame) {
        this.isInGame = isInGame;
    }

    public void startGame(Context context, EnterRealmsResult enterRealmsResult) {
        String gameInfo = new Gson().toJson(enterRealmsResult);
        Intent intent = new Intent();
        ControllerType controllerType = ControllerType.BLOCK_MAN;
        intent.putExtra("controllerType", controllerType);
        GameSharedUtils.newInstance().putStartGameInfo(gameInfo);
        int pid = CommonHelper.checkProcessIsRunning(context, "com.sandboxol.blockymods.BlockmanGo");
        if (pid != 0) {
            android.os.Process.killProcess(pid);
        }
        intent.setComponent(new ComponentName(context, StartMcActivity.class));
        ((Activity) context).startActivityForResult(intent, StartMcActivity.FINISH_MAIN_ACTIVITY_ACTIVITY);
        setInGame(true);
    }

    public void leaveGame() {
        setInGame(false);
        instance = null;
    }
}
