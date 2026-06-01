package com.sandboxol.blockymods.view.fragment.changename;

import android.content.Context;

import com.sandboxol.blockymods.entity.User;
import com.sandboxol.blockymods.web.UserApi;
import com.sandboxol.common.base.web.OnResponseListener;
import com.sandboxol.common.base.model.IDefaultModel;

/**
 * Created by Bob on 2017/10/27.
 */
public class ChangeNameModel implements IDefaultModel<User> {

    private String nickName;

    public ChangeNameModel(String nickName) {
        this.nickName = nickName;
    }

    @Override
    public void loadData(Context context, OnResponseListener<User> listener) {
        UserApi.changeNickName(context, nickName, listener);
    }
}
