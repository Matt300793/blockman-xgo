package com.sandboxol.blockymods.utils;

import android.Manifest;
import android.app.Activity;
import android.content.ContentResolver;
import android.content.ContentValues;
import android.content.Context;
import android.content.Intent;
import android.content.pm.PackageManager;
import android.database.Cursor;
import android.graphics.Bitmap;
import android.graphics.BitmapFactory;
import android.net.Uri;
import android.os.Build;
import android.os.Environment;
import android.provider.MediaStore;
import android.support.v4.app.ActivityCompat;
import android.support.v4.content.ContextCompat;
import android.support.v7.app.AppCompatActivity;
import android.util.Log;
import android.widget.ImageView;

import com.sandboxol.blockymods.R;
import com.sandboxol.blockymods.config.IntConstant;
import com.sandboxol.blockymods.config.StringConstant;
import com.sandboxol.blockymods.entity.AccountCenter;
import com.sandboxol.common.base.app.BaseFragment;
import com.sandboxol.common.utils.ToastUtils;

import java.io.File;
import java.io.FileNotFoundException;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.InputStream;

/**
 * 选择图片、切图
 * Created by luoweiyi on 15/11/17.
 */
public class IconCrop {

    public static long picName = 0;
    public static String key = "";
    public static File TMP_DIR;

    private static File dir = new File(Environment.getExternalStorageDirectory(), StringConstant.BLOCKY_MODS_CACHE_PATH_ICON_TEMP);
    private static Uri cropUri = Uri.fromFile(dir);

    private static IconCrop me;

    public static IconCrop newInstance() {
        if (me == null) {
            me = new IconCrop();
        }
        return me;
    }

    /**
     * 上传头像
     */
    public void uploadIcon(Context context, BaseFragment fragment) {
        if (Build.VERSION.SDK_INT >= 23) {
            int checkWritePermission = ContextCompat.checkSelfPermission(context, Manifest.permission.WRITE_EXTERNAL_STORAGE);
            int checkReadPermission = ContextCompat.checkSelfPermission(context, Manifest.permission.READ_EXTERNAL_STORAGE);
            if (checkReadPermission != PackageManager.PERMISSION_GRANTED || checkWritePermission != PackageManager.PERMISSION_GRANTED) {
                ActivityCompat.requestPermissions((AppCompatActivity) context, new String[]{Manifest.permission.WRITE_EXTERNAL_STORAGE, Manifest.permission.READ_EXTERNAL_STORAGE}, 123);
            } else {
                gotoImageList(context, fragment);
            }
        } else {
            gotoImageList(context, fragment);
        }
    }

    /**
     * 调用系统相册
     *
     * @param context
     * @param fragment
     */
    public void gotoImageList(Context context, BaseFragment fragment) {
        Intent intent = new Intent(Intent.ACTION_PICK);
        intent.setType("image/*");
        fragment.startActivityForResult(Intent.createChooser(intent, context.getString(R.string.account_choose_photo)), IntConstant.UPLOAD_ICON_SELECT_ICON);
    }


    /**
     * 头像裁剪
     *
     * @param uri
     * @param fragment
     */
    public void cutIcon(Uri uri, BaseFragment fragment) {
        dir.deleteOnExit();
        Intent intent = new Intent("com.android.camera.action.CROP");
        intent.setDataAndType(uri, "image/*");
        intent.putExtra("corp", "true");
        intent.putExtra("aspectX", 1);
        intent.putExtra("aspectY", 1);
        intent.putExtra("outputX", 300);
        intent.putExtra("outputY", 300);
        intent.putExtra("scale", true);
        intent.putExtra("return-data", false);
        intent.putExtra(MediaStore.EXTRA_OUTPUT, cropUri);
        intent.putExtra("outputFormat", Bitmap.CompressFormat.JPEG.toString());
        intent.putExtra("noFaceDetection", true);
        fragment.startActivityForResult(intent, IntConstant.UPLOAD_ICON_CROP_ICON);
    }

    /**
     * 头像裁剪后返回图片名称
     *
     * @return
     */
    public String cutIconResult(Context context, ImageView ivIcon) {
        Bitmap bm = convertUri(context, cropUri);
        if (bm != null) {
            ivIcon.setImageBitmap(bm);
            return key;
        } else {
            ToastUtils.showShortToast(context, context.getString(R.string.icon_select_fails));
        }
        return null;
    }

    public File cutIconReturnFile() {
        if (TMP_DIR != null)
            return TMP_DIR;
        return null;
    }

