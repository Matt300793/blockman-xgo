package com.sandboxol.blockymods.view.fragment.bindphone;

import android.app.Activity;
import android.content.Context;
import android.databinding.ObservableField;

import com.sandboxol.blockymods.R;
import com.sandboxol.blockymods.config.EventConstant;
import com.sandboxol.blockymods.config.StringConstant;
import com.sandboxol.blockymods.entity.AccountCenter;
import com.sandboxol.blockymods.entity.PhoneBindForm;
import com.sandboxol.common.utils.HttpUtils;
import com.sandboxol.common.base.web.OnResponseListener;
import com.sandboxol.common.base.viewmodel.ViewModel;
import com.sandboxol.common.command.ReplyCommand;
import com.sandboxol.common.utils.ToastUtils;
import com.tendcloud.tenddata.TCAgent;

/**
 * Created by Bob on 2017/10/23.
 */
public class BindPhoneViewModel extends ViewModel {

    private Context context;

    private PhoneBindForm form;

    public ReplyCommand onGetCodeCommand = new ReplyCommand(this::sendCode);

    public ReplyCommand onVerificationCommand = new ReplyCommand(this::bindPhone);

    public ReplyCommand<String> onGetPhoneNumCommand = new ReplyCommand<>(s -> form.setPhone(s));
    public ReplyCommand<String> onGetVerifyCodeCommand = new ReplyCommand<>(s -> form.setVerifyCode(s));
    public ObservableField<Boolean> editTextFocus = new ObservableField<>(false);

    public BindPhoneViewModel(Context context) {
        this.context = context;
        form = new PhoneBindForm();
    }

    private void sendCode() {
        if (form.getPhone() == null) {
            ToastUtils.showShortToast(context, R.string.bind_phone_phone_hint);
            return;
        }
        editTextFocus.set(true);
        new BindPhoneModel().sendCode(context, form.getPhone(), StringConstant.BIND_PHONE, new OnResponseListener() {
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
                ToastUtils.showShortToast(context, context.getString(R.string.connect_error_code, error));
            }
        });
    }

    private void bindPhone() {
        new BindPhoneModel().bindPhone(context, form, StringConstant.BIND_PHONE, new OnResponseListener() {
            @Override
            public void onSuccess(Object data) {
                ToastUtils.showShortToast(context, R.string.bind_phone_bind_success);
                TCAgent.onEvent(context, EventConstant.MORE_MOI_SUC);
                AccountCenter.newInstance().telephone.set(form.getPhone());
                AccountCenter.putAccountInfo();
                ((Activity) context).finish();
            }

            @Override
            public void onError(int code, String msg) {
                switch (code) {
                    case 102:
                        ToastUtils.showShortToast(context, R.string.account_not_exist);
                        break;
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
                ToastUtils.showShortToast(context, HttpUtils.getHttpErrorMsg(context, error));
            }
        });
    }
}
