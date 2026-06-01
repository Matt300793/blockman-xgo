package com.sandboxol.blockymods.view.fragment.changename;

import android.app.Activity;
import android.content.Context;
import android.databinding.ObservableField;

import com.sandboxol.blockymods.R;
import com.sandboxol.blockymods.entity.AccountCenter;
import com.sandboxol.blockymods.entity.User;
import com.sandboxol.common.utils.HttpUtils;
import com.sandboxol.common.base.web.OnResponseListener;
import com.sandboxol.common.base.viewmodel.ViewModel;
import com.sandboxol.common.command.ReplyCommand;
import com.sandboxol.common.utils.ToastUtils;

/**
 * Created by Bob on 2017/10/20.
 */
public class ChangeNameViewModel extends ViewModel {

    public ObservableField<String> inputText = new ObservableField<>();
    public ObservableField<Boolean> showClear = new ObservableField<>();

    private String nickName;

    private Context context;

    public ChangeNameViewModel(Context context) {
        this.context = context;
    }

    //清空editText事件
    //TODO 只能清除一次Bug
    public ReplyCommand onClearTextCommand = new ReplyCommand<>(() -> {
        inputText.set("");
    });

    public ReplyCommand<String> onGetTextCommand = new ReplyCommand<>(s -> {
        if ("".equals(s))
            showClear.set(false);
        else
            showClear.set(true);

        nickName = s;
    });

    public void changeNickName() {

        new ChangeNameModel(nickName).loadData(context, new OnResponseListener<User>() {

            @Override
            public void onSuccess(User data) {
                AccountCenter.newInstance().nickName.set(data.getNickName());
                AccountCenter.putAccountInfo();
                ToastUtils.showShortToast(context, R.string.change_name_success);
                ((Activity)context).finish();
            }

            @Override
            public void onError(int code, String msg) {
                if (code == 1003)
                    ToastUtils.showShortToast(context, R.string.account_nickname_exist);
                else
                    ToastUtils.showShortToast(context, context.getString(R.string.connect_error_code, code));
            }

            @Override
            public void onServerError(int error) {
                ToastUtils.showShortToast(context, HttpUtils.getHttpErrorMsg(context, error));
            }
        });
    }

}
