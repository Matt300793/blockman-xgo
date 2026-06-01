package com.sandboxol.blockymods.view.dialog;

import android.content.Context;
import android.databinding.DataBindingUtil;
import android.support.annotation.NonNull;
import android.view.LayoutInflater;

import com.sandboxol.blockymods.R;
import com.sandboxol.blockymods.config.SharedConstant;
import com.sandboxol.blockymods.databinding.DialogAppRegisterFinishBinding;
import com.sandboxol.common.dialog.FullScreenDialog;
import com.sandboxol.common.utils.CommonHelper;
import com.sandboxol.common.utils.SharedUtils;
import com.sandboxol.common.utils.ToastUtils;

/**
 * Created by Bob on 2017/11/11.
 */
public class RegisterFinishDialog extends FullScreenDialog {

    public RegisterFinishDialog(@NonNull Context context) {
        super(context);
    }

    @Override
    protected void init(Context context) {
        super.init(context);
        DialogAppRegisterFinishBinding binding = DataBindingUtil.inflate(LayoutInflater.from(context), R.layout.dialog_app_register_finish, null, false);
        setContentView(binding.getRoot());
        binding.tvAccount.setText(context.getResources().getString(R.string.account_register_finish_account, SharedUtils.getString(context, SharedConstant.SAVE_ACCOUNT_NUM)));
        binding.tvPassword.setText(context.getResources().getString(R.string.account_register_finish_password, SharedUtils.getString(context, SharedConstant.SAVE_PASSWORD)));
        binding.btnClose.setOnClickListener(v -> dismiss());
        binding.btnSave.setOnClickListener(v -> save(context, binding));
    }

    private void save(Context context, DialogAppRegisterFinishBinding binding) {
        CommonHelper.screenPic(context, SharedUtils.getString(context, SharedConstant.SAVE_ACCOUNT_NUM), binding.llContainer);
        ToastUtils.showShortToast(context, R.string.account_register_finish_save_success);
        dismiss();
    }
}
