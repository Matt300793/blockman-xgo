package com.sandboxol.blockymods.view.fragment.bindemail;

import android.app.Activity;
import android.content.Context;
import android.databinding.ObservableField;

import com.sandboxol.blockymods.R;
import com.sandboxol.blockymods.config.EventConstant;
import com.sandboxol.blockymods.config.StringConstant;
import com.sandboxol.blockymods.entity.AccountCenter;
import com.sandboxol.blockymods.entity.EmailBindForm;
import com.sandboxol.common.base.viewmodel.ViewModel;
import com.sandboxol.common.base.web.OnResponseListener;
import com.sandboxol.common.command.ReplyCommand;
import com.sandboxol.common.utils.CommonHelper;
import com.sandboxol.common.utils.HttpUtils;
import com.sandboxol.common.utils.ToastUtils;
import com.tendcloud.tenddata.TCAgent;

/**
 * Created by Bob on 2017/11/14.
 */
public class BindEmailViewModel extends ViewModel {

    private Context context;

    private EmailBindForm form;

    public BindEmailViewModel(Context context) {
        this.context = context;
        form = new EmailBindForm();
    }

    public ObservableField<Boolean> isSend = new ObservableField<>(true);
    public ObservableField<Boolean> enable = new ObservableField<>(true);

    public ReplyCommand onBindCommand = new ReplyCommand(this::onBind);
    public ReplyCommand onSendCodeCommand = new ReplyCommand(this::onSendCode);
    public ReplyCommand<String> onGetEmailTextCommand = new ReplyCommand<>(s -> form.setEmail(s));
    public ReplyCommand<String> onGetCodeCommand = new ReplyCommand<>(s -> form.setVerifyCode(s));

    /**
     * 发送邮箱验证码
     */
    private void onSendCode(){
        if (form.getEmail() == null){
            ToastUtils.showShortToast(context, R.string.account_email_is_empty);
            return;
        }
        if (!CommonHelper.isEmail(form.getEmail())) {
            return;
        }
        enable.set(false);
        new BindEmailModel().sendCode(context, form.getEmail(), new OnResponseListener() {
            @Override
            public void onSuccess(Object data) {
                isSend.set(false);
                ToastUtils.showShortToast(context, R.string.bind_phone_code_send_success);
                enable.set(true);
            }

            @Override
            public void onError(int code, String msg) {
                switch (code) {
                    case 111:
                        ToastUtils.showShortToast(context, R.string.bind_email_pattern_error);
                        break;
                    case 112:
                        ToastUtils.showShortToast(context, R.string.bind_email_not_exist);
                        break;
                    case 113:
                        ToastUtils.showShortToast(context, R.string.bind_email_has_bind);
                        break;
                    default:
                        ToastUtils.showShortToast(context, context.getString(R.string.connect_error_code, code));
                        break;
                }
                enable.set(true);
            }

            @Override
            public void onServerError(int error) {
                ToastUtils.showShortToast(context, HttpUtils.getHttpErrorMsg(context, error));
                enable.set(true);
            }
        });
    }

    /**
     * 绑定
     */
    private void onBind() {
        if (form.getVerifyCode() == null){
            ToastUtils.showShortToast(context, R.string.bind_phone_code_is_empty);
            return;
        }
        new BindEmailModel().bindEmail(context, StringConstant.EMAIL_BIND, form, new OnResponseListener() {
            @Override
            public void onSuccess(Object data) {
                ToastUtils.showShortToast(context, R.string.bind_phone_bind_success);
                TCAgent.onEvent(context, EventConstant.MORE_EMAIL_SUC);
                AccountCenter.newInstance().email.set(form.getEmail());
                AccountCenter.putAccountInfo();
                ((Activity) context).finish();
            }

            @Override
            public void onError(int code, String msg) {
                switch (code) {
                    case 107:
                        ToastUtils.showShortToast(context, R.string.bind_phone_code_error);
                        break;
                    case 113:
                        ToastUtils.showShortToast(context, R.string.bind_email_has_bind);
                        break;
                    case 114:
                        ToastUtils.showShortToast(context, R.string.bind_email_user_has_bind);
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
}
