package com.sandboxol.blockymods.view.dialog;

import android.content.Context;
import android.databinding.DataBindingUtil;
import android.support.annotation.NonNull;
import android.text.Editable;
import android.text.TextWatcher;
import android.view.LayoutInflater;
import android.view.View;

import com.sandboxol.blockymods.R;
import com.sandboxol.blockymods.databinding.DialogAppUnbindPhoneBinding;
import com.sandboxol.blockymods.entity.AccountCenter;
import com.sandboxol.blockymods.interfaces.IDataListener;
import com.sandboxol.common.dialog.FullScreenDialog;
import com.sandboxol.common.utils.ToastUtils;

/**
 * Created by Bob on 2017/11/14.
 */
public class UnbindingPhoneDialog extends FullScreenDialog {

    private View.OnClickListener getCodeListener, cancelListener, sureListener;
    private IDataListener dataListener;

    public UnbindingPhoneDialog(@NonNull Context context, final IDataListener dataListener, View.OnClickListener getCodeListener, View.OnClickListener cancelListener, View.OnClickListener sureListener ) {
        super(context);
        this.dataListener = dataListener;
        this.getCodeListener = getCodeListener;
        this.cancelListener = cancelListener;
        this.sureListener = sureListener;
    }

    @Override
    protected void init(Context context) {
        super.init(context);
        DialogAppUnbindPhoneBinding binding = DataBindingUtil.inflate(LayoutInflater.from(context), R.layout.dialog_app_unbind_phone, null, false);
        setContentView(binding.getRoot());
        binding.tvPhoneNum.setText(context.getString(R.string.bind_phone_phone_num, AccountCenter.newInstance().telephone.get()));

        binding.etCode.addTextChangedListener(new TextWatcher() {
            @Override
            public void beforeTextChanged(CharSequence s, int start, int count, int after) {
            }

            @Override
            public void onTextChanged(CharSequence s, int start, int before, int count) {
                if (dataListener != null)
                    dataListener.OnTextChange(s.toString());
            }

            @Override
            public void afterTextChanged(Editable s) {

            }
        });

        binding.btnCancel.setOnClickListener(v1 -> {
            if (cancelListener != null) {
                cancelListener.onClick(v1);
            }
            dismiss();
        });

        binding.btnSure.setOnClickListener(v2 -> {
            if (sureListener != null) {
                if (binding.etCode.getText() != null) {
                    sureListener.onClick(v2);
                    dismiss();
                } else
                    ToastUtils.showShortToast(context, R.string.bind_phone_code_is_empty);
            } else
                dismiss();
        });

        binding.btnGetCode.setOnClickListener(v3 -> {
            if (getCodeListener != null) {
                getCodeListener.onClick(v3);
            }
        });
    }
}
