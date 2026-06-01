package com.sandboxol.blockymods.view.fragment.reminder;

import com.sandboxol.blockymods.R;
import com.sandboxol.blockymods.databinding.FragmentReminderBinding;
import com.sandboxol.common.base.app.TemplateFragment;

/**
 * Created by Bob on 2017/10/23.
 */
public class ReminderFragment extends TemplateFragment<ReminderViewModel, FragmentReminderBinding> {

    @Override
    protected int getLayoutId() {
        return R.layout.fragment_reminder;
    }

    @Override
    protected ReminderViewModel getViewModel() {
        return new ReminderViewModel();
    }

    @Override
    protected void bindViewModel(FragmentReminderBinding binding, ReminderViewModel viewModel) {
        binding.setReminderViewModel(viewModel);
    }

}
