package com.sandboxol.game.webapi.api;

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

import retrofit2.Call;
import retrofit2.http.Body;
import retrofit2.http.Header;
import retrofit2.http.POST;


/**
 * Created by luoweiyi on 16/1/7.
 */
public interface GameApi {

    @POST("v1/startlocalgame")
    Call<CreateGameResult> createGame(@Body CreateGameParam game,
                                      @Header("X-SHAHE-UID") String userId,
                                      @Header("X-SHAHE-KEY") String userKey,
                                      @Header("X-SHAHE-AREA") int areaId);

    @POST("v1/entergame")
    Call<EnterGameResult> enterGame(@Body EnterGameParam game,
                                    @Header("X-SHAHE-UID") String userId,
                                    @Header("X-SHAHE-KEY") String userKey,
                                    @Header("X-SHAHE-AREA") int areaId);

    @POST("v1/entergame/sexmatch")
    Call<EnterGameResult> enterGameSexMatch(@Body EnterGameSexMatchParam game,
                                            @Header("X-SHAHE-UID") String userId,
                                            @Header("X-SHAHE-KEY") String userKey,
                                            @Header("X-SHAHE-SEX") int sex);

    @POST("v1/recommendgame")
    Call<GameListResult> getGameList(@Body GameListParam info,
                                     @Header("X-SHAHE-UID") String userId,
                                     @Header("X-SHAHE-KEY") String userKey,
                                     @Header("X-SHAHE-AREA") int areaId);

    @POST("v1/findgame")
    Call<GameListResult> findGame(@Body FindItem gameIdList,
                                  @Header("X-SHAHE-UID") String userId,
                                  @Header("X-SHAHE-KEY") String userKey,
                                  @Header("X-SHAHE-AREA") int areaId);

    @POST("pm/enter")
    Call<EnterCloudResult> enterCloud(@Body EnterCloudParam game,
                                      @Header("X-SHAHE-UID") String userId,
                                      @Header("X-SHAHE-KEY") String userKey,
                                      @Header("X-SHAHE-AREA") int areaId);

}
