package com.sandboxol.common.base.app;

import android.app.Application;
import android.content.Context;

/**
 * Created by Jimmy on 2016/7/31.
 */
public class BaseApplication extends Application {

    private static BaseApplication application;
    private static Context context;

    @Override
    public void onCreate() {
        super.onCreate();
        context = this;
        application = this;
    }

    public static BaseApplication getApp() {
        return application;
    }

    public static Context getContext() {
        return context;
    }

}
