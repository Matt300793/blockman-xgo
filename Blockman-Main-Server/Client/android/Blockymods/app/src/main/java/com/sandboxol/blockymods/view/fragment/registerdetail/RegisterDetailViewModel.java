package com.sandboxol.blockymods.view.fragment.registerdetail;

import android.content.Context;
import android.databinding.ObservableField;

import com.sandboxol.blockymods.R;
import com.sandboxol.blockymods.config.EventConstant;
import com.sandboxol.blockymods.config.IntConstant;
import com.sandboxol.blockymods.config.MessageToken;
import com.sandboxol.blockymods.entity.AccountCenter;
import com.sandboxol.blockymods.entity.User;
import com.sandboxol.blockymods.utils.IntentUtils;
import com.sandboxol.common.base.web.OnResponseListener;
import com.sandboxol.common.binding.adapter.RadioGroupBindingAdapters;
import com.sandboxol.common.base.viewmodel.ViewModel;
import com.sandboxol.common.command.ReplyCommand;
import com.sandboxol.common.messenger.Messenger;
import com.sandboxol.common.utils.HttpUtils;
import com.sandboxol.common.utils.ToastUtils;
import com.tendcloud.tenddata.TCAgent;

/**
 * Created by Bob on 2017/10/17.
 */
public class RegisterDetailViewModel extends ViewModel {

    private Context context;

    private int sex = 0;
    private User user;

    private RegisterDetailFragment fragment;

    public ObservableField<Boolean> isLoading = new ObservableField<>(false);
    public ReplyCommand onUploadCommand = new ReplyCommand(() -> fragment.uploadIconClick());
    public ReplyCommand onFinishClickCommand = new ReplyCommand(this::onFinishClick);
    public ReplyCommand<String> onNickNameTextCommand = new ReplyCommand<>(s -> user.setNickName(s));
    public ReplyCommand<RadioGroupBindingAdapters.CheckedDataWrapper> onCheckCommand = new ReplyCommand<>(checkedDataWrapper -> onCheck(checkedDataWrapper.getCheckedId()));

    public RegisterDetailViewModel(Context context, RegisterDetailFragment fragment) {
        this.context = context;
        this.fragment = fragment;
        user = new User();
    }

    private void onCheck(int checkedId) {
        switch (checkedId) {
            case R.id.rbMale:
                user.setSex(1);
                sex = 1;
                break;
            case R.id.rbFemale:
                user.setSex(2);
                sex = 2;
                break;
        }
    }

    private void onFinishClick() {
        if (user.getNickName() == null) {
            ToastUtils.showShortToast(context, R.string.account_nick_name_empty);
            return;
        }
        if (user.getNickName().length() < 6) {
            ToastUtils.showShortToast(context, R.string.account_nickname_less_6);
            return;
        }

        if (sex == 0) {
            ToastUtils.showShortToast(context, R.string.account_sex_empty);
            return;
        }

        if (fragment.getTmpKey() != null)
            uploadIcon();
        else
            userRegister();
    }

    private void uploadIcon() {
        isLoading.set(true);
        new RegisterDetailModel().uploadIcon(context, fragment.getTmpDir(), fragment.getTmpKey(), new OnResponseListener<String>() {
            @Override
            public void onSuccess(String data) {
                userRegister();
                user.setPicUrl(data);
                ToastUtils.showShortToast(context, "uploadSuccess");
                TCAgent.onEvent(context, EventConstant.MORE_HEAD_SUC);
            }

            @Override
            public void onError(int code, String msg) {
                ToastUtils.showShortToast(context, context.getString(R.string.connect_error_code, code));
                isLoading.set(false);
            }

            @Override
            public void onServerError(int error) {
                ToastUtils.showShortToast(context, context.getString(R.string.connect_error_code, error));
                isLoading.set(false);
            }
        });
    }

    private void userRegister() {

        new RegisterDetailModel().userRegister(context, user, new OnResponseListener<User>() {

            @Override
            public void onSuccess(User data) {
                isLoading.set(false);
                data.setAccessToken(AccountCenter.newInstance().token.get());
                ToastUtils.showShortToast(context, R.string.account_register_success);
                AccountCenter.updateAccount(data);
                Messenger.getDefault().send(IntConstant.ACCOUNT_REGISTER, MessageToken.TOKEN_ACCOUNT);
                Messenger.getDefault().send(IntConstant.REGISTER_SUCCESS, MessageToken.TOKEN_LOGIN_REGISTER_SUCCESS);
                Messenger.getDefault().send(IntConstant.REGISTER_SUCCESS_DIALOG, MessageToken.TOKEN_REGISTER_SUCCESS);
                IntentUtils.startMainActivity(context);
            }

            @Override
            public void onError(int code, String msg) {
                isLoading.set(false);
                switch (code) {
                    case 102:
                        ToastUtils.showShortToast(context, R.string.account_not_exist);
                        break;
                    case 1001:
                        ToastUtils.showShortToast(context, R.string.account_not_exist);
                        if (fragment != null)
                            fragment.getActivity().finish();
                        break;
                    case 1003:
                        ToastUtils.showShortToast(context, R.string.account_nickname_exist);
                        break;
                    default:
                        ToastUtils.showShortToast(context, context.getString(R.string.connect_error_code, code));
                        break;
                }
            }

            @Override
            public void onServerError(int error) {
                isLoading.set(false);
                ToastUtils.showShortToast(context, HttpUtils.getHttpErrorMsg(context, error));
            }
        });
    }
}
