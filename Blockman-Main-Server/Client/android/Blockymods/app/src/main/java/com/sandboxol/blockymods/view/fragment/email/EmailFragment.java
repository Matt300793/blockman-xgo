package com.sandboxol.blockymods.view.fragment.email;


import com.sandboxol.blockymods.R;
import com.sandboxol.blockymods.databinding.FragmentEmailBinding;
import com.sandboxol.common.base.app.TemplateFragment;

/**
 * Created by Bob on 2017/11/22.
 */
public class EmailFragment extends TemplateFragment<EmailViewModel, FragmentEmailBinding> {

    @Override
    protected int getLayoutId() {
        return R.layout.fragment_email;
    }

    @Override
    protected EmailViewModel getViewModel() {
        return new EmailViewModel(context);
    }

    @Override
    protected void bindViewModel(FragmentEmailBinding binding, EmailViewModel viewModel) {
        binding.setEmailViewModel(viewModel);
    }
}
