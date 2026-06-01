package com.sandboxol.blockymods.view.fragment.more;

import android.content.Context;
import android.content.Intent;
import android.databinding.ObservableField;
import android.text.TextUtils;

import com.sandboxol.blockymods.R;
import com.sandboxol.blockymods.config.EventConstant;
import com.sandboxol.blockymods.config.IntConstant;
import com.sandboxol.blockymods.config.MessageToken;
import com.sandboxol.blockymods.config.StringConstant;
import com.sandboxol.blockymods.entity.AccountCenter;
import com.sandboxol.blockymods.view.activity.account.AccountActivity;
import com.sandboxol.blockymods.view.fragment.setting.SettingFragment;
import com.sandboxol.blockymods.view.fragment.updateuserinfo.UpdateUserInfoFragment;
import com.sandboxol.common.base.viewmodel.ViewModel;
import com.sandboxol.common.command.ReplyCommand;
import com.sandboxol.common.messenger.Messenger;
import com.sandboxol.common.utils.TemplateUtils;
import com.sandboxol.common.utils.ToastUtils;
import com.tendcloud.tenddata.TCAgent;

/**
 * Created by Bob on 2017/10/14.
 */
public class MoreViewModel extends ViewModel {

    public ObservableField<String> details = new ObservableField<>("");
    private Context context;
    public ReplyCommand onShopClickCommand = new ReplyCommand(this::onShopClick);
    public ReplyCommand onRechargeClickCommand = new ReplyCommand(this::onRechargeClick);
    public ReplyCommand onSettingClickCommand = new ReplyCommand(this::onSettingClick);
    public ReplyCommand onHelpClickCommand = new ReplyCommand(this::onHelpClick);
    public ReplyCommand onUpdateClickCommand = new ReplyCommand(this::onUpdateClick);
    public ReplyCommand onLoginClickCommand = new ReplyCommand(this::onLoginClick);
    public ReplyCommand onRegisterClickCommand = new ReplyCommand(this::onRegisterClick);

    public MoreViewModel(Context context) {
        this.context = context;
        initData();
        initMessage();
    }

    private void initData() {
        if (AccountCenter.newInstance().login.get())
            initUI();
        else
            details.set(context.getString(R.string.more_fragment_details, context.getString(R.string.more_fragment_no_details)));
    }

    private void initMessage() {
        Messenger.getDefault().register(this, MessageToken.TOKEN_ACCOUNT, Integer.class, type -> {
            if (type == IntConstant.ACCOUNT_LOGIN)
                initUI();
            else if (type == IntConstant.ACCOUNT_REGISTER)
                initUI();
            else if (type == IntConstant.ACCOUNT_LOGOUT)
                details.set(context.getString(R.string.more_fragment_details, context.getString(R.string.more_fragment_no_details)));
            else if (type == IntConstant.UPDATE_USER_INFO)
                initUI();
        });
    }

    /**
     * 设置个人简介
     */
    private void initUI() {
        if (TextUtils.isEmpty(AccountCenter.newInstance().detail.get())) {
            details.set(context.getString(R.string.more_fragment_details, context.getString(R.string.more_fragment_no_details)));
        } else {
            details.set(context.getString(R.string.more_fragment_details, AccountCenter.newInstance().detail.get()));
        }
    }

    private void onShopClick() {
        ToastUtils.showShortToast(context, R.string.coming_soon);
//        TemplateUtils.startTemplate(context, ShopFragment.class, context.getString(R.string.me_shop));
        TCAgent.onEvent(context, EventConstant.MORE_SHOP);
    }

    private void onRechargeClick() {
        ToastUtils.showShortToast(context, R.string.coming_soon);
//        TemplateUtils.startTemplate(context, RechargeFragment.class, context.getString(R.string.me_recharge));
        TCAgent.onEvent(context, EventConstant.MORE_TOPUP);
    }

    private void onSettingClick() {
        TemplateUtils.startTemplate(context, SettingFragment.class, context.getString(R.string.me_setting));
        TCAgent.onEvent(context, EventConstant.MORE_SETUP);
    }

    private void onHelpClick() {
        ToastUtils.showShortToast(context, R.string.coming_soon);
//        TemplateUtils.startTemplate(context, HelpFragment.class, context.getString(R.string.me_help));
        TCAgent.onEvent(context, EventConstant.MORE_HELP);
    }

    private void onUpdateClick() {
        if (AccountCenter.newInstance().login.get()) {
            TemplateUtils.startTemplate(context, UpdateUserInfoFragment.class, context.getString(R.string.item_view_personal_details));
            TCAgent.onEvent(context, EventConstant.MORE_PERSINFO);
        }
    }

    private void onLoginClick() {
        context.startActivity(new Intent(context, AccountActivity.class));
        TCAgent.onEvent(context, EventConstant.MORE_LOGIN);
    }

    private void onRegisterClick() {
        context.startActivity(new Intent(context, AccountActivity.class).putExtra(StringConstant.MORE_LOGIN_TYPE, "REGISTER"));
        TCAgent.onEvent(context, EventConstant.MORE_REG);
    }

    public Context getContext() {
        return context;
    }

    @Override
    public void onDestroy() {
        super.onDestroy();
        Messenger.getDefault().unregister(this);
    }

}
