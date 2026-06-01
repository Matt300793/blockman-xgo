package com.sandboxol.blockymods.view.fragment.changedetail;

import android.app.Activity;
import android.content.Context;

import com.sandboxol.blockymods.R;
import com.sandboxol.blockymods.config.EventConstant;
import com.sandboxol.blockymods.config.IntConstant;
import com.sandboxol.blockymods.config.MessageToken;
import com.sandboxol.blockymods.entity.AccountCenter;
import com.sandboxol.blockymods.entity.User;
import com.sandboxol.common.utils.HttpUtils;
import com.sandboxol.common.base.web.OnResponseListener;
import com.sandboxol.common.base.viewmodel.ViewModel;
import com.sandboxol.common.command.ReplyCommand;
import com.sandboxol.common.messenger.Messenger;
import com.sandboxol.common.utils.ToastUtils;
import com.tendcloud.tenddata.TCAgent;

/**
 * Created by Bob on 2017/10/23.
 */
public class ChangeDetailViewModel extends ViewModel {

    private Context context;

    private User user;

    public ReplyCommand<String> onGetTextCommand = new ReplyCommand<>(s -> {
        user.setDetails(s);
    });

    public ChangeDetailViewModel(Context context) {
        this.context = context;
        user = new User();
    }

    public void changeDetails() {
        new ChangeDetailModel(user).loadData(context, new OnResponseListener<User>() {

            @Override
            public void onSuccess(User data) {
                AccountCenter.newInstance().detail.set(data.getDetails());
                AccountCenter.putAccountInfo();
                ToastUtils.showShortToast(context, R.string.modify_success);
                TCAgent.onEvent(context, EventConstant.MORE_PERS_SUC);
                Messenger.getDefault().send(IntConstant.UPDATE_USER_INFO, MessageToken.TOKEN_ACCOUNT);
                ((Activity)context).finish();
            }

            @Override
            public void onError(int code, String msg) {
                ToastUtils.showShortToast(context, context.getString(R.string.connect_error_code, code));
            }

            @Override
            public void onServerError(int error) {
                ToastUtils.showShortToast(context, HttpUtils.getHttpErrorMsg(context, error));
            }
        });
    }
}
