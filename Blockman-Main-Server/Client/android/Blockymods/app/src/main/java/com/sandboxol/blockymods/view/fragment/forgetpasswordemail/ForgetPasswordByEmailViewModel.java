package com.sandboxol.blockymods.view.fragment.forgetpasswordemail;

import android.content.Context;
import android.databinding.ObservableField;

import com.sandboxol.blockymods.R;
import com.sandboxol.common.base.viewmodel.ViewModel;
import com.sandboxol.common.base.web.OnResponseListener;
import com.sandboxol.common.command.ReplyCommand;
import com.sandboxol.common.utils.HttpUtils;
import com.sandboxol.common.utils.ToastUtils;

/**
 * Created by Bob on 2017/11/23.
 */
public class ForgetPasswordByEmailViewModel extends ViewModel {

    private Context context;
    private String email;
    public ObservableField<Boolean> enable = new ObservableField<>(true);
    public ReplyCommand onResetClickCommand = new ReplyCommand(this::onReset);
    public ReplyCommand<String> onGetEmailTextCommand = new ReplyCommand<>(s -> email = s);

    public ForgetPasswordByEmailViewModel(Context context) {
        this.context = context;
    }

    /**
     * 邮箱重置密码
     */
    private void onReset() {

        if (email == null) {
            ToastUtils.showShortToast(context, R.string.change_password_email_empty);
            return;
        }
        enable.set(false);

        new ForgetPasswordByEmailModel().forgetPassword(context, email, new OnResponseListener() {
            @Override
            public void onSuccess(Object data) {
                ToastUtils.showShortToast(context, R.string.change_password_email_success);
                enable.set(true);
            }

            @Override
            public void onError(int code, String msg) {
                if (code == 116)
                    ToastUtils.showShortToast(context, R.string.change_password_email_not_bind);
                else
                    ToastUtils.showShortToast(context, context.getString(R.string.connect_error_code, code));
                enable.set(true);
            }

            @Override
            public void onServerError(int error) {
                ToastUtils.showShortToast(context, HttpUtils.getHttpErrorMsg(context, error));
                enable.set(true);
            }
        });
    }

}
