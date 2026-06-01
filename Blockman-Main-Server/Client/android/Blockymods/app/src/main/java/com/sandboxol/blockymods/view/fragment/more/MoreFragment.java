package com.sandboxol.blockymods.view.fragment.more;

import android.view.animation.Animation;

import com.sandboxol.blockymods.R;
import com.sandboxol.blockymods.anim.MainPageAnimation;
import com.sandboxol.blockymods.databinding.FragmentMoreBinding;
import com.sandboxol.common.base.app.BaseFragment;

/**
 * Created by Jimmy on 2017/10/13 0013.
 */
public class MoreFragment extends BaseFragment<MoreViewModel, FragmentMoreBinding> {

    public static final int INDEX = 3;

    @Override
    protected int getLayoutId() {
        return R.layout.fragment_more;
    }

    @Override
    protected MoreViewModel getViewModel() {
        return new MoreViewModel(context);
    }

    @Override
    protected void bindViewModel(FragmentMoreBinding binding, MoreViewModel viewModel) {
        binding.setMoreViewModel(viewModel);
    }

    @Override
    public Animation onCreateAnimation(int transit, boolean enter, int nextAnim) {
        return new MainPageAnimation(enter, INDEX);
    }
}
