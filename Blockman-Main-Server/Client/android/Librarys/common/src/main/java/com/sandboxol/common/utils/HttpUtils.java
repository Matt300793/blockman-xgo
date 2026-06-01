package com.sandboxol.common.utils;

import android.content.Context;

import com.sandboxol.common.R;
import com.sandboxol.common.config.HttpCode;

/**
 * Created by Jimmy on 2017/11/17 0017.
 */
public class HttpUtils {

    public static String getHttpErrorMsg(Context context, int error) {
        switch (error) {
            case HttpCode.NO_CONNECTED:
                return context.getResources().getString(R.string.connect_server_no_connect);
            case HttpCode.TIMEOUT:
                return context.getResources().getString(R.string.connect_server_time_out);
            case HttpCode.UN_KNOW:
                return context.getResources().getString(R.string.connect_server_un_know);
            case HttpCode.AUTH_FAILED:
                return context.getResources().getString(R.string.connect_repeat_login);
            default:
                return context.getResources().getString(R.string.connect_error_code, error);
        }
    }

}
