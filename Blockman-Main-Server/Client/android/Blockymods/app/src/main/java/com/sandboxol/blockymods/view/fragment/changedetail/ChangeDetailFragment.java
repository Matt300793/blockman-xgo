package com.sandboxol.blockymods.view.fragment.changedetail;

import android.view.View;

import com.sandboxol.blockymods.R;
import com.sandboxol.blockymods.databinding.FragmentChangeDetailBinding;
import com.sandboxol.common.base.app.TemplateFragment;
import com.sandboxol.common.utils.ToastUtils;

/**
 * Created by Bob on 2017/10/23.
 */
public class ChangeDetailFragment extends TemplateFragment<ChangeDetailViewModel, FragmentChangeDetailBinding> {

    @Override
    protected int getLayoutId() {
        return R.layout.fragment_change_detail;
    }

    @Override
    protected ChangeDetailViewModel getViewModel() {
        return new ChangeDetailViewModel(context);
    }

    @Override
    protected void bindViewModel(FragmentChangeDetailBinding binding, ChangeDetailViewModel viewModel) {
        binding.setChangeDetailViewModel(viewModel);
    }

    @Override
    public void onRightButtonClick(View v) {
        super.onRightButtonClick(v);
        viewModel.changeDetails();
    }
}
