package com.sandboxol.blockymods.view.fragment.game;

import android.view.animation.Animation;

import com.sandboxol.blockymods.R;
import com.sandboxol.blockymods.anim.MainPageAnimation;
import com.sandboxol.blockymods.databinding.FragmentGameBinding;
import com.sandboxol.common.base.app.BaseFragment;

/**
 * Created by Bob on 2017/11/3.
 */
public class GameFragment extends BaseFragment<GameViewModel, FragmentGameBinding> {

    public static final int INDEX = 0;
    private boolean isFirst = true;

    @Override
    protected int getLayoutId() {
        return R.layout.fragment_game;
    }

    @Override
    protected GameViewModel getViewModel() {
        return new GameViewModel(context, this);
    }

    @Override
    protected void bindViewModel(FragmentGameBinding binding, GameViewModel viewModel) {
        binding.setGameViewModel(viewModel);
    }

    @Override
    public Animation onCreateAnimation(int transit, boolean enter, int nextAnim) {
        //第一次进App Index页面去掉动画
        if (isFirst) {
            isFirst = false;
            return super.onCreateAnimation(transit, enter, nextAnim);
        } else {
            return new MainPageAnimation(enter, INDEX);
        }
    }
}
