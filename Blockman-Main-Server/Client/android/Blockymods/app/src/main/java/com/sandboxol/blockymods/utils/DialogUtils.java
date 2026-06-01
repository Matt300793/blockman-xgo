package com.sandboxol.blockymods.utils;

import android.app.Dialog;
import android.content.Context;
import android.content.DialogInterface;
import android.view.LayoutInflater;
import android.view.View;
import android.view.Window;
import android.view.WindowManager;
import android.widget.ProgressBar;
import android.widget.TextView;

import com.sandboxol.blockymods.R;
import com.sandboxol.common.utils.CommonHelper;

/**
 * Created by Bob on 2017/10/20.
 */
public class DialogUtils {

    private Dialog dialog;
    private View view;

    public ProgressBar downloadPB;

    public DialogUtils(Context mContext, int layoutId) {
        this(mContext, true, layoutId);
    }

    public DialogUtils(final Context mContext, boolean isFullscreen, int layoutId) {
        view = LayoutInflater.from(mContext).inflate(layoutId, null);
        dialog = new Dialog(mContext, isFullscreen ? R.style.DialogFullscreen : R.style.DialogMinWidth);
//        dialog.getWindow().setWindowAnimations(R.style.cloudDialogWindowAnim);
        dialog.requestWindowFeature(Window.FEATURE_NO_TITLE);
        dialog.setContentView(view);
        dialog.setCanceledOnTouchOutside(false);
        if (CommonHelper.isTablet(mContext)) {
            dialog.getWindow().setBackgroundDrawableResource(android.R.color.transparent);
        }
        if (!isFullscreen) {
            Window win = getDialog().getWindow();
            dialog.getWindow().getDecorView().setPadding(0, 0, 0, 0);
            WindowManager.LayoutParams lp = win.getAttributes();
            lp.width = WindowManager.LayoutParams.MATCH_PARENT;
            lp.height = WindowManager.LayoutParams.WRAP_CONTENT;
            win.setAttributes(lp);
        }
        dialog.setOnDismissListener(isFullscreen ? null : (DialogInterface.OnDismissListener) dialog1 -> CommonHelper.hideSoftInputFromWindow(mContext));
        dialog.setOnCancelListener(isFullscreen ? null : (DialogInterface.OnCancelListener) dialog12 -> CommonHelper.hideSoftInputFromWindow(mContext));
    }

    public View getView() {
        return view;
    }

    public Dialog getDialog() {
        return dialog;
    }

    public void show() {
        try {
            dialog.show();
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    public void dismiss() {
        try {
            dialog.dismiss();
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    /**
     * 显示自己定义的是与否 带标题 对话框
     *
     * @param context        上下文
//     * @param msg            content内容
//     * @param title          标题
     * @param cancelListener 取消点击监听
     * @param sureListener   确定点击监听器
     */
    public static void showTitleAndYesOrNoDialog(final Context context, final View.OnClickListener cancelListener, final View.OnClickListener sureListener) {
        final DialogUtils customDialog = new DialogUtils(context, R.layout.dialog_app_title_text_yes_no);
        View v = customDialog.getView();
        TextView tvMsg = v.findViewById(R.id.tvMsg);
        TextView tvTitle =  v.findViewById(R.id.tvTitle);
//        tvMsg.setText(msg);
//        tvTitle.setText(title);
        v.findViewById(R.id.btnCancel).setOnClickListener(v1 -> {
            if (cancelListener != null) {
                cancelListener.onClick(v1);
            }
            customDialog.dismiss();
        });
        v.findViewById(R.id.btnSure).setOnClickListener(v2 -> {
            if (sureListener != null) {
                sureListener.onClick(v2);
            }
            customDialog.dismiss();
        });
        customDialog.show();
    }
}
