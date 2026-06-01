package com.sandboxol.blockymods.entity;

import android.databinding.BaseObservable;
import android.databinding.ObservableField;

import com.google.gson.Gson;
import com.sandboxol.blockymods.utils.AppSharedUtils;

/**
 * Created by Bob on 2017/10/16.
 */
public class VisitorCenter extends BaseObservable {

    private static VisitorCenter instance = null;

    public ObservableField<Long> userId = new ObservableField<>(0L);
    public ObservableField<String> token = new ObservableField<>("");
    public ObservableField<String> nickName = new ObservableField<>("");

    public static VisitorCenter newInstance() {
        if (instance == null) {
            instance = new VisitorCenter();
        }
        return instance;
    }

    public static void setInstance(VisitorCenter instance) {
        VisitorCenter.instance = instance;
    }

    /**
     * 存储游客信息
     */
    public synchronized static void putVisitorInfo() {
        if (instance != null) {
            Gson gson = new Gson();
            AppSharedUtils.newInstance().putVisitorInfo(gson.toJson(instance));
        } else {
            AppSharedUtils.newInstance().putVisitorInfo(null);
        }
    }

    public static void updateVisitorInfo(Visitor visitor) {
        instance.setUserId(visitor.getId());
        instance.setToken(visitor.getAccessToken());
        instance.setNickName(visitor.getNickName());
        VisitorCenter.putVisitorInfo();
    }

    /**
     * 加载游客信息
     */
    public static void getVisitorInfo() {
        AppSharedUtils.newInstance().getVisitorInfo();
    }

    public void setUserId(long userId) {
        this.userId.set(userId);
    }

    public void setToken(String token) {
        this.token.set(token);
    }

    public void setNickName(String nickName) {
        this.nickName.set(nickName);
    }
}
