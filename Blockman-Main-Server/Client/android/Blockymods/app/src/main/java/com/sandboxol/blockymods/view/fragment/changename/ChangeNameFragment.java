package com.sandboxol.blockymods.view.fragment.changename;

import android.view.View;

import com.sandboxol.blockymods.R;
import com.sandboxol.blockymods.databinding.FragmentChangeNameBinding;
import com.sandboxol.common.base.app.TemplateFragment;

/**
 * Created by Bob on 2017/10/20.
 */
public class ChangeNameFragment extends TemplateFragment<ChangeNameViewModel, FragmentChangeNameBinding> {

    @Override
    protected int getLayoutId() {
        return R.layout.fragment_change_name;
    }

    @Override
    protected ChangeNameViewModel getViewModel() {
        return new ChangeNameViewModel(context);
    }

    @Override
    protected void bindViewModel(FragmentChangeNameBinding binding, ChangeNameViewModel viewModel) {
        binding.setChangeNameViewModel(viewModel);
    }

    @Override
    public void onRightButtonClick(View v) {
        super.onRightButtonClick(v);
        viewModel.changeNickName();
    }
}
