package com.sandboxol.blockymods.view.fragment.forgetpassword;

import com.sandboxol.blockymods.R;
import com.sandboxol.blockymods.databinding.FragmentForgetPasswordBinding;
import com.sandboxol.common.base.app.TemplateFragment;

/**
 * Created by Bob on 2017/11/14.
 */
public class ForgetPasswordFragment extends TemplateFragment<ForgetPasswordViewModel, FragmentForgetPasswordBinding> {

    @Override
    protected int getLayoutId() {
        return R.layout.fragment_forget_password;
    }

    @Override
    protected ForgetPasswordViewModel getViewModel() {
        return new ForgetPasswordViewModel(context);
    }

    @Override
    protected void bindViewModel(FragmentForgetPasswordBinding binding, ForgetPasswordViewModel viewModel) {
        binding.setForgetPasswordViewModel(viewModel);
    }
}
