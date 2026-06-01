package com.sandboxol.mapeditor.web;

import com.sandboxol.common.base.web.HttpResponse;
import com.sandboxol.mapeditor.entity.LatestVersion;

import retrofit2.http.GET;
import rx.Observable;

/**
 * Created by Jimmy on 2017/12/7 0007.
 */
public interface IUpdateApi {

    @GET("/api/v1/config/mapeditor-check-version")
    Observable<HttpResponse<LatestVersion>> checkAppVersion();

}
