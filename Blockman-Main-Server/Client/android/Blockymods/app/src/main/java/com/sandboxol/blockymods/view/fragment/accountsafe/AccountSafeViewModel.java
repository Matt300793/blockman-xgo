package com.sandboxol.blockymods.view.fragment.accountsafe;

import android.content.Context;

import com.sandboxol.blockymods.R;
import com.sandboxol.blockymods.config.EventConstant;
import com.sandboxol.blockymods.entity.AccountCenter;
import com.sandboxol.blockymods.view.fragment.bindphone.BindPhoneFragment;
import com.sandboxol.blockymods.view.fragment.changepassword.ChangePasswordFragment;
import com.sandboxol.blockymods.view.fragment.bindemail.BindEmailFragment;
import com.sandboxol.blockymods.view.fragment.email.EmailFragment;
import com.sandboxol.blockymods.view.fragment.phone.PhoneFragment;
import com.sandboxol.common.base.viewmodel.ViewModel;
import com.sandboxol.common.command.ReplyCommand;
import com.sandboxol.common.utils.TemplateUtils;
import com.tendcloud.tenddata.TCAgent;

/**
 * Created by Bob on 2017/10/23.
 */
public class AccountSafeViewModel extends ViewModel {

    private Context context;

    public ReplyCommand onChangePasswordClickCommand = new ReplyCommand(() -> {
        TemplateUtils.startTemplate(context, ChangePasswordFragment.class, context.getString(R.string.item_view_change_password), context.getString(R.string.finish));
        TCAgent.onEvent(context, EventConstant.MORE_CHPASS_CLICK);
    });

    public ReplyCommand onEmailClickCommand = new ReplyCommand(() -> {
        if ("".equals(AccountCenter.newInstance().email.get()) || AccountCenter.newInstance().email.get()==null) {
            TemplateUtils.startTemplate(context, BindEmailFragment.class, context.getString(R.string.item_view_bind_email));
            TCAgent.onEvent(context, EventConstant.MORE_EMAIL_CLICK);
        } else
            TemplateUtils.startTemplate(context, EmailFragment.class, context.getString(R.string.item_view_bind_email));
    });

    public ReplyCommand onBindPhoneClickCommand = new ReplyCommand(() -> {
        if ("".equals(AccountCenter.newInstance().telephone.get())) {
            TemplateUtils.startTemplate(context, BindPhoneFragment.class, context.getString(R.string.item_view_bind_phone));
            TCAgent.onEvent(context, EventConstant.MORE_MOI_CLICK);
        }else
            TemplateUtils.startTemplate(context, PhoneFragment.class, context.getString(R.string.item_view_bind_phone));
    });

    public AccountSafeViewModel(Context context) {
        this.context = context;
    }

}
