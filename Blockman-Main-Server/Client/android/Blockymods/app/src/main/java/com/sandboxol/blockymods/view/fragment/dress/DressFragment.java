package com.sandboxol.blockymods.view.fragment.dress;

import android.view.animation.Animation;

import com.sandboxol.blockymods.R;
import com.sandboxol.blockymods.anim.MainPageAnimation;
import com.sandboxol.blockymods.databinding.FragmentDressBinding;
import com.sandboxol.common.base.app.BaseFragment;

/**
 * Created by Jimmy on 2017/10/13 0013.
 */
public class DressFragment extends BaseFragment<DressViewModel, FragmentDressBinding> {

    public static final int INDEX = 1;

    @Override
    protected int getLayoutId() {
        return R.layout.fragment_dress;
    }

    @Override
    protected DressViewModel getViewModel() {
        return new DressViewModel(context);
    }

    @Override
    protected void bindViewModel(FragmentDressBinding binding, DressViewModel viewModel) {
        binding.setDressViewModel(viewModel);
    }

    @Override
    public Animation onCreateAnimation(int transit, boolean enter, int nextAnim) {
        return new MainPageAnimation(enter, INDEX);
    }

    @Override
    public void onDestroy() {
        super.onDestroy();
    }
}
