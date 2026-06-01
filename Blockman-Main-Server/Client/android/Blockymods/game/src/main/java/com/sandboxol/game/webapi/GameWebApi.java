package com.sandboxol.game.webapi;

import android.util.Log;

import com.sandboxol.game.entity.CreateGameParam;
import com.sandboxol.game.entity.CreateGameResult;
import com.sandboxol.game.entity.EnterCloudParam;
import com.sandboxol.game.entity.EnterCloudResult;
import com.sandboxol.game.entity.EnterGameParam;
import com.sandboxol.game.entity.EnterGameResult;
import com.sandboxol.game.entity.EnterGameSexMatchParam;
import com.sandboxol.game.entity.FindItem;
import com.sandboxol.game.entity.GameListParam;
import com.sandboxol.game.entity.GameListResult;
import com.sandboxol.game.utils.Constant;
import com.sandboxol.game.webapi.api.GameApi;

import retrofit2.Response;


/**
 * Created by luoweiyi on 16/1/7.
 */
public class GameWebApi {

    private static GameApi creatorApi = null;
    private static GameApi enterApi = null;
    private static GameApi querierApi = null;

    public static void initGameApi() {
        creatorApi = GameWebUtils.createApi(GameApi.class);
        enterApi = GameWebUtils.enterApi(GameApi.class);
        querierApi = GameWebUtils.queryApi(GameApi.class);
    }

    public static CreateGameResult userCreateGame(CreateGameParam info, long userId, String userKey, int areaId) {
        try {
            Response<CreateGameResult> response = creatorApi.createGame(info, userId + "", userKey, areaId).execute();
            if (response.isSuccessful()) {
                return response.body();
            } else {
                CreateGameResult item = new CreateGameResult();
                item.setCode(response.code());
                return item;
            }
        } catch (Exception e) {
            Log.e("GameWebApi", e.toString());
            CreateGameResult item = new CreateGameResult();
            String str = e.toString();
            int code = 0;

            if (str.contains("Timeout")) {
                code = Constant.GAME_CODE_TIME_OUT;
            }

            if (str.contains("UnknownHost")) {
                code = Constant.GAME_CODE_NET_ERROR;
            }
            item.setCode(code);
            return item;
        }
    }

    public static EnterGameResult userEnterGame(EnterGameParam info, boolean isFast, long userId, String userKey, int areaId) {
        try {
            Response<EnterGameResult> response = enterApi.enterGame(info, userId + "", userKey, areaId).execute();
            if (response.isSuccessful()) {
                EnterGameResult item = response.body();
                if (item.getCode() == 4 && isFast) {
                    item.setCode(Constant.GAME_CODE_GAME_NOT_FOUND_2);
                }
                return response.body();
            } else {
                EnterGameResult item = new EnterGameResult();
                item.setCode(response.code());
                return item;
            }
        } catch (Exception e) {
            Log.e("GameWebApi", e.toString());
            EnterGameResult item = new EnterGameResult();
            String str = e.toString();
            int code = 0;

            if (str.contains("Timeout")) {
                code = Constant.GAME_CODE_TIME_OUT;
            }

            if (str.contains("UnknownHost")) {
                code = Constant.GAME_CODE_NET_ERROR;
            }
            item.setCode(code);
            return item;
        }
    }

    public static EnterGameResult userEnterGameSexMatch(EnterGameSexMatchParam info, long userId, String userKey, int sex) {
        try {
            Response<EnterGameResult> response = enterApi.enterGameSexMatch(info, userId + "", userKey, sex).execute();
            if (response.isSuccessful()) {
                EnterGameResult item = response.body();
                if (item.getCode() == 4) {
                    item.setCode(Constant.GAME_CODE_GAME_NOT_FOUND_2);
                }
                return item;
            } else {
                EnterGameResult item = new EnterGameResult();
                item.setCode(response.code());
                return item;
            }
        } catch (Exception e) {
            Log.e("GameWebApi", e.toString());
            EnterGameResult item = new EnterGameResult();
            String str = e.toString();
            int code = 0;

            if (str.contains("Timeout")) {
                code = Constant.GAME_CODE_TIME_OUT;
            }

            if (str.contains("UnknownHost")) {
                code = Constant.GAME_CODE_NET_ERROR;
            }
            item.setCode(code);
            return item;
        }
    }

    public static GameListResult getGameList(GameListParam info, long userId, String userKey, int areaId) {
        try {
            Response<GameListResult> response = querierApi.getGameList(info, userId + "", userKey, areaId).execute();
            Thread.sleep(500);
            if (response.isSuccessful()) {
                return response.body();
            } else {
                return new GameListResult();
            }
        } catch (Exception e) {
            Log.e("GameWebApi", e.toString());
            return new GameListResult();
        }
    }

    public static GameListResult findGame(FindItem info, long userId, String userKey, int areaId) {
        try {
            Response<GameListResult> response = querierApi.findGame(info, userId + "", userKey, areaId).execute();
            if (response.isSuccessful()) {
                return response.body();
            } else {
                return new GameListResult();
            }
        } catch (Exception e) {
            return new GameListResult();
        }
    }


    public static EnterGameResult userEnterOtherRegionGame(EnterGameParam info, String url, long userId, String userKey, int areaId) {
        try {
            GameApi enterOtherRegionApi = GameWebUtils.enterOtherRegionApi(GameApi.class, url);
            Response<EnterGameResult> response = enterOtherRegionApi.enterGame(info, userId + "", userKey, areaId).execute();
            if (response.isSuccessful()) {
                return response.body();
            } else {
                EnterGameResult item = new EnterGameResult();
                item.setCode(response.code());
                return item;
            }
        } catch (Exception e) {
            EnterGameResult item = new EnterGameResult();
            String str = e.toString();
            int code = 0;
            if (str.contains("Timeout")) {
                code = Constant.GAME_CODE_TIME_OUT;
            }
            if (str.contains("UnknownHost")) {
                code = Constant.GAME_CODE_NET_ERROR;
            }
            item.setCode(code);
            return item;
        }
    }

    public static EnterCloudResult userEnterCloud(EnterCloudParam info, String url, long userId, String userKey, int areaId) {
        try {
            GameApi enterOtherRegionApi = GameWebUtils.enterOtherRegionApi(GameApi.class, url);
            Response<EnterCloudResult> response = enterOtherRegionApi.enterCloud(info, userId + "", userKey, areaId).execute();
            if (response.isSuccessful()) {
                return response.body();
            } else {
                EnterCloudResult item = new EnterCloudResult();
                item.setCode(response.code());
                return item;
            }
        } catch (Exception e) {
            EnterCloudResult item = new EnterCloudResult();
            String str = e.toString();
            int code = 0;
            if (str.contains("Timeout")) {
                code = Constant.GAME_CODE_TIME_OUT;
            }
            if (str.contains("UnknownHost")) {
                code = Constant.GAME_CODE_NET_ERROR;
            }
            item.setCode(code);
            return item;
        }
    }

}
