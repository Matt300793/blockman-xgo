package com.sandboxol.blockymods.view.fragment.login;

import android.app.Activity;
import android.content.Context;
import android.databinding.ObservableField;

import com.google.gson.Gson;
import com.sandboxol.blockymods.ChannelController;
import com.sandboxol.blockymods.R;
import com.sandboxol.blockymods.config.EventConstant;
import com.sandboxol.blockymods.config.IntConstant;
import com.sandboxol.blockymods.config.MessageToken;
import com.sandboxol.blockymods.config.SharedConstant;
import com.sandboxol.blockymods.config.StringConstant;
import com.sandboxol.blockymods.entity.AccountCenter;
import com.sandboxol.blockymods.entity.LoginRegisterAccountForm;
import com.sandboxol.blockymods.entity.User;
import com.sandboxol.blockymods.interfaces.ILoginListener;
import com.sandboxol.blockymods.utils.IntentUtils;
import com.sandboxol.blockymods.view.fragment.forgetpasswordemail.ForgetPasswordByEmailFragment;
import com.sandboxol.common.base.viewmodel.ViewModel;
import com.sandboxol.common.base.web.OnResponseListener;
import com.sandboxol.common.command.ReplyCommand;
import com.sandboxol.common.messenger.Messenger;
import com.sandboxol.common.utils.HttpUtils;
import com.sandboxol.common.utils.SharedUtils;
import com.sandboxol.common.utils.TemplateUtils;
import com.sandboxol.common.utils.ToastUtils;
import com.tendcloud.tenddata.TCAgent;

/**
 * Created by Bob on 2017/10/16.
 */
public class LoginViewModel extends ViewModel implements ILoginListener {

    private Context context;
    private LoginRegisterAccountForm form;

    public ObservableField<String> accountDefault = new ObservableField<>();
    public ObservableField<String> passwordDefault = new ObservableField<>();
    public ObservableField<Boolean> isShowThirdPart = new ObservableField<>(false);

    public ReplyCommand onLoginCommand = new ReplyCommand(this::onLoginClick);
    public ReplyCommand onRegisterCommand = new ReplyCommand(this::onRegisterClick);
    public ReplyCommand onFBLoginCommand = new ReplyCommand(this::onFBLoginClick);
    public ReplyCommand onForgetCommand = new ReplyCommand(() -> TemplateUtils.startTemplate(context, ForgetPasswordByEmailFragment.class, context.getString(R.string.item_view_forget_password)));
    public ReplyCommand<String> onAccountCommand = new ReplyCommand<>(s -> form.setUid(s));
    public ReplyCommand<String> onPasswordCommand = new ReplyCommand<>(s -> form.setPassword(s));

    public LoginViewModel(Context context) {
        this.context = context;
        form = new LoginRegisterAccountForm();
        initAccount();
        isShowThirdPart.set(SharedUtils.getBoolean(context, SharedConstant.APP_CONFIG_SHOW_THIRD_PART_LOGIN));
    }

    private void initAccount() {
        String accountNum = SharedUtils.getString(context, SharedConstant.SAVE_ACCOUNT_NUM);
        String password = SharedUtils.getString(context, SharedConstant.SAVE_PASSWORD);
        if (accountNum != null && !"".equals(accountNum)) {
            accountDefault.set(accountNum);
            form.setUid(accountNum);
        }
        if (password != null && !"".equals(password)) {
            passwordDefault.set(password);
            form.setPassword(password);
        }
    }

    private void onRegisterClick() {
        Messenger.getDefault().send(IntConstant.CHANGE_ACCOUNT_REGISTER, MessageToken.TOKEN_CHANGE_LOGIN_OR_REGISTER);
        TCAgent.onEvent(context, EventConstant.LOGINPAGE_REG);
    }

    private void onLoginClick() {
        login();
        TCAgent.onEvent(context, EventConstant.CLICK_LOGIN);
    }

    /**
     * 登录请求
     */
    private void login() {

        if (form.getUid() == null) {
            ToastUtils.showShortToast(context, R.string.account_account_empty);
            return;
        }

        new LoginModel(form).loadData(context, new OnResponseListener<User>() {
            @Override
            public void onSuccess(User data) {
                if (form.getPlatform() == null) {
                    SharedUtils.putString(context, SharedConstant.SAVE_ACCOUNT_NUM, form.getUid());
                    SharedUtils.putString(context, SharedConstant.SAVE_PASSWORD, form.getPassword());
                } else {
                    TCAgent.onEvent(context, EventConstant.ACCOUNT_LOGIN_SUC);
                }
                AccountCenter.updateAccount(data);
                ToastUtils.showShortToast(context, R.string.account_login_success);
                Messenger.getDefault().send(IntConstant.ACCOUNT_LOGIN, MessageToken.TOKEN_ACCOUNT);
                Messenger.getDefault().send(IntConstant.LOGIN_SUCCESS, MessageToken.TOKEN_LOGIN_REGISTER_SUCCESS);
                IntentUtils.startMainActivity(context);
            }

            @Override
            public void onError(int code, String msg) {
                switch (code) {
                    case 102:
                        ToastUtils.showShortToast(context, R.string.account_not_exist);
                        break;
                    case 108:
                        ToastUtils.showShortToast(context, R.string.change_password_wrong);
                        break;
                    case 1002:
                        User data = new Gson().fromJson(msg, User.class);
                        AccountCenter.newInstance().userId.set(data.getUserId());
                        AccountCenter.newInstance().token.set(data.getAccessToken());
                        Messenger.getDefault().send(IntConstant.CHANGE_ACCOUNT_REGISTER_DETAIL, MessageToken.TOKEN_CHANGE_LOGIN_OR_REGISTER);
                        break;
                    default:
                        ToastUtils.showShortToast(context, context.getString(R.string.connect_error_code, code));
                        break;
                }
                TCAgent.onEvent(context, EventConstant.LOGIN_FAILED, msg);
            }

            @Override
            public void onServerError(int error) {
                ToastUtils.showShortToast(context, HttpUtils.getHttpErrorMsg(context, error));
            }
        });
    }

    /**
     * facebook登录
     */
    private void onFBLoginClick() {
        ChannelController.newInstance().facebookLogin(context, this);
        TCAgent.onEvent(context, EventConstant.THIRD_FACEBOOK);
    }

    @Override
    public void loginSuccessful(String userId, String userName, String token, String loginType) {
        loginSuccessful(userId, userName, "", token, loginType);
    }

    @Override
    public void loginSuccessful(String userId, String userName, String picUrl, String token, String loginType) {
        form.setUid(userId);
        form.setPassword(token);
        form.setPlatform(loginType);
        login();
    }

    @Override
    public void loginFailure() {
        ToastUtils.showShortToast(context, R.string.account_register_failed);
    }
}
