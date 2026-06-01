package com.sandboxol.mapeditor.view.dialog;

import android.content.Context;
import android.support.annotation.NonNull;
import android.view.View;
import android.widget.Button;
import android.widget.TextView;

import com.sandboxol.common.dialog.FullScreenDialog;
import com.sandboxol.mapeditor.R;

/**
 * Created by Jimmy on 2017/11/28 0028.
 */
public class YerOrNoDialog extends FullScreenDialog implements View.OnClickListener {

    private TextView tvContent;
    private Button btnConfirm, btnCancel;
    private OnConfirmListener onConfirmListener;
    private OnCancelListener onCancelListener;

    public YerOrNoDialog(@NonNull Context context) {
        super(context);
    }

    @Override
    protected void init(Context context) {
        super.init(context);
        setContentView(R.layout.dialog_yer_or_no);
        tvContent = findViewById(R.id.tvContent);
        btnConfirm = findViewById(R.id.btnConfirm);
        btnCancel = findViewById(R.id.btnCancel);
        btnConfirm.setOnClickListener(this);
        btnCancel.setOnClickListener(this);
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

    public YerOrNoDialog setCancelListener(OnCancelListener listener) {
        this.onCancelListener = listener;
        return this;
    }

    public YerOrNoDialog setConfirmListener(OnConfirmListener listener) {
        this.onConfirmListener = listener;
        return this;
    }

    public YerOrNoDialog setContentText(int textId) {
        tvContent.setText(textId);
        return this;
    }

    public YerOrNoDialog setContentText(String text) {
        tvContent.setText(text);
        return this;
    }

    public YerOrNoDialog setCancelText(int textId) {
        btnCancel.setText(textId);
        return this;
    }

    public YerOrNoDialog setCancelText(String text) {
        btnCancel.setText(text);
        return this;
    }

    public YerOrNoDialog setConfirmText(int textId) {
        btnConfirm.setText(textId);
        return this;
    }

    public YerOrNoDialog setConfirmText(String text) {
        btnConfirm.setText(text);
        return this;
    }

    @Override
    public void onClick(View v) {
        switch (v.getId()) {
            case R.id.btnConfirm:
                dismiss();
                if (onConfirmListener != null) {
                    onConfirmListener.onConfirm();
                }
                break;
            case R.id.btnCancel:
                dismiss();
                if (onCancelListener != null) {
                    onCancelListener.onCancel();
                }
                break;
        }
    }

    public interface OnConfirmListener {
        void onConfirm();
    }

    public interface OnCancelListener {
        void onCancel();
    }

}
