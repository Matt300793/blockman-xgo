package com.sandboxol.mapeditor.view.dialog;

import android.content.Context;
import android.support.annotation.NonNull;
import android.view.View;
import android.widget.EditText;

import com.sandboxol.common.dialog.FullScreenDialog;
import com.sandboxol.mapeditor.R;

/**
 * Created by Jimmy on 2017/12/1 0001.
 */
public class MapRenameDialog extends FullScreenDialog implements View.OnClickListener {

    private OnConfirmListener listener;

    public MapRenameDialog(@NonNull Context context) {
        super(context);
    }

    @Override
    protected void init(Context context) {
        super.init(context);
        setContentView(R.layout.dialog_map_rename);
        findViewById(R.id.btnCancel).setOnClickListener(this);
        findViewById(R.id.btnConfirm).setOnClickListener(this);
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

    public MapRenameDialog setMapName(String name) {
        EditText etName = findViewById(R.id.etName);
        etName.setText(name);
        etName.setSelection(name.length());
        return this;
    }

    public MapRenameDialog setOnButtonClickListener(OnConfirmListener listener) {
        this.listener = listener;
        return this;
    }

    @Override
    public void onClick(View v) {
        switch (v.getId()) {
            case R.id.btnConfirm:
                if (listener != null)
                    listener.onConfirm(((EditText) findViewById(R.id.etName)).getText().toString());
                break;
        }
        dismiss();
    }

    public interface OnConfirmListener {

        void onConfirm(String name);

    }

}
