package com.sandboxol.blockymods.view.fragment.updateuserinfo;

import android.content.Context;

import com.sandboxol.blockymods.entity.User;
import com.sandboxol.blockymods.web.UserApi;
import com.sandboxol.common.base.web.OnResponseListener;
import com.sandboxol.common.base.model.IDefaultModel;

/**
 * Created by Bob on 2017/10/27.
 */
public class UpdateUserInfoModel implements IDefaultModel<User> {

    private User user;

    public UpdateUserInfoModel(User user) {
        this.user = user;
    }

    @Override
    public void loadData(Context context, OnResponseListener<User> listener) {
        UserApi.changeInfo(context, user, listener);
    }
}
