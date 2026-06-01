package com.sandboxol.blockymods.view.fragment.bindphone;

import com.sandboxol.blockymods.R;
import com.sandboxol.blockymods.databinding.FragmentBindPhoneBinding;
import com.sandboxol.common.base.app.TemplateFragment;

/**
 * Created by Bob on 2017/10/23.
 */
public class BindPhoneFragment extends TemplateFragment<BindPhoneViewModel, FragmentBindPhoneBinding> {

    @Override
    protected int getLayoutId() {
        return R.layout.fragment_bind_phone;
    }

    @Override
    protected BindPhoneViewModel getViewModel() {
        return new BindPhoneViewModel(context);
    }

    @Override
    protected void bindViewModel(FragmentBindPhoneBinding binding, BindPhoneViewModel viewModel) {
        binding.setBindPhoneViewModel(viewModel);
    }

}
