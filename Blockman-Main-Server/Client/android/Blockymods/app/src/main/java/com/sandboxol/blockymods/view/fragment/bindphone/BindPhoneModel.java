package com.sandboxol.blockymods.view.fragment.bindphone;

import android.content.Context;

import com.sandboxol.blockymods.entity.PhoneBindForm;
import com.sandboxol.blockymods.web.UserApi;
import com.sandboxol.common.base.model.IModel;
import com.sandboxol.common.base.web.OnResponseListener;

/**
 * Created by Bob on 2017/10/27.
 */
public class BindPhoneModel implements IModel {

    public void bindPhone(Context context, PhoneBindForm form,  String type, OnResponseListener listener) {
        UserApi.bindPhone(context, type, form, listener);
    }

    public void sendCode(Context context, String phoneNum, String type, OnResponseListener listener) {
        UserApi.sendCode(context, phoneNum, type, listener);
    }
}
