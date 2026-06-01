package com.sandboxol.blockymods.view.fragment.register;

import android.content.Context;

import com.sandboxol.blockymods.R;
import com.sandboxol.blockymods.config.EventConstant;
import com.sandboxol.blockymods.config.IntConstant;
import com.sandboxol.blockymods.config.MessageToken;
import com.sandboxol.blockymods.config.SharedConstant;
import com.sandboxol.blockymods.entity.AccountCenter;
import com.sandboxol.blockymods.entity.LoginRegisterAccountForm;
import com.sandboxol.blockymods.entity.User;
import com.sandboxol.blockymods.utils.Helper;
import com.sandboxol.common.utils.HttpUtils;
import com.sandboxol.common.base.web.OnResponseListener;
import com.sandboxol.common.base.viewmodel.ViewModel;
import com.sandboxol.common.command.ReplyCommand;
import com.sandboxol.common.messenger.Messenger;
import com.sandboxol.common.utils.SharedUtils;
import com.sandboxol.common.utils.ToastUtils;
import com.tendcloud.tenddata.TCAgent;

/**
 * Created by Bob on 2017/10/17.
 */
public class RegisterViewModel extends ViewModel {

    private Context context;
    private LoginRegisterAccountForm form;

    public ReplyCommand onLoginCommand = new ReplyCommand(this::onLoginClick);
    public ReplyCommand onRegisterCommand = new ReplyCommand(this::onRegisterClick);

    public ReplyCommand<String> onAccountCommand = new ReplyCommand<>(s -> form.setUid(s));
    public ReplyCommand<String> onPasswordCommand = new ReplyCommand<>(s -> form.setPassword(s));
    public ReplyCommand<String> onConfirmPasswordCommand = new ReplyCommand<>(s -> form.setConfirmPassword(s));

    public RegisterViewModel(Context context) {
        this.context = context;
        form = new LoginRegisterAccountForm();
    }

    private void onLoginClick() {
        Messenger.getDefault().send(IntConstant.CHANGE_ACCOUNT_LOGIN, MessageToken.TOKEN_CHANGE_LOGIN_OR_REGISTER);
        TCAgent.onEvent(context, EventConstant.REGPAGE_LOGIN);
    }

    /**
     * 注册
     */
    private void onRegisterClick() {

        if (form == null)
            return;

        if (form.getUid() == null) {
            ToastUtils.showShortToast(context, R.string.account_account_empty);
            return;
        }

        if (form.getUid().length() < 4) {
            ToastUtils.showShortToast(context, R.string.account_account_less_4);
            return;
        }

        if (form.getPassword() == null) {
            ToastUtils.showShortToast(context, R.string.account_password_empty);
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

        try {
            Helper.getSystemInfo(context, form);
        } catch (Exception e) {
            e.printStackTrace();
        }

        new RegisterModel(form).loadData(context, new OnResponseListener<User>() {

            @Override
            public void onSuccess(User user) {
                updateAccount(user);

                SharedUtils.putString(context, SharedConstant.SAVE_ACCOUNT_NUM, form.getUid());
                SharedUtils.putString(context, SharedConstant.SAVE_PASSWORD, form.getPassword());

                Messenger.getDefault().send(IntConstant.CHANGE_ACCOUNT_REGISTER_DETAIL, MessageToken.TOKEN_CHANGE_LOGIN_OR_REGISTER);
            }

            @Override
            public void onError(int code, String msg) {
                if (code == 101)
                    ToastUtils.showShortToast(context, R.string.account_exist);
                else
                    ToastUtils.showShortToast(context, context.getString(R.string.connect_error_code, code));
            }

            @Override
            public void onServerError(int error) {
                ToastUtils.showShortToast(context, HttpUtils.getHttpErrorMsg(context, error));
            }
        });
    }

    /**
     * 注册账号时存储userId和token
     *
     * @param user
     */
    private void updateAccount(User user) {
        //注册账号是存储userId和token
        AccountCenter.newInstance().setUserId(user.getUserId());
        AccountCenter.newInstance().setToken(user.getAccessToken());
        AccountCenter.putAccountInfo();
    }
}
