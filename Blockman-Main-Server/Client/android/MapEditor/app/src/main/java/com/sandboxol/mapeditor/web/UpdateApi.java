package com.sandboxol.mapeditor.web;

import android.content.Context;

import com.sandboxol.common.base.web.HttpSubscriber;
import com.sandboxol.common.base.web.OnResponseListener;
import com.sandboxol.common.retrofit.RetrofitFactory;
import com.sandboxol.mapeditor.entity.LatestVersion;
import com.trello.rxlifecycle.ActivityEvent;
import com.trello.rxlifecycle.ActivityLifecycleProvider;

import rx.android.schedulers.AndroidSchedulers;
import rx.schedulers.Schedulers;

/**
 * Created by Jimmy on 2017/12/7 0007.
 */
public class UpdateApi {

    private static final IUpdateApi updateApi = RetrofitFactory.create("http://ols.sandboxol.com", IUpdateApi.class);

    /**
     * 检测更新
     *
     * @param context
     * @param listener
     */
    public static void checkAppVersion(Context context, OnResponseListener<LatestVersion> listener) {
        updateApi.checkAppVersion()
                .compose(((ActivityLifecycleProvider) context).bindUntilEvent(ActivityEvent.DESTROY))
                .subscribeOn(Schedulers.newThread())
                .observeOn(AndroidSchedulers.mainThread())
                .subscribe(new HttpSubscriber<>(listener));
    }

}
