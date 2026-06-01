package com.sandboxol.blockymods.view.fragment.bindemail;

import com.sandboxol.blockymods.R;
import com.sandboxol.blockymods.databinding.FragmentBindEmailBinding;
import com.sandboxol.common.base.app.TemplateFragment;

/**
 * Created by Bob on 2017/11/14.
 */
public class BindEmailFragment extends TemplateFragment<BindEmailViewModel, FragmentBindEmailBinding> {

    @Override
    protected int getLayoutId() {
        return R.layout.fragment_bind_email;
    }

    @Override
    protected BindEmailViewModel getViewModel() {
        return new BindEmailViewModel(context);
    }

    @Override
    protected void bindViewModel(FragmentBindEmailBinding binding, BindEmailViewModel viewModel) {
        binding.setBindEmailViewModel(viewModel);
    }
}
