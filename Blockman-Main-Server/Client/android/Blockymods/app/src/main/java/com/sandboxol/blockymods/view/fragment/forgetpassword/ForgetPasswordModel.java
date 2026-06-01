package com.sandboxol.blockymods.view.fragment.forgetpassword;

import android.content.Context;

import com.sandboxol.blockymods.entity.PhoneBindForm;
import com.sandboxol.blockymods.web.UserApi;
import com.sandboxol.common.base.model.IModel;
import com.sandboxol.common.base.web.OnResponseListener;

/**
 * Created by Bob on 2017/11/14.
 */ class ForgetPasswordModel implements IModel {

    void retrieve(Context context, String code, OnResponseListener listener) {
        UserApi.retrieve(context, code, listener);
    }

    void retrievePassword(Context context, PhoneBindForm form, OnResponseListener listener) {
        UserApi.retrievePassword(context, form, listener);
    }
}
