package com.sandboxol.blockymods.view.fragment.forgetpassword;

import android.app.Activity;
import android.content.Context;
import android.databinding.ObservableField;

import com.sandboxol.blockymods.R;
import com.sandboxol.blockymods.entity.PhoneBindForm;
import com.sandboxol.common.utils.HttpUtils;
import com.sandboxol.common.base.viewmodel.ViewModel;
import com.sandboxol.common.base.web.OnResponseListener;
import com.sandboxol.common.command.ReplyCommand;
import com.sandboxol.common.utils.ToastUtils;

/**
 * Created by Bob on 2017/11/14.
 */
public class ForgetPasswordViewModel extends ViewModel {

    private Context context;

    private PhoneBindForm form;

    public ReplyCommand<String> onGetPhoneNumCommand = new ReplyCommand<>(s -> form.setPhone(s));

    public ReplyCommand onGetCodeCommand = new ReplyCommand(this::retrieve);
    public ReplyCommand onVerificationCommand = new ReplyCommand(this::retrievePassword);
    public ReplyCommand<String> onGetVerifyCodeCommand = new ReplyCommand<>(s -> form.setVerifyCode(s));
    public ReplyCommand<String> onGetNewPasswordCommand = new ReplyCommand<>(s -> form.setPassword(s));
    public ReplyCommand<String> onGetConfirmPasswordCommand = new ReplyCommand<>(s -> form.setConfirmPassword(s));
    public ObservableField<Boolean> editTextFocus = new ObservableField<>(false);

    public ForgetPasswordViewModel(Context context) {
        this.context = context;
        form = new PhoneBindForm();
    }

    private void retrieve() {
        if (form.getPhone() == null) {
            ToastUtils.showShortToast(context, R.string.bind_phone_phone_hint);
            return;
        }
        editTextFocus.set(true);
        new ForgetPasswordModel().retrieve(context, form.getPhone(), new OnResponseListener() {
            @Override
            public void onSuccess(Object data) {
                ToastUtils.showShortToast(context, R.string.bind_phone_code_send_success);
            }

            @Override
            public void onError(int code, String msg) {
                switch (code) {
                    case 103:
                        ToastUtils.showShortToast(context, R.string.bind_phone_phone_has_been_bind);
                        break;
                    case 104:
                        ToastUtils.showShortToast(context, R.string.bind_phone_no_bind_phone);
                        break;
                    case 105:
                        ToastUtils.showShortToast(context, R.string.bind_phone_send_code_failed);
                        break;
                    case 106:
                        ToastUtils.showShortToast(context, R.string.bind_phone_user_has_bind);
                        break;
                    default:
                        ToastUtils.showShortToast(context, context.getString(R.string.connect_error_code, code));
                        break;
                }
            }

            @Override
            public void onServerError(int error) {
                ToastUtils.showShortToast(context, HttpUtils.getHttpErrorMsg(context, error));
            }
        });
    }

    /**
     * 发送验证码
     */
    private void retrievePassword() {
        if (form.getPhone() == null) {
            ToastUtils.showShortToast(context, R.string.bind_phone_phone_hint);
            return;
        }
        if ("".equals(form.getVerifyCode())) {
            ToastUtils.showShortToast(context, R.string.bind_phone_code_is_empty);
            return;
        }
        if (form.getPassword().length() < 6) {
            ToastUtils.showShortToast(context, R.string.account_password_less_6);
            return;
        }

        if (form.getConfirmPassword() == null) {
            ToastUtils.showShortToast(context, R.string.account_confirm_password_empty);
            return;
        }

        if (!form.getPassword().equals(form.getConfirmPassword())) {
            ToastUtils.showShortToast(context, R.string.account_password_not_compare);
            return;
        }

        new ForgetPasswordModel().retrievePassword(context, form, new OnResponseListener() {

            @Override
            public void onSuccess(Object data) {
                ToastUtils.showShortToast(context, R.string.modify_success);
                ((Activity)context).finish();
            }

            @Override
            public void onError(int code, String msg) {
                switch (code) {
                    case 104:
                        ToastUtils.showShortToast(context, R.string.bind_phone_no_bind_phone);
                        break;
                    case 107:
                        ToastUtils.showShortToast(context, R.string.bind_phone_code_error);
                        break;
                    default:
                        ToastUtils.showShortToast(context, context.getString(R.string.connect_error_code, code));
                        break;
                }
            }

            @Override
            public void onServerError(int error) {
                ToastUtils.showShortToast(context, context.getString(R.string.connect_error_code, error));
            }
        });
    }
}
