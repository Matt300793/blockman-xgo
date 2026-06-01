package com.sandboxol.blockymods.web;

import android.content.Context;

import com.sandboxol.blocky.entity.Game;
import com.sandboxol.blockymods.BuildConfig;
import com.sandboxol.blockymods.entity.AccountCenter;
import com.sandboxol.blockymods.entity.Dispatch;
import com.sandboxol.blockymods.entity.MiniGameToken;
import com.sandboxol.blockymods.entity.VisitorCenter;
import com.sandboxol.common.utils.CommonHelper;
import com.sandboxol.common.base.web.HttpListSubscriber;
import com.sandboxol.common.base.web.HttpPageListSubscriber;
import com.sandboxol.common.base.web.HttpResponse;
import com.sandboxol.common.base.web.HttpSubscriber;
import com.sandboxol.common.base.web.OnResponseListener;
import com.sandboxol.common.retrofit.RetrofitFactory;
import com.sandboxol.common.widget.rv.pagerv.PageData;
import com.trello.rxlifecycle.ActivityEvent;
import com.trello.rxlifecycle.ActivityLifecycleProvider;

import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.concurrent.TimeUnit;

import rx.android.schedulers.AndroidSchedulers;
import rx.exceptions.Exceptions;
import rx.schedulers.Schedulers;

/**
 * Created by Bob on 2017/11/6.
 */
public class GameApi {

    private static final IGameApi api = RetrofitFactory.create(BuildConfig.BASE_URL, IGameApi.class);
    private static final IGameApi gameApi = RetrofitFactory.create(BuildConfig.BLOCK_MAN_MINI_GAME_DISPATCH_URL, IGameApi.class);

    /**
     * 推荐列表
     *
     * @param context
     * @param listener
     */
    public static void recommendation(Context context, OnResponseListener<List<Game>> listener) {
        api.recommendation(CommonHelper.getLanguage())
                .compose(((ActivityLifecycleProvider) context).bindUntilEvent(ActivityEvent.DESTROY))
                .subscribeOn(Schedulers.newThread())
                .observeOn(AndroidSchedulers.mainThread())
                .subscribe(new HttpListSubscriber<>(listener));
    }

    /**
     * 最近游戏列表
     *
     * @param context
     * @param listener
     */
    public static void recentlyPlayList(Context context, OnResponseListener<List<Game>> listener) {
        api.recentlyPlayList(CommonHelper.getLanguage(),
                AccountCenter.newInstance().userId.get(),
                AccountCenter.newInstance().token.get())
                .compose(((ActivityLifecycleProvider) context).bindUntilEvent(ActivityEvent.DESTROY))
                .subscribeOn(Schedulers.newThread())
                .observeOn(AndroidSchedulers.mainThread())
                .subscribe(new HttpListSubscriber<>(listener));
    }

    /**
     * 好友在玩列表
     *
     * @param context
     * @param listener
     */
    public static void friendPlayList(Context context, OnResponseListener<List<Game>> listener) {
        api.friendPlayList(CommonHelper.getLanguage(),
                AccountCenter.newInstance().userId.get(),
                AccountCenter.newInstance().token.get())
                .compose(((ActivityLifecycleProvider) context).bindUntilEvent(ActivityEvent.DESTROY))
                .subscribeOn(Schedulers.newThread())
                .observeOn(AndroidSchedulers.mainThread())
                .subscribe(new HttpListSubscriber<>(listener));
    }

    /**
     * 游戏详情
     *
     * @param context
     * @param gameId
     * @param listener
     */
    public static void miniGameDetail(Context context, String gameId, OnResponseListener<Game> listener) {
        api.miniGameDetail(gameId, CommonHelper.getLanguage(),
                AccountCenter.newInstance().userId.get(),
                AccountCenter.newInstance().token.get())
                .compose(((ActivityLifecycleProvider) context).bindUntilEvent(ActivityEvent.DESTROY))
                .subscribeOn(Schedulers.newThread())
                .observeOn(AndroidSchedulers.mainThread())
                .subscribe(new HttpSubscriber<>(listener));
    }

