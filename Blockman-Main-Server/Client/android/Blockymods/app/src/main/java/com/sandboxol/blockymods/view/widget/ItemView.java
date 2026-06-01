package com.sandboxol.blockymods.view.widget;

import android.content.Context;
import android.content.res.TypedArray;
import android.support.annotation.Nullable;
import android.util.AttributeSet;
import android.view.View;
import android.widget.FrameLayout;
import android.widget.ImageView;
import android.widget.TextView;

import com.sandboxol.blockymods.R;

/**
 * Created by Bob on 2017/10/20.
 */
public class ItemView extends FrameLayout {

    private TextView tvRightText;

    public ItemView(Context context) {
        this(context, null);
    }

    public ItemView(Context context, @Nullable AttributeSet attrs) {
        this(context, attrs, 0);
    }

    public ItemView(Context context, @Nullable AttributeSet attrs, int defStyleAttr) {
        super(context, attrs, defStyleAttr);
        TypedArray array = context.obtainStyledAttributes(attrs, R.styleable.ItemView);
        boolean isShowArrow = array.getBoolean(R.styleable.ItemView_showPoint, true);
        boolean isShowBorder = array.getBoolean(R.styleable.ItemView_border, true);
        CharSequence leftText = array.getText(R.styleable.ItemView_leftText);
        CharSequence rightText = array.getText(R.styleable.ItemView_rightText);
        CharSequence rightTextHint = array.getText(R.styleable.ItemView_rightTextHint);
        array.recycle();
        initView(context, isShowArrow, isShowBorder, leftText, rightText, rightTextHint);
    }

    private void initView(Context context, boolean isShowArrow, boolean isShowBorder, CharSequence leftText, CharSequence rightText, CharSequence rightTextHint) {
        View.inflate(context, R.layout.content_item_view, this);
        TextView tvLeftText = findViewById(R.id.tvLeftText);
        View vLine = findViewById(R.id.vLine);
        ImageView ivArrow = findViewById(R.id.ivArrow);
        tvRightText = findViewById(R.id.tvRightText);

        tvLeftText.setText(leftText);
        setText(rightText);
        tvRightText.setHint(rightTextHint);
        ivArrow.setVisibility(isShowArrow ? VISIBLE : GONE);
        vLine.setVisibility(isShowBorder ? VISIBLE : GONE);
        setClickable(true);
    }

    public void setText(CharSequence text) {
        tvRightText.setText(text);
    }
}
