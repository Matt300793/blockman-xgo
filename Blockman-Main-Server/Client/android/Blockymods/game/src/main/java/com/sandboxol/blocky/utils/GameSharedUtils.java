package com.sandboxol.blocky.utils;

import android.content.Context;
import android.content.SharedPreferences;

import com.sandboxol.common.base.app.BaseApplication;

/**
 * Created by Bob on 2017/11/20.
 */
public class GameSharedUtils {

    private static final String START_GAME_INFO = "start.game.info";

    private static GameSharedUtils instance = null;
    private Context context;

    private GameSharedUtils(Context ctx) {
        this.context = ctx;
    }

    public static GameSharedUtils newInstance() {
        if (instance == null) {
            instance = new GameSharedUtils(BaseApplication.getContext());
        }
        return instance;
    }

    public boolean putStartGameInfo(String startMcInfo) {
        SharedPreferences userPref = context.getSharedPreferences(START_GAME_INFO, Context.MODE_PRIVATE);
        SharedPreferences.Editor editor = userPref.edit();
        editor.putString(START_GAME_INFO, startMcInfo);
        return editor.commit();
    }

    public String getStartGameInfo() {
        SharedPreferences userPref = context.getSharedPreferences(START_GAME_INFO, Context.MODE_PRIVATE);
        return userPref.getString(START_GAME_INFO, null);
    }
}
