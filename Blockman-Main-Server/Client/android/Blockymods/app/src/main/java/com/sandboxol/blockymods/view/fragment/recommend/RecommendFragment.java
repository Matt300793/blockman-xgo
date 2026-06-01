package com.sandboxol.blockymods.view.fragment.recommend;

import com.sandboxol.blockymods.R;
import com.sandboxol.blockymods.databinding.FragmentRecommendBinding;
import com.sandboxol.common.base.app.BaseFragment;

/**
 * Created by Jimmy on 2017/10/13 0013.
 */
public class RecommendFragment extends BaseFragment<RecommendViewModel, FragmentRecommendBinding> {

    @Override
    protected int getLayoutId() {
        return R.layout.fragment_recommend;
    }

    @Override
    protected RecommendViewModel getViewModel() {
        return new RecommendViewModel(context);
    }

    @Override
    protected void bindViewModel(FragmentRecommendBinding binding, RecommendViewModel viewModel) {
        binding.setRecommendViewModel(viewModel);
    }

}
