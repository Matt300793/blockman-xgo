package com.sandboxol.blockymods;

import android.app.Activity;
import android.content.Context;
import android.util.Log;

import com.facebook.CallbackManager;
import com.facebook.FacebookCallback;
import com.facebook.FacebookException;
import com.facebook.FacebookSdk;
import com.facebook.Profile;
import com.facebook.appevents.AppEventsLogger;
import com.facebook.login.LoginManager;
import com.facebook.login.LoginResult;
import com.sandboxol.blockymods.config.EventConstant;
import com.sandboxol.blockymods.config.StringConstant;
import com.sandboxol.blockymods.interfaces.ILoginListener;
import com.sandboxol.common.base.app.BaseApplication;
import com.sandboxol.common.utils.ToastUtils;
import com.tendcloud.tenddata.TCAgent;

import java.util.Arrays;

/**
 * Created by Bob on 2017/11/22.
 */

public class ChannelController {

    private static ChannelController controller;
    private CallbackManager callbackManager;

    private ChannelController(Context context) {
        initThirdPartySdk(context);
    }

    public static ChannelController newInstance() {
        if (controller == null) {
            controller = new ChannelController(BaseApplication.getContext());
        }
        return controller;
    }

    private void initThirdPartySdk(Context context) {
        try {
            AppEventsLogger.activateApp(App.getApp());
        } catch (Exception | VerifyError e) {

        }
    }

    public void facebookLogin(final Context context, final ILoginListener listener) {
        try {
            if (callbackManager == null) {
                callbackManager = CallbackManager.Factory.create();
                LoginManager.getInstance().registerCallback(callbackManager, new FacebookCallback<LoginResult>() {
                    @Override
                    public void onSuccess(LoginResult loginResult) {
                        Log.d("Facebook", String.format("id: %s, name: %s", loginResult.getAccessToken().getUserId(), loginResult.getAccessToken().getToken()));
                        Profile profile = Profile.getCurrentProfile();
                        String name = profile.getName();
                        listener.loginSuccessful(loginResult.getAccessToken().getUserId(), name, loginResult.getAccessToken().getToken(), StringConstant.THIRD_PART_LOGIN_FB);
                        TCAgent.onEvent(context, EventConstant.THIRD_FACEBOOK_SUC);
                    }

                    @Override
                    public void onCancel() {
                        Log.d("Facebook", "fackbook login cancel");
                        ToastUtils.showShortToast(context, R.string.fb_login_cancel);
                    }

                    @Override
                    public void onError(FacebookException error) {
                        Log.d("Facebook", "facebook login error:" + error.getMessage());
                        ToastUtils.showShortToast(context, R.string.fb_login_failed);
                    }
                });
            }

            LoginManager.getInstance().logInWithReadPermissions((Activity) context, Arrays.asList("public_profile", "user_friends"));
        } catch (Exception e) {
            Log.e("Facebook", "facebook login failed");
        }
    }

}
