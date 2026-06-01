package com.sandboxol.blockymods.view.fragment.about;

import com.sandboxol.blockymods.R;
import com.sandboxol.blockymods.databinding.FragmentAboutBinding;
import com.sandboxol.common.base.app.TemplateFragment;

/**
 * Created by Bob on 2017/10/23.
 */
public class AboutFragment extends TemplateFragment<AboutViewModel, FragmentAboutBinding> {

    @Override
    protected int getLayoutId() {
        return R.layout.fragment_about;
    }

    @Override
    protected AboutViewModel getViewModel() {
        return new AboutViewModel(context);
    }

    @Override
    protected void bindViewModel(FragmentAboutBinding binding, AboutViewModel viewModel) {
        binding.setAboutViewModel(viewModel);
    }

}
