package com.sandboxol.blockymods.view.fragment.category;

import com.sandboxol.blockymods.R;
import com.sandboxol.blockymods.databinding.FragmentCategoryBinding;
import com.sandboxol.common.base.app.BaseFragment;

/**
 * Created by Bob on 2017/11/3.
 */
public class CategoryFragment extends BaseFragment<CategoryViewModel, FragmentCategoryBinding> {

    @Override
    protected int getLayoutId() {
        return R.layout.fragment_category;
    }

    @Override
    protected CategoryViewModel getViewModel() {
        return new CategoryViewModel(context);
    }

    @Override
    protected void bindViewModel(FragmentCategoryBinding binding, CategoryViewModel viewModel) {
        viewModel.setLlCategory(binding.llCategory);
        binding.setCategoryViewModel(viewModel);
    }
}
