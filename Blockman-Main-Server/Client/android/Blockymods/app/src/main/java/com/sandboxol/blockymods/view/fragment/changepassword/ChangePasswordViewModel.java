package com.sandboxol.blockymods.view.fragment.changepassword;

import android.app.Activity;
import android.content.Context;

import com.sandboxol.blockymods.R;
import com.sandboxol.blockymods.config.EventConstant;
import com.sandboxol.blockymods.entity.ChangePasswordForm;
import com.sandboxol.common.utils.HttpUtils;
import com.sandboxol.common.base.web.OnResponseListener;
import com.sandboxol.common.base.viewmodel.ViewModel;
import com.sandboxol.common.command.ReplyCommand;
import com.sandboxol.common.utils.ToastUtils;
import com.tendcloud.tenddata.TCAgent;

/**
 * Created by Bob on 2017/10/23.
 */
public class ChangePasswordViewModel extends ViewModel {

    private Context context;

    public ChangePasswordForm form;

    public ReplyCommand<String> onGetOriginalPasswordCommand = new ReplyCommand<>(s -> form.setOldPassword(s));
    public ReplyCommand<String> onGetNewPasswordCommand = new ReplyCommand<>(s -> form.setNewPassword(s));
    public ReplyCommand<String> onGetConfirmPasswordCommand = new ReplyCommand<>(s -> form.setConfirmPassword(s));

    public ChangePasswordViewModel(Context context) {
        this.context = context;
        form = new ChangePasswordForm();
    }

    void changePassword() {

        if (form.getOldPassword() == null) {
            ToastUtils.showShortToast(context, R.string.change_password_old_empty);
            return;
        }

        if (form.getNewPassword() == null) {
            ToastUtils.showShortToast(context, R.string.change_password_new_empty);
            return;
        }

        if (form.getOldPassword().length() < 6 ||form.getNewPassword().length() < 6) {
            ToastUtils.showShortToast(context, R.string.account_password_less_6);
            return;
        }

        if (!form.getNewPassword().equals(form.getConfirmPassword())) {
            ToastUtils.showShortToast(context, R.string.account_password_not_compare);
            return;
        }

        new ChangePasswordModel(form).loadData(context, new OnResponseListener() {

            @Override
            public void onSuccess(Object data) {
                ToastUtils.showShortToast(context, R.string.change_password_success);
                TCAgent.onEvent(context, EventConstant.MORE_CHPASS_SUC);
                ((Activity)context).finish();
            }

            @Override
            public void onError(int code, String msg) {
                if (code == 108)
                    ToastUtils.showShortToast(context, R.string.change_password_wrong);
                else
                    ToastUtils.showShortToast(context, context.getString(R.string.connect_error_code, code));
            }

            @Override
            public void onServerError(int error) {
                ToastUtils.showShortToast(context, HttpUtils.getHttpErrorMsg(context, error));
            }
        });
    }
}
