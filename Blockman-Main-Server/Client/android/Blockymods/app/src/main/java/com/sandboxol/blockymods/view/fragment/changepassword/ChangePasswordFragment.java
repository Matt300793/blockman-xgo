package com.sandboxol.blockymods.view.fragment.changepassword;

import android.view.View;

import com.sandboxol.blockymods.R;
import com.sandboxol.blockymods.databinding.FragmentChangePasswordBinding;
import com.sandboxol.common.base.app.TemplateFragment;

/**
 * Created by Bob on 2017/10/23.
 */
public class ChangePasswordFragment extends TemplateFragment<ChangePasswordViewModel, FragmentChangePasswordBinding> {

    @Override
    protected int getLayoutId() {
        return R.layout.fragment_change_password;
    }

    @Override
    protected ChangePasswordViewModel getViewModel() {
        return new ChangePasswordViewModel(context);
    }

    @Override
    protected void bindViewModel(FragmentChangePasswordBinding binding, ChangePasswordViewModel viewModel) {
        binding.setChangePasswordViewModel(viewModel);
    }

    @Override
    public void onRightButtonClick(View v) {
        super.onRightButtonClick(v);
        viewModel.changePassword();
    }
}
