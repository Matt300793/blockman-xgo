package com.sandboxol.game.webapi;

import java.util.concurrent.TimeUnit;

import okhttp3.OkHttpClient;
import retrofit2.Retrofit;
import retrofit2.converter.gson.GsonConverterFactory;

/**
 * Created by arthur on 15/11/22.
 */
public class GameWebUtils {

    public static String CREATOR_BASE_URL = "http://hall2.sandboxol.com:9121/";
    public static String ENTER_BASE_URL = "http://hall2.sandboxol.com:9122/";
    public static String QUERIER_BASE_URL = "http://hall2.sandboxol.com:9123/";
    public static String BULLETIN_BASE_URL = "bulletin2.sandboxol.com:9511";

    public static String MGS_QUEUE_BASE_URL = "queue2.mgs.sandboxol.com:9612";
    public static String MGS_TEAM_BASE_URL = "queue2.mgs.sandboxol.com:9210";

    public static String MSG_ORGANIZE_TEAM_BASE_URL = "queue2.mgs.sandboxol.com:9921";

    public static String BLOCK_MAN_MSG_ORGANIZE_TEAM_BASE_URL = "queue.bmg.sandboxol.com:9921";

    public static Retrofit creatorApi = null;
    public static Retrofit enterApi = null;
    public static Retrofit querierApi = null;

    public static <T> T createApi(Class<T> clazz) {
        final OkHttpClient okHttpClient = new OkHttpClient.Builder().connectTimeout(2, TimeUnit.SECONDS).readTimeout(8, TimeUnit.SECONDS).build();
        if (creatorApi == null) {
            synchronized (GameWebUtils.class) {
                if (creatorApi == null) {
                    creatorApi = new Retrofit.Builder()
                            .client(okHttpClient)
                            .baseUrl(CREATOR_BASE_URL)
                            .addConverterFactory(GsonConverterFactory.create())
                            .build();
                }
            }
        }
        return creatorApi.create(clazz);
    }

    public static <T> T enterApi(Class<T> clazz) {
        final OkHttpClient okHttpClient = new OkHttpClient.Builder().connectTimeout(2, TimeUnit.SECONDS).readTimeout(8, TimeUnit.SECONDS).build();
        if (enterApi == null) {
            synchronized (GameWebUtils.class) {
                if (enterApi == null) {
                    enterApi = new Retrofit.Builder()
                            .client(okHttpClient)
                            .baseUrl(ENTER_BASE_URL)
                            .addConverterFactory(GsonConverterFactory.create())
                            .build();
                }
            }
        }
        return enterApi.create(clazz);
    }

    public static <T> T queryApi(Class<T> clazz) {
        final OkHttpClient okHttpClient = new OkHttpClient.Builder().connectTimeout(2, TimeUnit.SECONDS).readTimeout(8, TimeUnit.SECONDS).build();
        if (querierApi == null) {
            synchronized (GameWebUtils.class) {
                if (querierApi == null) {
                    querierApi = new Retrofit.Builder()
                            .client(okHttpClient)
                            .baseUrl(QUERIER_BASE_URL)
                            .addConverterFactory(GsonConverterFactory.create())
                            .build();
                }
            }
        }
        return querierApi.create(clazz);
    }

    public synchronized static <T> T enterOtherRegionApi(Class<T> clazz, String url) {
        final OkHttpClient okHttpClient = new OkHttpClient.Builder().connectTimeout(2, TimeUnit.SECONDS).readTimeout(8, TimeUnit.SECONDS).build();
        Retrofit enterOtherRegionApi = new Retrofit.Builder()
                .client(okHttpClient)
                .baseUrl(url)
                .addConverterFactory(GsonConverterFactory.create())
                .build();
        return enterOtherRegionApi.create(clazz);
    }

}
