package com.sandboxol.blockymods.web;

import com.sandboxol.blockymods.entity.DressItem;
import com.sandboxol.common.base.web.HttpResponse;
import com.sandboxol.common.widget.rv.pagerv.PageData;

import java.util.List;

import retrofit2.http.DELETE;
import retrofit2.http.GET;
import retrofit2.http.Header;
import retrofit2.http.PUT;
import retrofit2.http.Path;
import retrofit2.http.Query;
import rx.Observable;

/**
 * Created by Bob on 2017/12/6.
 */
public interface IDecorationApi {

    @GET("/decoration/api/v1/decorations/{typeId}")
    Observable<HttpResponse<List<DressItem>>> dressList(@Path("typeId") long typeId,
                                                        @Header("language") String language,
                                                        @Header("userId") long userId,
                                                        @Header("Access-Token") String accessToken);

    @GET("/decoration/api/v1/decorations/using")
    Observable<HttpResponse<List<DressItem>>> isUsingList(@Header("language") String language,
                                                          @Header("userId") long userId,
                                                          @Header("Access-Token") String accessToken);

    @PUT("/decoration/api/v1/decorations/using/{decorationId}")
    Observable<HttpResponse<DressItem>> useDecoration(@Path("decorationId") long decorationId,
                                                      @Header("language") String language,
                                                      @Header("userId") long userId,
                                                      @Header("Access-Token") String accessToken);

    @DELETE("/decoration/api/v1/decorations/using/{decorationId}")
    Observable<HttpResponse<DressItem>> removeDecoration(@Path("decorationId") long decorationId,
                                                         @Header("userId") long userId,
                                                         @Header("Access-Token") String accessToken);

}
