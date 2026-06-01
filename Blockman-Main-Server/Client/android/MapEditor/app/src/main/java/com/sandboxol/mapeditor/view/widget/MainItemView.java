package com.sandboxol.mapeditor.view.widget;

import android.content.Context;
import android.content.res.TypedArray;
import android.support.annotation.AttrRes;
import android.support.annotation.NonNull;
import android.support.annotation.Nullable;
import android.util.AttributeSet;
import android.view.View;
import android.widget.FrameLayout;
import android.widget.TextView;

import com.sandboxol.mapeditor.R;

/**
 * Created by Jimmy on 2017/11/28 0028.
 */
public class MainItemView extends FrameLayout {

    public MainItemView(@NonNull Context context) {
        this(context, null);
    }

    public MainItemView(@NonNull Context context, @Nullable AttributeSet attrs) {
        this(context, attrs, 0);
    }

    public MainItemView(@NonNull Context context, @Nullable AttributeSet attrs, @AttrRes int defStyleAttr) {
        super(context, attrs, defStyleAttr);
        TypedArray array = context.obtainStyledAttributes(attrs, R.styleable.MainItemView);
        String title = array.getString(R.styleable.MainItemView_title);
        int backgroundId = array.getResourceId(R.styleable.MainItemView_backgroundRes, R.drawable.bg_main_start_editor);
        array.recycle();
        init(title, backgroundId);
    }

    private void init(String title, int backgroundId) {
        View.inflate(getContext(), R.layout.view_main_item, this);
        findViewById(R.id.llContent).setBackgroundResource(backgroundId);
        TextView tvTitle = findViewById(R.id.tvTitle);
        tvTitle.setText(title);
        setClickable(true);
    }
}
