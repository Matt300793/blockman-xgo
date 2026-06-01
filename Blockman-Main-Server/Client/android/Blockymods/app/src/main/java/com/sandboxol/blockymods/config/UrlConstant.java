package com.sandboxol.blockymods.config;

import com.sandboxol.blockymods.BuildConfig;

/**
 * Created by Bob on 2017/10/28.
 */
public interface UrlConstant {

    String ksUserPicUrl = "http://7xjty7.dl1.z0.glb.clouddn.com/";

    String PLAY_STORE_URL = "https://play.google.com/store/apps/details?id=" + BuildConfig.APPLICATION_ID;

    String UPDATE_VERSION = BuildConfig.FLAVOR.toLowerCase().contains("envtest") ? "http://dev.sandboxol.com:9000" : "http://ols.sandboxol.com";
}
