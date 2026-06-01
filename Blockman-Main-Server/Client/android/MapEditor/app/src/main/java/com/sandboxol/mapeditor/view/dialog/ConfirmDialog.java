package com.sandboxol.mapeditor.view.dialog;

import android.content.Context;
import android.support.annotation.NonNull;
import android.widget.Button;
import android.widget.TextView;

import com.sandboxol.common.dialog.FullScreenDialog;
import com.sandboxol.mapeditor.R;

/**
 * Created by Jimmy on 2017/11/28 0028.
 */
public class ConfirmDialog extends FullScreenDialog {

    private TextView tvTitle;
    private Button btnConfirm;
    private OnConfirmListener listener;

    public ConfirmDialog(@NonNull Context context) {
        super(context);
    }

    @Override
    protected void init(Context context) {
        super.init(context);
        setContentView(R.layout.dialog_confirm);
        tvTitle = findViewById(R.id.tvContent);
        btnConfirm = findViewById(R.id.btnConfirm);
        btnConfirm.setOnClickListener(v -> {
            dismiss();
            if (listener != null) {
                listener.onConfirm();
            }
        });
    }

    @Override
    protected boolean isBlurBackground() {
        return true;
    }

    @Override
    protected float getBlurScale() {
        return 2.5f;
    }

    @Override
    protected int getBlurRadius() {
        return 3;
    }


    public ConfirmDialog setConfirmListener(OnConfirmListener listener) {
        this.listener = listener;
        return this;
    }

    public ConfirmDialog setContentText(int textId) {
        tvTitle.setText(textId);
        return this;
    }

    public ConfirmDialog setContentText(String text) {
        tvTitle.setText(text);
        return this;
    }

    public ConfirmDialog setConfirmText(int textId) {
        btnConfirm.setText(textId);
        return this;
    }

    public ConfirmDialog setConfirmText(String text) {
        btnConfirm.setText(text);
        return this;
    }

    public interface OnConfirmListener {
        void onConfirm();
    }

}
