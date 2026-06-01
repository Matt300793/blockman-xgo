package com.sandboxol.blockymods.view.fragment.help;

import com.sandboxol.blockymods.R;
import com.sandboxol.blockymods.databinding.FragmentHelpBinding;
import com.sandboxol.common.base.app.BaseFragment;
import com.sandboxol.common.base.app.TemplateFragment;

/**
 * Created by Bob on 2017/10/14.
 */
public class HelpFragment extends TemplateFragment<HelpViewModel, FragmentHelpBinding> {

    @Override
    protected int getLayoutId() {
        return R.layout.fragment_help;
    }

    @Override
    protected HelpViewModel getViewModel() {
        return new HelpViewModel();
    }

    @Override
    protected void bindViewModel(FragmentHelpBinding binding, HelpViewModel viewModel) {
        binding.setHelpViewModel(viewModel);
    }

}
