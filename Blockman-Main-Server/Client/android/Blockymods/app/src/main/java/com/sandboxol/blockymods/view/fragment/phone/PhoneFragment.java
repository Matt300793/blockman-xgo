package com.sandboxol.blockymods.view.fragment.phone;

import com.sandboxol.blockymods.R;
import com.sandboxol.blockymods.databinding.FragmentPhoneBinding;
import com.sandboxol.common.base.app.TemplateFragment;

/**
 * Created by Bob on 2017/10/27.
 */
public class PhoneFragment extends TemplateFragment<PhoneViewModel, FragmentPhoneBinding> {

    @Override
    protected int getLayoutId() {
        return R.layout.fragment_phone;
    }

    @Override
    protected PhoneViewModel getViewModel() {
        return new PhoneViewModel(context);
    }

    @Override
    protected void bindViewModel(FragmentPhoneBinding binding, PhoneViewModel viewModel) {
        binding.setPhoneViewModel(viewModel);
    }

}
