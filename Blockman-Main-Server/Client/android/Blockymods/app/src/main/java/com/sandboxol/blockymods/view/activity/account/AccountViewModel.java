package com.sandboxol.blockymods.view.activity.account;

import android.support.v4.app.FragmentTransaction;

import com.sandboxol.blockymods.R;
import com.sandboxol.blockymods.config.IntConstant;
import com.sandboxol.blockymods.config.MessageToken;
import com.sandboxol.blockymods.utils.IntentUtils;
import com.sandboxol.blockymods.view.fragment.login.LoginFragment;
import com.sandboxol.blockymods.view.fragment.register.RegisterFragment;
import com.sandboxol.blockymods.view.fragment.registerdetail.RegisterDetailFragment;
import com.sandboxol.common.base.app.BaseFragment;
import com.sandboxol.common.base.viewmodel.ViewModel;
import com.sandboxol.common.command.ReplyCommand;
import com.sandboxol.common.messenger.Messenger;

/**
 * Created by Bob on 2017/10/18.
 */
public class AccountViewModel extends ViewModel {

    public static int nextPageIndex = 0;
    public static int currPageIndex = 0;

    private AccountActivity activity;
    private boolean isInit = false;

    public ReplyCommand onLeftClickCommand = new ReplyCommand(() -> IntentUtils.startMainActivity(activity));

    private LoginFragment loginFragment;
    private RegisterFragment registerFragment;
    private RegisterDetailFragment registerDetailFragment;

    public AccountViewModel(AccountActivity activity, String type) {
        this.activity = activity;
        initMessenger();
        initFragments(type);
    }

    private void initMessenger() {
        Messenger.getDefault().register(this, MessageToken.TOKEN_CHANGE_LOGIN_OR_REGISTER, Integer.class, type -> {
            nextPageIndex = type;
            if (type == IntConstant.CHANGE_ACCOUNT_LOGIN) {
                replaceFragment(loginFragment);
            } else if (type == IntConstant.CHANGE_ACCOUNT_REGISTER) {
                replaceFragment(registerFragment);
            } else
                replaceFragment(registerDetailFragment);
        });
    }

    private void initFragments(String type) {
        if (!isInit) {
            isInit = true;
            loginFragment = new LoginFragment();
            registerFragment = new RegisterFragment();
            registerDetailFragment = new RegisterDetailFragment();
            if (type == null) {
                replaceFragment(loginFragment);
                nextPageIndex = IntConstant.CHANGE_ACCOUNT_LOGIN;
            } else {
                replaceFragment(registerFragment);
                nextPageIndex = IntConstant.CHANGE_ACCOUNT_REGISTER;
            }
            currPageIndex = nextPageIndex;
        }
    }

    private void replaceFragment(BaseFragment fragment) {
        FragmentTransaction ft = activity.getSupportFragmentManager().beginTransaction();
        ft.setTransition(FragmentTransaction.TRANSIT_NONE);
        ft.replace(R.id.flAccount, fragment);
        ft.commitAllowingStateLoss();
    }

    @Override
    public void onDestroy() {
        super.onDestroy();
        Messenger.getDefault().unregister(this);
    }
}
