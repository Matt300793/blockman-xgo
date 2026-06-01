package com.sandboxol.blockymods.view.fragment.game;

import android.content.Context;

import com.sandboxol.blockymods.entity.LoginRegisterAccountForm;
import com.sandboxol.blockymods.entity.Visitor;
import com.sandboxol.blockymods.entity.VisitorCenter;
import com.sandboxol.blockymods.web.UserApi;
import com.sandboxol.common.base.model.IModel;
import com.sandboxol.common.base.web.OnResponseListener;

/**
 * Created by Bob on 2017/11/15.
 */
class GameModel implements IModel {

    void loadVisitorInfo(Context context, LoginRegisterAccountForm form) {
        visitor(context, form);
    }

    private void visitor(Context context, LoginRegisterAccountForm form) {
        UserApi.visitor(context, form, new OnResponseListener<Visitor>() {
            @Override
            public void onSuccess(Visitor data) {
                VisitorCenter.updateVisitorInfo(data);
            }

            @Override
            public void onError(int code, String msg) {
            }

            @Override
            public void onServerError(int error) {
            }
        });
    }

}
