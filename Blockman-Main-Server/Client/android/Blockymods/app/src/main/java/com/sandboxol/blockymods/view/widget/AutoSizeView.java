package com.sandboxol.blockymods.view.widget;

import android.content.Context;
import android.content.res.TypedArray;
import android.util.AttributeSet;
import android.widget.FrameLayout;

import com.sandboxol.blockymods.R;

/**
 * Created by Bob on 2017/10/31.
 */
public class AutoSizeView extends FrameLayout {

    private boolean isWidth;
    private int widthProportion, heightProportion;

    public AutoSizeView(Context context) {
        this(context, null);
    }

    public AutoSizeView(Context context, AttributeSet attrs) {
        this(context, attrs, 0);
    }

    public AutoSizeView(Context context, AttributeSet attrs, int defStyleAttr) {
        super(context, attrs, defStyleAttr);
        TypedArray array = context.obtainStyledAttributes(attrs, R.styleable.AutoSizeView);
        isWidth = array.getBoolean(R.styleable.AutoSizeView_isAutoWidth, false);
        widthProportion = array.getInteger(R.styleable.AutoSizeView_widthProportion, 1);
        heightProportion = array.getInteger(R.styleable.AutoSizeView_heightProportion, 1);
        array.recycle();
    }

    @Override
    protected void onMeasure(int widthMeasureSpec, int heightMeasureSpec) {
        if (isWidth) {
            super.onMeasure(widthMeasureSpec * widthProportion, widthMeasureSpec * heightProportion);
            setMeasuredDimension(widthMeasureSpec * widthProportion, widthMeasureSpec * heightProportion);
        } else {
            super.onMeasure(heightMeasureSpec * widthProportion, heightMeasureSpec * heightProportion);
            setMeasuredDimension(heightMeasureSpec * widthProportion, heightMeasureSpec * heightProportion);
        }
    }
}
