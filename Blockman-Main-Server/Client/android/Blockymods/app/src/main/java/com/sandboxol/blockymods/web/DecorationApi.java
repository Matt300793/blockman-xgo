package com.sandboxol.blockymods.web;

import android.content.Context;

import com.sandboxol.blockymods.BuildConfig;
import com.sandboxol.blockymods.entity.AccountCenter;
import com.sandboxol.blockymods.entity.DressItem;
import com.sandboxol.blockymods.entity.MiniGameToken;
import com.sandboxol.blockymods.entity.VisitorCenter;
import com.sandboxol.common.base.web.HttpListSubscriber;
import com.sandboxol.common.base.web.HttpResponse;
import com.sandboxol.common.base.web.HttpSubscriber;
import com.sandboxol.common.base.web.OnResponseListener;
import com.sandboxol.common.retrofit.RetrofitFactory;
import com.sandboxol.common.utils.CommonHelper;
import com.trello.rxlifecycle.ActivityEvent;
import com.trello.rxlifecycle.ActivityLifecycleProvider;

import java.util.List;
import java.util.concurrent.TimeUnit;

import rx.Observable;
import rx.android.schedulers.AndroidSchedulers;
import rx.schedulers.Schedulers;

/**
 * Created by Bob on 2017/12/6.
 */
public class DecorationApi {

    private static final IDecorationApi api = RetrofitFactory.create(BuildConfig.BASE_URL, IDecorationApi.class);

    /**
     * 获取装饰列表
     *
     * @param context
     * @param typeId
     * @param listener
     */
    public static void dressList(Context context, long typeId, OnResponseListener<List<DressItem>> listener) {
        long userId;
        String token;
        if (AccountCenter.newInstance().login.get()) {
            userId = AccountCenter.newInstance().userId.get();
            token = AccountCenter.newInstance().token.get();
        } else {
            userId = VisitorCenter.newInstance().userId.get();
            token = VisitorCenter.newInstance().token.get();
        }
        api.dressList(typeId, CommonHelper.getLanguage(), userId, token)
                .compose(((ActivityLifecycleProvider) context).bindUntilEvent(ActivityEvent.DESTROY))
                .subscribeOn(Schedulers.newThread())
                .observeOn(AndroidSchedulers.mainThread())
                .subscribe(new HttpListSubscriber<>(listener));
    }

    /**
     * 获取正在使用的装扮信息
     *
     * @param context
     * @param listener
     */
    public static void isUsingList(Context context, OnResponseListener<List<DressItem>> listener) {
        getUsingDress(context)
                .observeOn(AndroidSchedulers.mainThread())
                .subscribe(new HttpListSubscriber<>(listener));
    }

    public static Observable<HttpResponse<List<DressItem>>> getUsingDress(Context context) {
        long userId;
        String token;
        if (AccountCenter.newInstance().login.get()) {
            userId = AccountCenter.newInstance().userId.get();
            token = AccountCenter.newInstance().token.get();
        } else {
            userId = VisitorCenter.newInstance().userId.get();
            token = VisitorCenter.newInstance().token.get();
        }
        return api.isUsingList(CommonHelper.getLanguage(), userId, token)
                .compose(((ActivityLifecycleProvider) context).bindUntilEvent(ActivityEvent.DESTROY))
                .subscribeOn(Schedulers.newThread());
    }

    /**
     * 使用装扮
     *
     * @param context
     * @param listener
     */
    public static void useDecoration(Context context, long decorationId, OnResponseListener<DressItem> listener) {
        long userId;
        String token;
        if (AccountCenter.newInstance().login.get()) {
            userId = AccountCenter.newInstance().userId.get();
            token = AccountCenter.newInstance().token.get();
        } else {
            userId = VisitorCenter.newInstance().userId.get();
            token = VisitorCenter.newInstance().token.get();
        }
        api.useDecoration(decorationId, CommonHelper.getLanguage(), userId, token)
                .compose(((ActivityLifecycleProvider) context).bindUntilEvent(ActivityEvent.DESTROY))
                .subscribeOn(Schedulers.newThread())
                .observeOn(AndroidSchedulers.mainThread())
                .subscribe(new HttpSubscriber<>(listener));
    }

    /**
     * 使用装扮
     *
     * @param context
     * @param listener
     */
    public static void removeDecoration(Context context, long decorationId, OnResponseListener<DressItem> listener) {
        api.removeDecoration(decorationId, AccountCenter.newInstance().userId.get(), AccountCenter.newInstance().token.get())
                .compose(((ActivityLifecycleProvider) context).bindUntilEvent(ActivityEvent.DESTROY))
                .subscribeOn(Schedulers.newThread())
                .observeOn(AndroidSchedulers.mainThread())
                .subscribe(new HttpSubscriber<>(listener));
    }
}
