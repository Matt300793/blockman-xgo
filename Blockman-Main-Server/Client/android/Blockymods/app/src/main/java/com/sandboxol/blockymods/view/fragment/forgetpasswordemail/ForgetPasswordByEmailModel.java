package com.sandboxol.blockymods.view.fragment.forgetpasswordemail;

import android.content.Context;

import com.sandboxol.blockymods.web.UserApi;
import com.sandboxol.common.base.model.IModel;
import com.sandboxol.common.base.web.OnResponseListener;

/**
 * Created by Bob on 2017/11/23.
 */
public class ForgetPasswordByEmailModel implements IModel {

    public void forgetPassword(Context context, String email, OnResponseListener listener) {
        UserApi.resetPassword(context, email, listener);
    }
}
