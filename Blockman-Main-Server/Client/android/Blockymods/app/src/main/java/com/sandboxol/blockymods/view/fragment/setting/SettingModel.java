package com.sandboxol.blockymods.view.fragment.setting;

import android.content.Context;

import com.sandboxol.blockymods.web.UserApi;
import com.sandboxol.common.base.web.OnResponseListener;

/**
 * Created by Bob on 2017/12/15
 */
public class SettingModel {

    public void logout(Context context, OnResponseListener listener) {
        UserApi.logout(context, listener);
    }
}
