package com.sandboxol.mapeditor.view.widget;

import android.content.Context;
import android.content.res.TypedArray;
import android.support.annotation.Nullable;
import android.util.AttributeSet;
import android.view.View;
import android.view.ViewGroup;
import android.widget.RelativeLayout;

import com.sandboxol.mapeditor.R;

/**
 * Created by Jimmy on 2017/12/2 0002.
 */
public class LineItemView extends RelativeLayout {

    public LineItemView(Context context) {
        this(context, null);
    }

    public LineItemView(Context context, @Nullable AttributeSet attrs) {
        this(context, attrs, 0);
    }

    public LineItemView(Context context, @Nullable AttributeSet attrs, int defStyleAttr) {
        super(context, attrs, defStyleAttr);
        TypedArray array = context.obtainStyledAttributes(attrs, R.styleable.LineItemView);
        int color = array.getColor(R.styleable.LineItemView_lineColor, context.getResources().getColor(R.color.mainBgColor));
        int direction = array.getInt(R.styleable.LineItemView_lineDirection, RelativeLayout.ALIGN_PARENT_BOTTOM);
        array.recycle();
        init(color, direction);
    }

    private void init(int color, int direction) {
        View line = new View(getContext());
        RelativeLayout.LayoutParams params;
        if (direction == RelativeLayout.ALIGN_PARENT_TOP || direction == RelativeLayout.ALIGN_PARENT_BOTTOM) {
            params = new RelativeLayout.LayoutParams(ViewGroup.LayoutParams.MATCH_PARENT,
                    getContext().getResources().getDimensionPixelOffset(R.dimen.boldLineH));
        } else {
            params = new RelativeLayout.LayoutParams(getContext().getResources().getDimensionPixelOffset(R.dimen.boldLineH),
                    ViewGroup.LayoutParams.MATCH_PARENT);
        }
        params.addRule(direction, RelativeLayout.TRUE);
        line.setLayoutParams(params);
        line.setBackgroundColor(color);
        addView(line);
    }

}
