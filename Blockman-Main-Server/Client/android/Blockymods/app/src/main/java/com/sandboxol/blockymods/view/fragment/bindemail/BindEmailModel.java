package com.sandboxol.blockymods.view.fragment.bindemail;

import android.content.Context;

import com.sandboxol.blockymods.entity.EmailBindForm;
import com.sandboxol.blockymods.web.UserApi;
import com.sandboxol.common.base.model.IModel;
import com.sandboxol.common.base.web.OnResponseListener;

/**
 * Created by Bob on 2017/11/22.
 */
public class BindEmailModel implements IModel {

    void sendCode(Context context, String email, OnResponseListener listener) {
        UserApi.sendEmailCode(context, email, listener);
    }

    public void bindEmail(Context context, String type, EmailBindForm form, OnResponseListener listener) {
        UserApi.bindEmail(context, type, form, listener);
    }
}
