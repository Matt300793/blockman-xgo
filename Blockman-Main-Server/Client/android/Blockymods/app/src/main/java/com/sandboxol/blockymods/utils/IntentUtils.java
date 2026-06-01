package com.sandboxol.blockymods.utils;

import android.app.Activity;
import android.content.Context;
import android.content.Intent;

import com.sandboxol.blockymods.view.activity.account.AccountActivity;
import com.sandboxol.blockymods.view.activity.main.MainActivity;
import com.sandboxol.blockymods.view.dialog.RepeatLoginDialog;

/**
 * Created by Jimmy on 2017/11/29 0029.
 */
public class IntentUtils {

    public static void startRepeatLoginDialog(Context context) {
        Intent intent = new Intent(context, RepeatLoginDialog.class);
        intent.setFlags(Intent.FLAG_ACTIVITY_NEW_TASK);
        context.startActivity(intent);
    }

    public static void startMainActivity(Context context) {
        Intent intent = new Intent(context, MainActivity.class);
        intent.setFlags(Intent.FLAG_ACTIVITY_CLEAR_TOP);
        context.startActivity(intent);
    }

    public static void startAccountActivity(Activity activity) {
        Intent intent = new Intent(activity, AccountActivity.class);
        activity.startActivity(intent);
        if (activity instanceof MainActivity) return;
        activity.finish();
    }

}