    /**
     * 点赞
     *
     * @param context
     * @param gameId
     * @param listener
     */
    public static void appreciation(Context context, String gameId, OnResponseListener<Integer> listener) {
        long userId;
        String token;
        if (AccountCenter.newInstance().login.get()) {
            userId = AccountCenter.newInstance().userId.get();
            token = AccountCenter.newInstance().token.get();
        } else {
            userId = VisitorCenter.newInstance().userId.get();
            token = VisitorCenter.newInstance().token.get();
        }

        api.appreciation(gameId, userId, token)
                .compose(((ActivityLifecycleProvider) context).bindUntilEvent(ActivityEvent.DESTROY))
                .subscribeOn(Schedulers.newThread())
                .observeOn(AndroidSchedulers.mainThread())
                .subscribe(new HttpSubscriber<>(listener));
    }

    /**
     * 分类
     *
     * @param context
     * @param pageNo
     * @param pageSize
     * @param orderType
     * @param typeId
     * @param order
     * @param listener
     */
    public static void category(Context context, String pageNo, String pageSize, String orderType, long typeId, String order, OnResponseListener<PageData<Game>> listener) {
        api.category(pageNo, pageSize, orderType, typeId, order, CommonHelper.getLanguage())
                .compose(((ActivityLifecycleProvider) context).bindUntilEvent(ActivityEvent.DESTROY))
                .subscribeOn(Schedulers.newThread())
                .observeOn(AndroidSchedulers.mainThread())
                .subscribe(new HttpPageListSubscriber<>(listener));
    }

    /**
     * 获取游戏Dispatch
     *
     * @param context
     * @param typeId
     * @param listener
     */
    public static void getMiniGameDispatch(Context context, String typeId, OnResponseListener<Dispatch> listener) {
        long userId;
        String token;
        String nickName;
        MiniGameToken[] miniGameToken = new MiniGameToken[1];
        if (AccountCenter.newInstance().login.get()) {
            userId = AccountCenter.newInstance().userId.get();
            token = AccountCenter.newInstance().token.get();
            nickName = AccountCenter.newInstance().nickName.get();
        } else {
            userId = VisitorCenter.newInstance().userId.get();
            token = VisitorCenter.newInstance().token.get();
            nickName = VisitorCenter.newInstance().nickName.get();
        }
        Map<String, Object> map = new HashMap<>();
        map.put("clz", 0);
        map.put("rid", 1001);
        map.put("name", nickName);
        map.put("pioneer", true);
        api.miniGameToken(typeId, userId, token)
                .compose(((ActivityLifecycleProvider) context).bindUntilEvent(ActivityEvent.DESTROY))
                .subscribeOn(Schedulers.newThread())
                .doOnNext(r -> {
                    if (r.isFailed()) {
                        listener.onError(r.getCode(), r.getMsg());
                    }
                })
                .filter(HttpResponse::isSuccess)
                .doOnNext(r -> miniGameToken[0] = r.getData())
                .flatMap(r -> gameApi.newMiniGameDispatcher(map, userId, r.getData().getToken()))
                .observeOn(AndroidSchedulers.mainThread())
                .doOnNext(r -> {
                    if (r.isSuccess() && r.getData() != null) {
                        Dispatch dispatch = r.getData();
                        dispatch.signature = miniGameToken[0].getSignature();
                        dispatch.timestamp = miniGameToken[0].getTimestamp();
                        listener.onSuccess(dispatch);
                    } else {
                        listener.onError(r.getCode(), r.getMsg());
                    }
                })
                .filter(HttpResponse::isFailed)
                .delay(5, TimeUnit.SECONDS)
                .doOnNext(r -> {
                    if (r.getCode() == 2) {
                        try {
                            throw new Exception("get dispatch failed");
                        } catch (Throwable e) {
                            throw Exceptions.propagate(e);
                        }
                    }
                })
                .retry(17280)
                .filter(HttpResponse::isSuccess)
                .observeOn(AndroidSchedulers.mainThread())
                .subscribe(new HttpSubscriber<Dispatch, HttpResponse<Dispatch>>(listener) {
                    @Override
                    public boolean isCheckNetwork() {
                        return true;
                    }
                });
    }

}
