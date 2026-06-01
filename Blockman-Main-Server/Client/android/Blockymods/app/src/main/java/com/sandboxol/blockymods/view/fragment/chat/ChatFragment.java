package com.sandboxol.blockymods.view.fragment.chat;

import android.view.animation.Animation;

import com.sandboxol.blockymods.R;
import com.sandboxol.blockymods.anim.MainPageAnimation;
import com.sandboxol.blockymods.databinding.FragmentChatBinding;
import com.sandboxol.common.base.app.BaseFragment;

/**
 * Created by Jimmy on 2017/10/13 0013.
 */
public class ChatFragment extends BaseFragment<ChatViewModel, FragmentChatBinding> {

    public static final int INDEX = 2;

    @Override
    protected int getLayoutId() {
        return R.layout.fragment_chat;
    }

    @Override
    protected ChatViewModel getViewModel() {
        return new ChatViewModel();
    }

    @Override
    protected void bindViewModel(FragmentChatBinding binding, ChatViewModel viewModel) {
        binding.setChatViewModel(viewModel);
    }

    @Override
    public Animation onCreateAnimation(int transit, boolean enter, int nextAnim) {
        return new MainPageAnimation(enter, INDEX);
    }
}
