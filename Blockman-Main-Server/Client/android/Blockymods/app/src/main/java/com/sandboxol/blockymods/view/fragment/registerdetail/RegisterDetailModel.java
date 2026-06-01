package com.sandboxol.blockymods.view.fragment.registerdetail;

import android.content.Context;

import com.sandboxol.blockymods.entity.User;
import com.sandboxol.blockymods.web.UserApi;
import com.sandboxol.common.base.model.IModel;
import com.sandboxol.common.base.web.OnResponseListener;

import java.io.File;

/**
 * Created by Bob on 2017/10/17.
 */
public class RegisterDetailModel implements IModel {

    void userRegister(Context context, User user, OnResponseListener<User> listener) {
        UserApi.userRegister(context, user, listener);
    }

    public void uploadIcon(Context context, File tmpDir, String key, OnResponseListener<String> listener) {
        UserApi.uploadIcon(context, tmpDir, key, listener);
    }
}
