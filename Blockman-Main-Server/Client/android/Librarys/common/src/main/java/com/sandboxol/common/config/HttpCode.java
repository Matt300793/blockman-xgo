package com.sandboxol.common.config;

/**
 * Created by Jimmy on 2017/9/27 0027.
 */
public interface HttpCode {

    int SUCCESS = 1;
    int FAILED = 2;
    int AUTH_FAILED = 401;//认证错误，eg.重复登录

    int NO_CONNECTED = 10000;
    int TIMEOUT = 10001;
    int UN_KNOW = 10002;
}
