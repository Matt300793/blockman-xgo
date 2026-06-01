package com.sandboxol.blockymods.view.fragment.changepassword;

import android.content.Context;

import com.sandboxol.blockymods.entity.ChangePasswordForm;
import com.sandboxol.blockymods.web.UserApi;
import com.sandboxol.common.base.web.OnResponseListener;
import com.sandboxol.common.base.model.IDefaultModel;

/**
 * Created by Bob on 2017/10/27.
 */

public class ChangePasswordModel implements IDefaultModel {

    private ChangePasswordForm form;

    public ChangePasswordModel(ChangePasswordForm form) {
        this.form = form;
    }

    @Override
    public void loadData(Context context, OnResponseListener listener) {
        UserApi.modifyPassword(context, form, listener);
    }
}
