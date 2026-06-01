package com.sandboxol.blockymods.view.fragment.game;

import android.content.Context;
import android.support.v4.app.FragmentTransaction;

import com.sandboxol.blockymods.R;
import com.sandboxol.blockymods.config.EventConstant;
import com.sandboxol.blockymods.config.IntConstant;
import com.sandboxol.blockymods.config.MessageToken;
import com.sandboxol.blockymods.entity.AccountCenter;
import com.sandboxol.blockymods.entity.LoginRegisterAccountForm;
import com.sandboxol.blockymods.entity.VisitorCenter;
import com.sandboxol.blockymods.utils.Helper;
import com.sandboxol.blockymods.view.dialog.RegisterFinishDialog;
import com.sandboxol.blockymods.view.fragment.category.CategoryFragment;
import com.sandboxol.blockymods.view.fragment.recommend.RecommendFragment;
import com.sandboxol.common.base.app.BaseFragment;
import com.sandboxol.common.base.viewmodel.ViewModel;
import com.sandboxol.common.binding.adapter.RadioGroupBindingAdapters;
import com.sandboxol.common.command.ReplyCommand;
import com.sandboxol.common.messenger.Messenger;
import com.tendcloud.tenddata.TCAgent;

/**
 * Created by Bob on 2017/11/3.
 */
public class GameViewModel extends ViewModel {

    private boolean isFirst = true;

    private GameFragment fragment;
    private Context context;

    private RecommendFragment recommendFragment;
    private CategoryFragment categoryFragment;

    private BaseFragment currentFragment;

    public ReplyCommand<RadioGroupBindingAdapters.CheckedDataWrapper> onCheckCommand = new ReplyCommand<>(checkedDataWrapper -> onCheck(checkedDataWrapper.getCheckedId()));

    public GameViewModel(Context context, GameFragment fragment) {
        this.fragment = fragment;
        this.context = context;
        initFragments();
        initMessage();
        onCheck(R.id.rbRecommend);
        //获取游客信息
        if (AccountCenter.newInstance().userId.get() == 0 && VisitorCenter.newInstance().userId.get() == 0)
            loadVisitorInfo(context);
    }

    private void loadVisitorInfo(Context context) {
        LoginRegisterAccountForm form = new LoginRegisterAccountForm();
        Helper.getSystemInfo(context, form);
        new GameModel().loadVisitorInfo(context, form);
    }

    private void initFragments() {
        recommendFragment = new RecommendFragment();
        categoryFragment = new CategoryFragment();
        FragmentTransaction ft = fragment.getChildFragmentManager().beginTransaction();
        ft.add(R.id.flGame, categoryFragment, "CategoryFragment");
        ft.hide(categoryFragment);
        ft.add(R.id.flGame, recommendFragment, "RecommendFragment");
        ft.hide(recommendFragment);
        ft.commitAllowingStateLoss();
    }

    private void initMessage() {
        Messenger.getDefault().register(this, MessageToken.TOKEN_REGISTER_SUCCESS, Integer.class, type -> {
            if (type == IntConstant.REGISTER_SUCCESS_DIALOG)
                new RegisterFinishDialog(fragment.getActivity()).show();
        });
    }

    private void onCheck(int checkedId) {
        switch (checkedId) {
            case R.id.rbRecommend:
                selectFragment(recommendFragment);
                if (!isFirst)
                    TCAgent.onEvent(context, EventConstant.HOME_RECO);
                break;
            case R.id.rbCategory:
                selectFragment(categoryFragment);
                TCAgent.onEvent(context, EventConstant.HOME_CLASS);
                break;
        }
        if (isFirst)
            isFirst = false;
    }

    private void selectFragment(BaseFragment baseFragment) {
        FragmentTransaction ft = fragment.getChildFragmentManager().beginTransaction();
        ft.setTransition(FragmentTransaction.TRANSIT_NONE);
        if (currentFragment != null)
            ft.hide(currentFragment);
        ft.show(baseFragment);
        ft.commitAllowingStateLoss();
        currentFragment = baseFragment;
    }

    @Override
    public void onDestroy() {
        super.onDestroy();
        Messenger.getDefault().unregister(this);
    }

}
