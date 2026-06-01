package com.sandboxol.blockymods.entity;

import android.databinding.BaseObservable;
import android.databinding.ObservableField;

import com.google.gson.Gson;
import com.sandboxol.blockymods.App;
import com.sandboxol.blockymods.R;
import com.sandboxol.blockymods.utils.AppSharedUtils;

/**
 * Created by Bob on 2017/10/16.
 */
public class AccountCenter extends BaseObservable {

    private static AccountCenter instance = null;

    public ObservableField<Long> userId = new ObservableField<>(0L);
    public ObservableField<String> token = new ObservableField<>("");
    public ObservableField<String> nickName = new ObservableField<>(App.getContext().getResources().getString(R.string.more_fragment_visitor));
    public ObservableField<String> picUrl = new ObservableField<>("");
    public ObservableField<Integer> sex = new ObservableField<>(0);
    public ObservableField<String> detail = new ObservableField<>(
            App.getContext().getResources().getString(R.string.more_fragment_details,
                    App.getContext().getResources().getString(R.string.more_fragment_no_details)));
    public ObservableField<String> gold = new ObservableField<>(App.getContext().getResources().getString(R.string.more_fragment_no_login));
    public ObservableField<String> birthday = new ObservableField<>("");
    public ObservableField<Boolean> login = new ObservableField<>(false);
    public ObservableField<String> telephone = new ObservableField<>("");
    public ObservableField<String> email = new ObservableField<>("");

    public static AccountCenter newInstance() {
        if (instance == null) {
            instance = new AccountCenter();
        }
        return instance;
    }

    public static void setInstance(AccountCenter instance) {
        AccountCenter.instance = instance;
    }

    /**
     * 存储用户信息
     */
    public synchronized static void putAccountInfo() {
        if (instance != null) {
            Gson gson = new Gson();
            AppSharedUtils.newInstance().putAccountInfo(gson.toJson(instance));
        } else {
            AppSharedUtils.newInstance().putAccountInfo(null);
        }
    }

    /**
     * 加载用户信息
     */
    public static void getAccountInfo() {
        AppSharedUtils.newInstance().getAccountInfo();
    }

    /**
     * 更新本地用户信息
     *
     * @param user
     */
    public static void updateAccount(User user) {
        instance.setNickName(user.getNickName());
        instance.setUserId(user.getUserId());
        instance.setToken(user.getAccessToken());
        instance.setDetail(user.getDetails());
        instance.setSex(user.getSex());
        instance.setGold(0L);
        instance.setPicUrl(user.getPicUrl());
        instance.setBirthday(user.getBirthday());
        instance.setLogin(true);
        instance.setTelephone(user.getTelephone());
        instance.setEmail(user.getEmail());
        AccountCenter.putAccountInfo();
    }

    public static void logout() {
        if (instance == null) return;
        instance.setNickName(App.getContext().getResources().getString(R.string.more_fragment_visitor));
        instance.setUserId(0);
        instance.setToken("");
        instance.setDetail("");
        instance.setSex(0);
        instance.setGold(0L);
        instance.setPicUrl("");
        instance.setBirthday("");
        instance.setLogin(false);
        instance.setTelephone("");
        instance.setEmail("");

        AppSharedUtils.newInstance().putAccountInfo("");
        getAccountInfo();
        AccountCenter.setInstance(null);
    }

//    public static boolean isLogin() {
//        return instance != null && instance.userId.get() != 0;
//    }

    public void setLogin(boolean login) {
        this.login.set(login);
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

    public void setPicUrl(String picUrl) {
        this.picUrl.set(picUrl);
    }

    public void setSex(int sex) {
        this.sex.set(sex);
    }

    public void setDetail(String detail) {
        this.detail.set(detail);
    }

    public void setGold(long gold) {
        this.gold.set(App.getContext().getResources().getString(R.string.more_fragment_gold, gold));
    }

    public void setBirthday(String birthday) {
        this.birthday.set(birthday);
    }

    public void setTelephone(String telephone) {
        this.telephone.set(telephone);
    }

    public void setEmail(String email) {
        this.email.set(email);
    }
}
