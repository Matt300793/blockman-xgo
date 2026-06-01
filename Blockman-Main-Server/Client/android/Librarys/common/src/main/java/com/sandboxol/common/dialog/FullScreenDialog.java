package com.sandboxol.common.dialog;

import android.app.Activity;
import android.app.Dialog;
import android.content.Context;
import android.graphics.Bitmap;
import android.graphics.Canvas;
import android.graphics.Color;
import android.graphics.Paint;
import android.graphics.RectF;
import android.graphics.drawable.BitmapDrawable;
import android.support.annotation.NonNull;
import android.view.Window;

import com.sandboxol.common.R;
import com.sandboxol.common.utils.BlurUtil;
import com.sandboxol.common.utils.CommonHelper;

/**
 * Created by Bob on 2017/11/11.
 */
public class FullScreenDialog extends Dialog {

    public FullScreenDialog(@NonNull Context context) {
        super(context, R.style.FullScreenTheme);
        init(context);
    }

    protected void init(Context context) {
        setCanceledOnTouchOutside(true);
        setCancelable(true);
        requestWindowFeature(Window.FEATURE_NO_TITLE);
        initBackground(context);
    }

    private void initBackground(Context context) {
        if (getWindow() == null)
            return;
        if (!isBlurBackground()) {
            getWindow().setBackgroundDrawableResource(R.color.dialog_shadow);
            return;
        }
        if (!(context instanceof Activity)) {
            getWindow().setBackgroundDrawableResource(R.color.dialog_shadow);
            return;
        }
        Bitmap bitmap = BlurUtil.blur(context, CommonHelper.getViewBitmap(((Activity) context).getWindow().getDecorView()), getBlurScale(), getBlurRadius());
        if (bitmap != null) {
            getWindow().setBackgroundDrawable(new BitmapDrawable(context.getResources(), makeShadowBitmap(bitmap)));
        } else {
            getWindow().setBackgroundDrawableResource(R.color.dialog_shadow);
        }
    }

    private Bitmap makeShadowBitmap(Bitmap bitmap) {
        Canvas canvas = new Canvas(bitmap);
        Paint paint = new Paint(Paint.ANTI_ALIAS_FLAG);
        paint.setColor(Color.BLACK);
        paint.setAlpha(65);
        canvas.drawRect(new RectF(0, 0, bitmap.getWidth(), bitmap.getHeight()), paint);
        return bitmap;
    }

    protected boolean isBlurBackground() {
        return false;
    }

    protected float getBlurScale() {
        return 8.0f;
    }

    protected int getBlurRadius() {
        return 8;
    }

}
