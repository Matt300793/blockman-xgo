package com.sandboxol.blockymods.view.fragment.minigamedetail;

import com.sandboxol.blockymods.R;
import com.sandboxol.blockymods.config.EventConstant;
import com.sandboxol.blockymods.config.StringConstant;
import com.sandboxol.blockymods.databinding.FragmentMiniGameDetailBinding;
import com.sandboxol.common.base.app.TemplateFragment;
import com.tendcloud.tenddata.TCAgent;

/**
 * Created by Bob on 2017/11/2.
 */
public class MiniGameDetailFragment extends TemplateFragment<MiniGameDetailViewModel, FragmentMiniGameDetailBinding> {

    private String gameId = null;

    @Override
    protected int getLayoutId() {
        return R.layout.fragment_mini_game_detail;
    }

    @Override
    protected MiniGameDetailViewModel getViewModel() {
        if (getArguments() != null)
            gameId = getArguments().getString(StringConstant.MINI_GAME_ID);
        return new MiniGameDetailViewModel(context, gameId);
    }

    @Override
    protected void bindViewModel(FragmentMiniGameDetailBinding binding, MiniGameDetailViewModel viewModel) {
        binding.setMiniGameDetailViewModel(viewModel);
    }

    @Override
    public void onResume() {
        super.onResume();
        TCAgent.onEvent(context, EventConstant.HOME_GAME, gameId);
    }
}
