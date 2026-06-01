package com.sandboxol.blockymods.web;

import com.sandboxol.blocky.entity.Game;
import com.sandboxol.blockymods.entity.Dispatch;
import com.sandboxol.blockymods.entity.MiniGameToken;
import com.sandboxol.common.base.web.HttpResponse;
import com.sandboxol.common.widget.rv.pagerv.PageData;

import java.util.List;
import java.util.Map;

import retrofit2.http.Body;
import retrofit2.http.GET;
import retrofit2.http.Header;
import retrofit2.http.POST;
import retrofit2.http.PUT;
import retrofit2.http.Path;
import retrofit2.http.Query;
import rx.Observable;

/**
 * Created by Bob on 2017/11/6.
 */
public interface IGameApi {

    @GET("/game/api/v1/games/recommendation")
    Observable<HttpResponse<List<Game>>> recommendation(@Header("language") String language);

    @GET("/game/api/v1/games/playlist/recently")
    Observable<HttpResponse<List<Game>>> recentlyPlayList(@Header("language") String language,
                                                          @Header("userId") long userId,
                                                          @Header("Access-Token") String accessToken);

    @GET("/game/api/v1/games/playlist/friends")
    Observable<HttpResponse<List<Game>>> friendPlayList(@Header("language") String language,
                                                        @Header("userId") long userId,
                                                        @Header("Access-Token") String accessToken);

    @GET("/game/api/v1/games/{gameId}")
    Observable<HttpResponse<Game>> miniGameDetail(@Path("gameId") String gameId,
                                                  @Header("language") String language,
                                                  @Header("userId") long userId,
                                                  @Header("Access-Token") String accessToken);

    @PUT("/game/api/v1/games/{gameId}/appreciation")
    Observable<HttpResponse<Integer>> appreciation(@Path("gameId") String gameId,
                                                   @Header("userId") long userId,
                                                   @Header("Access-Token") String accessToken);

    @GET("/game/api/v1/games")
    Observable<HttpResponse<PageData<Game>>> category(@Query("pageNo") String pageNo,
                                                      @Query("pageSize") String pageSize,
                                                      @Query("orderType") String orderType,
                                                      @Query("typeId") long typeId,
                                                      @Query("order") String order,
                                                      @Header("language") String language);

    @GET("/game/api/v1/game/auth")
    Observable<HttpResponse<MiniGameToken>> miniGameToken(@Query("typeId") String typeId,
                                                          @Header("userId") long userId,
                                                          @Header("Access-Token") String accessToken);

    @POST("/v1/dispatch")
    Observable<HttpResponse<Dispatch>> newMiniGameDispatcher(@Body Map<String, Object> map,
                                                             @Header("x-shahe-uid") long userId,
                                                             @Header("x-shahe-token") String accessToken);

}
