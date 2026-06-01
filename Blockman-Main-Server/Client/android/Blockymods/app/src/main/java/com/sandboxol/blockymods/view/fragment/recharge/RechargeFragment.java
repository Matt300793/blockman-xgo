package com.sandboxol.blockymods.view.fragment.recharge;

import com.sandboxol.blockymods.R;
import com.sandboxol.blockymods.databinding.FragmentRechargeBinding;
import com.sandboxol.common.base.app.TemplateFragment;

/**
 * Created by Bob on 2017/10/14.
 */
public class RechargeFragment extends TemplateFragment<RechargeViewModel, FragmentRechargeBinding> {

    @Override
    protected int getLayoutId() {
        return R.layout.fragment_recharge;
    }

    @Override
    protected RechargeViewModel getViewModel() {
        return new RechargeViewModel();
    }

    @Override
    protected void bindViewModel(FragmentRechargeBinding binding, RechargeViewModel viewModel) {
        binding.setRechargeViewModel(viewModel);
    }

}
