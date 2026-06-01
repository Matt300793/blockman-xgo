package com.sandboxol.mapeditor.view.dialog;

import android.content.Context;
import android.support.annotation.NonNull;
import android.view.View;
import android.widget.TextView;

import com.sandboxol.common.dialog.FullScreenDialog;
import com.sandboxol.mapeditor.R;

/**
 * Created by Jimmy on 2017/12/1 0001.
 */
public class EditorMapDialog extends FullScreenDialog implements View.OnClickListener {

    private OnItemClickListener listener;

    public EditorMapDialog(@NonNull Context context) {
        super(context);
    }

    @Override
    protected void init(Context context) {
        super.init(context);
        setContentView(R.layout.dialog_editor_map);
        findViewById(R.id.llContent).setOnClickListener(this);
        findViewById(R.id.tvRename).setOnClickListener(this);
        findViewById(R.id.tvCopy).setOnClickListener(this);
        findViewById(R.id.tvModel).setOnClickListener(this);
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

    public EditorMapDialog setMapName(String name) {
        ((TextView) findViewById(R.id.tvName)).setText(name);
        return this;
    }

    public EditorMapDialog setOnItemClickListener(OnItemClickListener listener) {
        this.listener = listener;
        return this;
    }

    @Override
    public void onClick(View v) {
        switch (v.getId()) {
            case R.id.tvRename:
                if (listener != null)
                    listener.onItemClick(EditorType.RENAME);
                break;
            case R.id.tvCopy:
                if (listener != null)
                    listener.onItemClick(EditorType.COPY);
                break;
            case R.id.tvModel:
                if (listener != null)
                    listener.onItemClick(EditorType.MODEL);
                break;
        }
        dismiss();
    }

    public enum EditorType {
        RENAME,
        COPY,
        MODEL
    }

    public interface OnItemClickListener {
        void onItemClick(EditorType type);
    }

}
