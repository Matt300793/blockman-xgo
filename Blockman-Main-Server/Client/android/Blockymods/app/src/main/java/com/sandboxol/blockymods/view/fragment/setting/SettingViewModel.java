package com.sandboxol.blockymods.view.fragment.setting;

import android.app.Activity;
import android.content.Context;

import com.sandboxol.blockymods.R;
import com.sandboxol.blockymods.config.EventConstant;
import com.sandboxol.blockymods.config.IntConstant;
import com.sandboxol.blockymods.config.MessageToken;
import com.sandboxol.blockymods.entity.AccountCenter;
import com.sandboxol.blockymods.utils.IntentUtils;
import com.sandboxol.blockymods.view.activity.main.MainModel;
import com.sandboxol.blockymods.view.fragment.about.AboutFragment;
import com.sandboxol.blockymods.view.fragment.accountsafe.AccountSafeFragment;
import com.sandboxol.blockymods.view.fragment.question.QuestionFragment;
import com.sandboxol.blockymods.view.fragment.reminder.ReminderFragment;
import com.sandboxol.common.base.viewmodel.ViewModel;
import com.sandboxol.common.base.web.OnResponseListener;
import com.sandboxol.common.command.ReplyCommand;
import com.sandboxol.common.messenger.Messenger;
import com.sandboxol.common.utils.HttpUtils;
import com.sandboxol.common.utils.TemplateUtils;
import com.sandboxol.common.utils.ToastUtils;
import com.tendcloud.tenddata.TCAgent;

/**
 * Created by Bob on 2017/10/14.
 */
public class SettingViewModel extends ViewModel {

    private Context context;

    public ReplyCommand onAccountSafeClickCommand = new ReplyCommand(() ->
            TemplateUtils.startTemplate(context, AccountSafeFragment.class, context.getString(R.string.item_view_account_safe))
    );

    public ReplyCommand onReminderClickCommand = new ReplyCommand(() ->
            TemplateUtils.startTemplate(context, ReminderFragment.class, context.getString(R.string.item_view_reminder))
    );

    public ReplyCommand onQuestionClickCommand = new ReplyCommand(() ->
            TemplateUtils.startTemplate(context, QuestionFragment.class, context.getString(R.string.item_view_question))
    );

    public ReplyCommand onCheckVersionClickCommand = new ReplyCommand(() ->
            new MainModel().checkAppVersion(context, true)
    );

    public ReplyCommand onAboutClickCommand = new ReplyCommand(() ->
            TemplateUtils.startTemplate(context, AboutFragment.class, context.getString(R.string.item_view_about))
    );

    public ReplyCommand onLogoutClickCommand = new ReplyCommand(this::logoutClick);

    public SettingViewModel(Context context) {
        this.context = context;
    }

    private void logoutClick() {
        new SettingModel().logout(context, new OnResponseListener() {
            @Override
            public void onSuccess(Object data) {
                TCAgent.onEvent(context, EventConstant.MORE_EXIT_SUC);
                IntentUtils.startAccountActivity((Activity) context);
                AccountCenter.logout();
                Messenger.getDefault().send(IntConstant.ACCOUNT_LOGOUT, MessageToken.TOKEN_ACCOUNT);
            }

            @Override
            public void onError(int code, String msg) {
                ToastUtils.showShortToast(context, context.getString(R.string.connect_error_code, code));
            }

            @Override
            public void onServerError(int error) {
                ToastUtils.showShortToast(context, HttpUtils.getHttpErrorMsg(context, error));
            }
        });
    }

}
