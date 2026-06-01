package com.sandboxol.blockymods.view.fragment.setting;

import com.sandboxol.blockymods.R;
import com.sandboxol.blockymods.databinding.FragmentSettingBinding;
import com.sandboxol.common.base.app.TemplateFragment;

/**
 * Created by Bob on 2017/10/14.
 */
public class SettingFragment extends TemplateFragment<SettingViewModel, FragmentSettingBinding> {

    @Override
    protected int getLayoutId() {
        return R.layout.fragment_setting;
    }

    @Override
    protected SettingViewModel getViewModel() {
        return new SettingViewModel(context);
    }

    @Override
    protected void bindViewModel(FragmentSettingBinding binding, SettingViewModel viewModel) {
        binding.setSettingViewModel(viewModel);
    }

}
