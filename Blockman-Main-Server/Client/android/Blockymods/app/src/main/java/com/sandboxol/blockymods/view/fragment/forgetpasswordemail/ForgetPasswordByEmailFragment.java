package com.sandboxol.blockymods.view.fragment.forgetpasswordemail;

import com.sandboxol.blockymods.R;
import com.sandboxol.blockymods.databinding.FragmentForgetPasswordByEmailBinding;
import com.sandboxol.common.base.app.TemplateFragment;

/**
 * Created by Bob on 2017/11/23.
 */
public class ForgetPasswordByEmailFragment extends TemplateFragment<ForgetPasswordByEmailViewModel, FragmentForgetPasswordByEmailBinding> {

    @Override
    protected int getLayoutId() {
        return R.layout.fragment_forget_password_by_email;
    }

    @Override
    protected ForgetPasswordByEmailViewModel getViewModel() {
        return new ForgetPasswordByEmailViewModel(context);
    }

    @Override
    protected void bindViewModel(FragmentForgetPasswordByEmailBinding binding, ForgetPasswordByEmailViewModel viewModel) {
        binding.setForgetPasswordByEmailViewModel(viewModel);
    }
}
