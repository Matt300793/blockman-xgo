package com.sandboxol.common.utils;

import android.app.Activity;
import android.app.ActivityManager;
import android.content.Context;
import android.content.pm.PackageInfo;
import android.content.pm.PackageManager;
import android.content.res.Configuration;
import android.graphics.Bitmap;
import android.provider.MediaStore;
import android.provider.Settings;
import android.telephony.TelephonyManager;
import android.view.View;
import android.view.inputmethod.InputMethodManager;

import com.google.gson.Gson;
import com.sandboxol.common.R;
import com.sandboxol.common.base.app.BaseApplication;

import java.util.List;
import java.util.Locale;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

/**
 * Created by Bob on 2017/10/19.
 */
public class CommonHelper {

    public static void hideSoftInputFromWindow(Context context) {
        if (((Activity) context).getCurrentFocus() != null && ((Activity) context).getCurrentFocus().getWindowToken() != null) {
            ((InputMethodManager) context.getSystemService(Context.INPUT_METHOD_SERVICE)).hideSoftInputFromWindow(((Activity) context).getCurrentFocus().getWindowToken(), 0);
        }
    }

    public static boolean isTablet(Context context) {
        try {
            context = context.getApplicationContext();
            return (context.getResources().getConfiguration().screenLayout & Configuration.SCREENLAYOUT_SIZE_MASK) >= Configuration.SCREENLAYOUT_SIZE_LARGE;
        } catch (Exception e) {
            return false;
        }
    }

    public static String getDeviceId(Context context) {
        TelephonyManager tm = (TelephonyManager) context.getApplicationContext().getSystemService(Context.TELEPHONY_SERVICE);
        String imei = tm.getDeviceId();
        if (imei == null) {
            imei = Settings.Secure.getString(context.getContentResolver(), Settings.Secure.ANDROID_ID);
        }
        return imei;
    }

    public static String getLanguage() {
        Locale locale = BaseApplication.getApp().getResources().getConfiguration().locale;
        return String.format("%s_%s", locale.getLanguage(), locale.getCountry());
    }

    public static <T> T formatObject(String json, Class<T> tclass) {
        Gson gson = new Gson();
        T object = gson.fromJson(json, tclass);
        return object;
    }

    public static int checkProcessIsRunning(Context ctx, String packageName) {
        try {
            ctx = ctx.getApplicationContext();
            ActivityManager am = (ActivityManager) ctx.getApplicationContext().getSystemService(Context.ACTIVITY_SERVICE);
            for (ActivityManager.RunningAppProcessInfo appProcess : am.getRunningAppProcesses()) {
                if (appProcess.processName.equals(packageName)) {
                    return appProcess.pid;
                }
            }
        } catch (Exception e) {

        }
        return 0;
    }

    //这种方法状态栏是空白，显示不了状态栏的信息
    public static Bitmap getViewBitmap(View rootView) {
        //获取当前屏幕的大小
        int width = rootView.getWidth();
        int height = rootView.getHeight();
        if (width == 0 || height == 0)
            return null;
        //生成相同大小的图片
        Bitmap temBitmap = Bitmap.createBitmap(width, height, Bitmap.Config.ARGB_8888);
        //找到当前页面的跟布局
        //设置缓存
        rootView.setDrawingCacheEnabled(true);
        rootView.buildDrawingCache();
        //从缓存中获取当前屏幕的图片
        temBitmap = rootView.getDrawingCache();

        return temBitmap;
    }

    public static void screenPic(Context context, String name, View rootView) {
        Bitmap bitmap = getViewBitmap(rootView);
        if (bitmap != null)
            MediaStore.Images.Media.insertImage(context.getContentResolver(), bitmap, name, context.getResources().getString(R.string.app_name));
    }

    public static boolean isEmail(String email) {
        String regEx = "^[a-zA-Z0-9_-]+@[a-zA-Z0-9_-]+(\\.[a-zA-Z0-9_-]+)+$";
        Pattern pattern = Pattern.compile(regEx);
        Matcher matcher = pattern.matcher(email);
        return matcher.matches();
    }

    /**
     * 判断是否安装App
     *
     * @param context
     * @param packageName
     * @return
     */
    public static boolean isAppInstalled(Context context, String packageName) {
        final PackageManager packageManager = context.getPackageManager();
        // 获取所有已安装程序的包信息
        List<PackageInfo> packages = packageManager.getInstalledPackages(0);
        for (int i = 0; i < packages.size(); i++) {
            if (packages.get(i).packageName.equalsIgnoreCase(packageName))
                return true;
        }
        return false;
    }

}
