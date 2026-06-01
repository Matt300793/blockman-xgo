package com.sandboxol.blockymods.view.fragment.email;

import android.app.Activity;
import android.content.Context;

import com.sandboxol.blockymods.R;
import com.sandboxol.blockymods.config.StringConstant;
import com.sandboxol.blockymods.entity.AccountCenter;
import com.sandboxol.blockymods.entity.EmailBindForm;
import com.sandboxol.blockymods.view.fragment.bindemail.BindEmailModel;
import com.sandboxol.common.base.viewmodel.ViewModel;
import com.sandboxol.common.base.web.OnResponseListener;
import com.sandboxol.common.command.ReplyCommand;
import com.sandboxol.common.utils.ToastUtils;

/**
 * Created by Bob on 2017/11/22.
 */
public class EmailViewModel extends ViewModel {

    private Context context;
    public ReplyCommand onUnbindingCommand = new ReplyCommand(this::clickUnBind);

    public EmailViewModel(Context context) {
        this.context = context;
    }

    /**
     * 解绑邮箱
     */
    private void clickUnBind() {

        new BindEmailModel().bindEmail(context, StringConstant.UNBIND_EMAIL, null, new OnResponseListener() {
            @Override
            public void onSuccess(Object data) {
                ToastUtils.showShortToast(context, R.string.bind_phone_unbind_success);
                AccountCenter.newInstance().email.set("");
                AccountCenter.putAccountInfo();
                ((Activity) context).finish();
            }

            @Override
            public void onError(int code, String msg) {
                if (code == 115)
                    ToastUtils.showShortToast(context, R.string.bind_email_never_bind_email);
                else
                    ToastUtils.showShortToast(context, context.getString(R.string.connect_error_code, code));
            }

            @Override
            public void onServerError(int error) {
                ToastUtils.showShortToast(context, context.getString(R.string.connect_error_code, error));
            }
        });
    }

}
