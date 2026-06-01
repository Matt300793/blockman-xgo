package com.sandboxol.blockymods.view.fragment.register;

import android.view.animation.Animation;

import com.sandboxol.blockymods.R;
import com.sandboxol.blockymods.anim.AccountPageAnimation;
import com.sandboxol.blockymods.config.IntConstant;
import com.sandboxol.blockymods.databinding.FragmentRegisterBinding;
import com.sandboxol.common.base.app.TemplateFragment;

/**
 * Created by Bob on 2017/10/17.
 */
public class RegisterFragment extends TemplateFragment<RegisterViewModel, FragmentRegisterBinding> {

    @Override
    protected int getLayoutId() {
        return R.layout.fragment_register;
    }

    @Override
    protected RegisterViewModel getViewModel() {
        return new RegisterViewModel(context);
    }

    @Override
    protected void bindViewModel(FragmentRegisterBinding binding, RegisterViewModel viewModel) {
        binding.setRegisterViewModel(viewModel);
    }

    @Override
    public Animation onCreateAnimation(int transit, boolean enter, int nextAnim) {
        return new AccountPageAnimation(enter, IntConstant.CHANGE_ACCOUNT_REGISTER);
    }
}
