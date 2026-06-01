package com.sandboxol.blockymods.utils;

import android.content.Context;

import com.google.gson.Gson;
import com.google.gson.reflect.TypeToken;
import com.sandboxol.blockymods.App;
import com.sandboxol.blockymods.config.SharedConstant;
import com.sandboxol.blockymods.entity.AccountCenter;
import com.sandboxol.blockymods.entity.VisitorCenter;
import com.sandboxol.common.utils.SharedUtils;

/**
 * Created by Bob on 2017/10/16.
 */
public class AppSharedUtils {

    private static AppSharedUtils instance = null;

    private Context context;

    private AppSharedUtils(Context ctx) {
        this.context = ctx;
    }

    public static AppSharedUtils newInstance() {
        if (instance == null) {
            instance = new AppSharedUtils(App.getContext());
        }
        return instance;
    }

    /**
     * 存储登录用户信息
     *
     * @param accountInfo
     */
    public void putAccountInfo(String accountInfo) {
        SharedUtils.putString(context, SharedConstant.ACCOUNT, SharedConstant.ACCOUNT_INFO, accountInfo);
    }

    /**
     * 获取登录用户信息
     */
    public void getAccountInfo() {
        String accountInfo = SharedUtils.getString(context, SharedConstant.ACCOUNT, SharedConstant.ACCOUNT_INFO, null);
        if (accountInfo != null) {
            try {
                Gson gson = new Gson();
                AccountCenter accountCenter = gson.fromJson(accountInfo, new TypeToken<AccountCenter>() {
                }.getType());
                AccountCenter.setInstance(accountCenter);
            } catch (Exception e) {
                AccountCenter.setInstance(null);
                e.printStackTrace();
            }
        } else {
            AccountCenter.setInstance(null);
        }
    }

    /**
     * 存储游客用户信息
     *
     * @param visitorInfo
     */
    public void putVisitorInfo(String visitorInfo) {
        SharedUtils.putString(context, SharedConstant.ACCOUNT, SharedConstant.VISITOR_INFO, visitorInfo);
    }

    /**
     * 获取游客用户信息
     */
    public void getVisitorInfo() {
        String visitorInfo = SharedUtils.getString(context, SharedConstant.ACCOUNT, SharedConstant.VISITOR_INFO, null);
        if (visitorInfo != null) {
            try {
                Gson gson = new Gson();
                VisitorCenter visitorCenter = gson.fromJson(visitorInfo, new TypeToken<VisitorCenter>() {
                }.getType());
                VisitorCenter.setInstance(visitorCenter);
            } catch (Exception e) {
                VisitorCenter.setInstance(null);
                e.printStackTrace();
            }
        } else {
            VisitorCenter.setInstance(null);
        }
    }

}