    private Bitmap convertUri(Context context, Uri uri) {
        InputStream is;
        try {
            is = context.getContentResolver().openInputStream(uri);
            Bitmap bitmap = BitmapFactory.decodeStream(is);
            if (is != null) {
                is.close();
                saveBitmap(bitmap);
                return bitmap;
            } else {
                return null;
            }
        } catch (FileNotFoundException e) {
            e.printStackTrace();
            return null;
        } catch (IOException e) {
            e.printStackTrace();
            return null;
        } catch (Exception e) {
            return null;
        }
    }

    private Uri saveBitmap(Bitmap bm) {
        picName = System.currentTimeMillis();
        File tmpDir = new File(Environment.getExternalStorageDirectory(), StringConstant.BLOCKY_MODS_CACHE_PATH_ICON);
        if (!tmpDir.exists()) {
            tmpDir.mkdirs();
        }
        key = "bolckymods-" + AccountCenter.newInstance().userId.get() + picName + ".jpg";
        File img = new File(tmpDir.getAbsolutePath(), key);
        TMP_DIR = img;
        //Log.e("icon", img.getPath());

        try {
            FileOutputStream fos = new FileOutputStream(img);
            bm.compress(Bitmap.CompressFormat.JPEG, 85, fos);
            fos.flush();
            fos.close();
            Log.e("IconCrop - save", "图片保存成功！");

            return Uri.fromFile(img);
        } catch (FileNotFoundException e) {
            Log.e("IconCrop - save", "图片保存失败！");
            e.printStackTrace();
            return null;
        } catch (IOException e) {
            e.printStackTrace();
            return null;
        }
    }

    public Uri getRealPathFromURI(Context context, Uri contentUri) {
        String[] proj = {MediaStore.Images.Media.DATA};
        @SuppressWarnings("deprecation")
        ContentResolver cr = context.getContentResolver();
        Cursor cursor = cr.query(contentUri, proj, null, null, null);
        int column_index;
        if (cursor != null) {
            try {
                column_index = cursor.getColumnIndexOrThrow(MediaStore.Images.Media.DATA);
                cursor.moveToFirst();
                String imgPath = cursor.getString(column_index);
                File img = new File(imgPath);
                cursor.close();
                return Uri.fromFile(img);
            } catch (Exception e) {
                return null;
            }
        } else {
            return contentUri;
        }
    }

    private String uriToPath(Context context, Uri contentUri) {
        String[] proj = {MediaStore.Images.Media.DATA};
        @SuppressWarnings("deprecation")
        Cursor cursor = ((Activity) context).managedQuery(contentUri, proj, null, null, null);
        int column_index;
        if (cursor != null) {
            try {
                column_index = cursor.getColumnIndexOrThrow(MediaStore.Images.Media.DATA);
                cursor.moveToFirst();
                String imgPath = cursor.getString(column_index);
                cursor.close();
                return imgPath;
            } catch (Exception e) {
                return null;
            }
        } else {
            return null;
        }
    }

    private File createImageFile(Context context, Uri contentUri) {
        String[] proj = {MediaStore.Images.Media.DATA};
        @SuppressWarnings("deprecation")
        Cursor cursor = ((Activity) context).managedQuery(contentUri, proj, null, null, null);
        int column_index;
        if (cursor != null) {
            try {
                column_index = cursor.getColumnIndexOrThrow(MediaStore.Images.Media.DATA);
                cursor.moveToFirst();
                String imgPath = cursor.getString(column_index);
                cursor.close();
                return new File(imgPath);
            } catch (Exception e) {
                return null;
            }
        } else {
            return null;
        }
    }

    private Uri getImageContentUri(Context context, File imageFile) {
        String filePath = imageFile.getAbsolutePath();
        Cursor cursor = context.getContentResolver().query(MediaStore.Images.Media.EXTERNAL_CONTENT_URI, new String[]{MediaStore.Images.Media._ID},
                MediaStore.Images.Media.DATA + "=? ", new String[]{filePath}, null);
        if (cursor != null && cursor.moveToFirst()) {
            int id = cursor.getInt(cursor.getColumnIndex(MediaStore.MediaColumns._ID));
            Uri baseUri = Uri.parse("content://media/external/images/media");
            cursor.close();
            return Uri.withAppendedPath(baseUri, "" + id);
        } else {
            if (imageFile.exists()) {
                ContentValues values = new ContentValues();
                values.put(MediaStore.Images.Media.DATA, filePath);
                return context.getContentResolver().insert(MediaStore.Images.Media.EXTERNAL_CONTENT_URI, values);
            } else {
                return null;
            }
        }
    }
}
