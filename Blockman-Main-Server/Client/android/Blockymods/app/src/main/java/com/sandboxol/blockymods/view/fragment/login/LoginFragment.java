package com.sandboxol.blockymods.view.fragment.login;

import android.view.animation.Animation;

import com.sandboxol.blockymods.R;
import com.sandboxol.blockymods.anim.AccountPageAnimation;
import com.sandboxol.blockymods.config.IntConstant;
import com.sandboxol.blockymods.databinding.FragmentLoginBinding;
import com.sandboxol.common.base.app.TemplateFragment;

/**
 * Created by Bob on 2017/10/16.
 */
public class LoginFragment extends TemplateFragment<LoginViewModel, FragmentLoginBinding> {

    private boolean isFirst = true;

    @Override
    protected int getLayoutId() {
        return R.layout.fragment_login;
    }

    @Override
    protected LoginViewModel getViewModel() {
        return new LoginViewModel(context);
    }

    @Override
    protected void bindViewModel(FragmentLoginBinding binding, LoginViewModel viewModel) {
        binding.setLoginViewModel(viewModel);
    }

    @Override
    public Animation onCreateAnimation(int transit, boolean enter, int nextAnim) {
        if (isFirst) {
            isFirst = false;
            return super.onCreateAnimation(transit, enter, nextAnim);
        } else {
            return new AccountPageAnimation(enter, IntConstant.CHANGE_ACCOUNT_LOGIN);
        }
    }
}
