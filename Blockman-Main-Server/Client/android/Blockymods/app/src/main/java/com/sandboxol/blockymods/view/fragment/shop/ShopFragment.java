package com.sandboxol.blockymods.view.fragment.shop;

import com.sandboxol.blockymods.R;
import com.sandboxol.blockymods.databinding.FragmentShopBinding;
import com.sandboxol.common.base.app.TemplateFragment;

/**
 * Created by Bob on 2017/10/14.
 */
public class ShopFragment extends TemplateFragment<ShopViewModel, FragmentShopBinding> {

    @Override
    protected int getLayoutId() {
        return R.layout.fragment_shop;
    }

    @Override
    protected ShopViewModel getViewModel() {
        return new ShopViewModel();
    }

    @Override
    protected void bindViewModel(FragmentShopBinding binding, ShopViewModel viewModel) {
        binding.setShopViewModel(viewModel);
    }

}
