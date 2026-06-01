package com.sandboxol.blockymods.view.widget;

import android.content.Context;
import android.content.res.TypedArray;
import android.support.annotation.Nullable;
import android.support.v4.content.ContextCompat;
import android.util.AttributeSet;
import android.view.View;
import android.widget.FrameLayout;
import android.widget.ImageView;
import android.widget.LinearLayout;
import android.widget.TextView;

import com.sandboxol.blockymods.R;

/**
 * Created by Bob on 2017/10/20.
 */
public class MeItemView extends FrameLayout {

    private ImageView ivPoint;
    private ImageView ivArrow;

    public MeItemView(Context context) {
        this(context, null);
    }

    public MeItemView(Context context, @Nullable AttributeSet attrs) {
        this(context, attrs, 0);
    }

    public MeItemView(Context context, @Nullable AttributeSet attrs, int defStyleAttr) {
        super(context, attrs, defStyleAttr);
        TypedArray array = context.obtainStyledAttributes(attrs, R.styleable.MeItemView);
        int drawableLeft = array.getResourceId(R.styleable.MeItemView_drawableLeft, R.mipmap.ic_me_help);
        boolean isShowPoint = array.getBoolean(R.styleable.MeItemView_isShowPoint, false);
        boolean isShowBorder = array.getBoolean(R.styleable.MeItemView_isShowBorder, true);
        int text = array.getResourceId(R.styleable.MeItemView_text, R.string.finish);
        array.recycle();
        initView(context, drawableLeft, isShowPoint, isShowBorder, text);
    }

    private void initView(Context context, int drawableLeft, boolean isShowPoint, boolean isShowBorder, int text) {
        View.inflate(context, R.layout.content_me_item_view, this);
        ImageView ivDrawableLeft = findViewById(R.id.ivDrawableLeft);
        TextView tvText = findViewById(R.id.tvText);
        View vLine = findViewById(R.id.vLine);
        ivPoint = findViewById(R.id.ivPoint);
        ivArrow = findViewById(R.id.ivArrow);

        ivDrawableLeft.setImageResource(drawableLeft);
        tvText.setText(text);
        vLine.setVisibility(isShowBorder ? VISIBLE : GONE);
        changePoint(isShowPoint);
        setClickable(true);
    }

    public void changePoint(boolean isShowPoint) {
        if (isShowPoint)
            showPoint();
        else
            hidePoint();
    }

    private void showPoint() {
        ivPoint.setVisibility(VISIBLE);
        ivArrow.setVisibility(GONE);
    }

    private void hidePoint() {
        ivPoint.setVisibility(GONE);
        ivArrow.setVisibility(VISIBLE);
    }
}
