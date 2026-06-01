package com.sandboxol.blockymods.view.activity.main;

import android.databinding.ObservableField;
import android.support.v4.app.FragmentTransaction;

import com.sandboxol.blockymods.R;
import com.sandboxol.blockymods.config.EventConstant;
import com.sandboxol.blockymods.config.IntConstant;
import com.sandboxol.blockymods.config.MessageToken;
import com.sandboxol.blockymods.entity.AccountCenter;
import com.sandboxol.blockymods.utils.IntentUtils;
import com.sandboxol.blockymods.view.dialog.RepeatLoginDialog;
import com.sandboxol.blockymods.view.fragment.chat.ChatFragment;
import com.sandboxol.blockymods.view.fragment.dress.DressFragment;
import com.sandboxol.blockymods.view.fragment.game.GameFragment;
import com.sandboxol.blockymods.view.fragment.more.MoreFragment;
import com.sandboxol.common.base.app.BaseFragment;
import com.sandboxol.common.base.viewmodel.ViewModel;
import com.sandboxol.common.binding.adapter.RadioGroupBindingAdapters;
import com.sandboxol.common.command.ReplyCommand;
import com.sandboxol.common.config.CommonMessageToken;
import com.sandboxol.common.messenger.Messenger;
import com.tendcloud.tenddata.TCAgent;

/**
 * Created by Jimmy on 2017/10/13 0013.
 */
public class MainViewModel extends ViewModel {

    public static int nextPageIndex = 0;
    public static int currPageIndex = 0;
    public ObservableField<Integer> checkId = new ObservableField<>();
    public ObservableField<String> title = new ObservableField<>();
    public ObservableField<Boolean> isShowLeftButton = new ObservableField<>();
    public ObservableField<Boolean> isShowRightButton = new ObservableField<>();
    private boolean isFirst = true;//用于统计
    private MainActivity activity;

    private GameFragment gameFragment;
    private DressFragment dressFragment;
    private ChatFragment chatFragment;
    private MoreFragment moreFragment;

    private BaseFragment currentFragment;

    public ReplyCommand<RadioGroupBindingAdapters.CheckedDataWrapper> onCheckCommand = new ReplyCommand<>(checkedDataWrapper -> onCheck(checkedDataWrapper.getCheckedId()));

    public MainViewModel(MainActivity activity) {
        this.activity = activity;
        initFragments();
        initMessage();
        onCheck(R.id.rb_1);
        checkAppVersion();
        loadAppConfig();
    }

    private void initMessage() {
        Messenger.getDefault().register(this, MessageToken.TOKEN_LOGIN_REGISTER_SUCCESS, Integer.class, type -> {
            if (type == IntConstant.REGISTER_SUCCESS || type == IntConstant.LOGIN_SUCCESS)
                onCheck(R.id.rb_1);
        });
        Messenger.getDefault().register(this, CommonMessageToken.TOKEN_REPEAT_LOGIN, () -> {
            AccountCenter.logout();
            Messenger.getDefault().send(IntConstant.ACCOUNT_LOGOUT, MessageToken.TOKEN_ACCOUNT);
            IntentUtils.startRepeatLoginDialog(activity);
        });
        Messenger.getDefault().register(this, MessageToken.TOKEN_APP_CHECK_UPDATE, this::checkAppVersion);
    }

    /**
     * 检测更新
     */
    private void checkAppVersion() {
        new MainModel().checkAppVersion(activity, false);
    }

    /**
     * 加载动态配置文件
     */
    private void loadAppConfig() {
        new MainModel().loadAppConfig(activity);
    }

    private void initFragments() {
        gameFragment = new GameFragment();
        dressFragment = new DressFragment();
        chatFragment = new ChatFragment();
        moreFragment = new MoreFragment();
        FragmentTransaction ft = activity.getSupportFragmentManager().beginTransaction();
        ft.add(R.id.flHomePage, gameFragment, "GameFragment");
        ft.hide(gameFragment);
        ft.add(R.id.flHomePage, dressFragment, "DressFragment");
        ft.hide(dressFragment);
        ft.add(R.id.flHomePage, chatFragment, "ChatFragment");
        ft.hide(chatFragment);
        ft.add(R.id.flHomePage, moreFragment, "MoreFragment");
        ft.hide(moreFragment);
        ft.commitAllowingStateLoss();
    }

    private void onCheck(int checkedId) {
        checkId.set(checkedId);
        switch (checkedId) {
            case R.id.rb_1:
                selectFragment(activity.getString(R.string.main_game), false, false, GameFragment.INDEX, gameFragment);
                if (!isFirst)
                    TCAgent.onEvent(activity, EventConstant.HOME_GAME_TAB);
                break;
            case R.id.rb_2:
                selectFragment(activity.getString(R.string.main_dress), false, false, DressFragment.INDEX, dressFragment);
                TCAgent.onEvent(activity, EventConstant.HOME_DRESS_TAB);
                break;
            case R.id.rb_3:
                selectFragment(activity.getString(R.string.main_chat), false, false, ChatFragment.INDEX, chatFragment);
                TCAgent.onEvent(activity, EventConstant.HOME_CHAT_TAB);
                break;
            case R.id.rb_4:
                selectFragment("", false, false, MoreFragment.INDEX, moreFragment);
                TCAgent.onEvent(activity, EventConstant.HOME_MORE_TAB);
                break;
        }
        if (isFirst)
            isFirst = false;
    }

    private void selectFragment(String titleText, boolean isShowLeft, boolean isShowRight, int index, BaseFragment replaceFragment) {
        title.set(titleText);
        isShowLeftButton.set(isShowLeft);
        isShowRightButton.set(isShowRight);
        nextPageIndex = index;
        replaceFragment(replaceFragment);
        currentFragment = replaceFragment;
    }

    private void replaceFragment(BaseFragment fragment) {
        FragmentTransaction ft = activity.getSupportFragmentManager().beginTransaction();
        ft.setTransition(FragmentTransaction.TRANSIT_NONE);
        if (currentFragment != null)
            ft.hide(currentFragment);
        ft.show(fragment);
        ft.commitAllowingStateLoss();
    }

    @Override
    public void onDestroy() {
        super.onDestroy();
        Messenger.getDefault().unregister(this);
    }

}
