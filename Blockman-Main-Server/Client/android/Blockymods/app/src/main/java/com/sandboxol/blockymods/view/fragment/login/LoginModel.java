package com.sandboxol.blockymods.view.fragment.login;

import android.content.Context;

import com.sandboxol.blockymods.entity.LoginRegisterAccountForm;
import com.sandboxol.blockymods.entity.User;
import com.sandboxol.blockymods.web.UserApi;
import com.sandboxol.common.base.web.OnResponseListener;
import com.sandboxol.common.base.model.IDefaultModel;

/**
 * Created by Bob on 2017/10/16.
 */
public class LoginModel implements IDefaultModel<User> {

    private LoginRegisterAccountForm form;

    public LoginModel(LoginRegisterAccountForm form) {
        this.form = form;
    }

    @Override
    public void loadData(Context context, OnResponseListener<User> listener) {
        UserApi.login(context, form, listener);
    }

}
