package com.sandboxol.mapeditor.utils;

import android.app.Activity;
import android.content.Intent;
import android.os.Environment;

import com.sandboxol.mapeditor.config.FileConstant;
import com.sandboxol.mapeditor.view.activity.filechooser.FileChooserActivity;

/**
 * Created by Jimmy on 2017/11/28 0028.
 */
public class IntentUtils {

    /**
     * Get the Intent for selecting content to be used in an Intent Chooser.
     *
     * @return The intent for opening a file with Intent.createChooser()
     * @author paulburke
     */
    private static Intent createGetContentIntent() {
        final Intent intent = new Intent(Intent.ACTION_GET_CONTENT);
        intent.setType("*/*");
        intent.addCategory(Intent.CATEGORY_OPENABLE);
        return intent;
    }

    public static void startFileChooserActivity(Activity activity, int requestCode) {
        startFileChooserActivity(activity, null, requestCode);
    }

    public static void startFileChooserActivity(Activity activity, String fileType, int requestCode) {
        startFileChooserActivity(activity, fileType, FileChooserActivity.TYPE_FILES, requestCode);
    }

    public static void startFileChooserActivity(Activity activity, String fileType, int type, int requestCode) {
        startFileChooserActivity(activity, fileType, Environment.getExternalStorageDirectory().getPath(), type, requestCode);
    }

    public static void startFileChooserActivity(Activity activity, String fileType, String startPath, int requestCode) {
        startFileChooserActivity(activity, fileType, startPath, FileChooserActivity.TYPE_FOLDER, requestCode);
    }

    public static void startFileChooserActivity(Activity activity, String fileType, String startPath, int type, int requestCode) {
        Intent intent = createGetContentIntent();
        intent.setType(fileType);
        intent.setClass(activity, FileChooserActivity.class);
        intent.putExtra(FileChooserActivity.START_PATH, startPath);
        intent.putExtra(FileChooserActivity.CHOOSER_TYPE, type);
        activity.startActivityForResult(intent, requestCode);
    }

}
