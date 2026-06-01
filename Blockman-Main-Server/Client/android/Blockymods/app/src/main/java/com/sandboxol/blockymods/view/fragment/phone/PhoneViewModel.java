package com.sandboxol.blockymods.view.fragment.phone;

import android.app.Activity;
import android.content.Context;

import com.sandboxol.blockymods.R;
import com.sandboxol.blockymods.config.StringConstant;
import com.sandboxol.blockymods.entity.AccountCenter;
import com.sandboxol.blockymods.entity.PhoneBindForm;
import com.sandboxol.blockymods.view.dialog.UnbindingPhoneDialog;
import com.sandboxol.blockymods.view.fragment.bindphone.BindPhoneModel;
import com.sandboxol.common.base.viewmodel.ViewModel;
import com.sandboxol.common.base.web.OnResponseListener;
import com.sandboxol.common.command.ReplyCommand;
import com.sandboxol.common.utils.ToastUtils;

/**
 * Created by Bob on 2017/10/27.
 */
public class PhoneViewModel extends ViewModel {

    private Context context;
    private String phoneNum;
    public ReplyCommand onUnbindingCommand = new ReplyCommand(this::clickUnBind);

    public PhoneViewModel(Context context) {
        this.context = context;
    }

    private void clickUnBind() {
        new UnbindingPhoneDialog(context,
                text -> phoneNum = text,
                v -> sendCode(),
                null,
                v -> unbindPhone()).show();
    }

    private void sendCode() {
        new BindPhoneModel().sendCode(context, AccountCenter.newInstance().telephone.get(), StringConstant.UNBIND_PHONE, new OnResponseListener() {
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

    private void unbindPhone() {
        PhoneBindForm form = new PhoneBindForm();
        form.setPhone(AccountCenter.newInstance().telephone.get());
        form.setVerifyCode(phoneNum);
        new BindPhoneModel().bindPhone(context, form, StringConstant.UNBIND_PHONE, new OnResponseListener() {
            @Override
            public void onSuccess(Object data) {
                ToastUtils.showShortToast(context, R.string.bind_phone_unbind_success);
                AccountCenter.newInstance().telephone.set("");
                AccountCenter.putAccountInfo();
                ((Activity) context).finish();
            }

            @Override
            public void onError(int code, String msg) {
                switch (code) {
                    case 109:
                        ToastUtils.showShortToast(context, R.string.bind_phone_unbind_error);
                        break;
                    case 110:
                        ToastUtils.showShortToast(context, R.string.bind_phone_never_bind_phone);
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
