package com.sandboxol.util;

import android.app.Activity;
import android.content.Context;
import android.os.Environment;

import org.apache.http.util.EncodingUtils;
import org.json.JSONException;
import org.json.JSONObject;
import org.json.JSONTokener;

import java.io.File;
import java.io.FileInputStream;
import java.io.FileNotFoundException;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.InputStream;
import java.io.OutputStream;

/**
 * Created by Administrator on 2017/12/15 0015.
 */

public class GameResCopy {

    private final static String ASSETS_NAME = "resources";
    private final static String VERSION_FILE_NAME = "res.version";
    private int m_nCopyedFileCount = 0;
    private int m_nTotalFileCount = 0;
    private Context mContext;
    private CopyListener mListener;

    public GameResCopy(Context cxt, CopyListener listener) {
        this.mContext = cxt;
        this.mListener = listener;
        new ChildThread().start();
    }

    private String getResPath() {
        return mContext.getDir(ASSETS_NAME, Context.MODE_WORLD_WRITEABLE).getPath() + "/";
    }

    private String getSDCardPath() {
        boolean sdCardExist = Environment.getExternalStorageState().equals(android.os.Environment.MEDIA_MOUNTED);
        return (sdCardExist ? new File(Environment.getExternalStorageDirectory(), "SandBoxOL/BlockMan").getPath() : mContext.getDir("BlockMan", Context.MODE_WORLD_WRITEABLE).getPath());
    }

    private String getConfigPath() {
        return getSDCardPath() + "/config/";
    }

    private void doCopyResAndCheckUpdate() {
        // copy resource
        if (checkNeedCopy()) {
            //delete old res
            delFolder(getResPath());
            m_nCopyedFileCount = 0;
            m_nTotalFileCount = getTotalFileCount(ASSETS_NAME);
            copyToSDCard(ASSETS_NAME, getResPath());
            //final version file copy
            copySingleFile(ASSETS_NAME, getResPath(), VERSION_FILE_NAME);
        }
        // currently no need to update. so send  HANDLER_COPY_COMPLETE Message.
//        Message msg = new Message();
//        msg.what = EchoesHandler.HANDLER_COPY_COMPLETE;
//        mHandler.sendMessage(msg);
        if (mContext instanceof Activity) {
            ((Activity)mContext).runOnUiThread(() -> mListener.copyDone());
        } else {
            mListener.copyDone();
        }
    }

    public boolean checkNeedCopy() {
        File file = new File(getResPath(), VERSION_FILE_NAME);

        if (file.exists()) {
            String[] oldVersionArray = new String[10];
            String[] newVersionArray = new String[10];

            // fist get the version from local file.
            try {
                FileInputStream fis = new FileInputStream(file);
                byte[] buffer = new byte[fis.available()];
                fis.read(buffer);
                fis.close();

                InputStream in = null;
                in = mContext.getAssets().open(ASSETS_NAME + "/" + VERSION_FILE_NAME);
                int n = in.available();
                byte[] newBuffer = new byte[n];
                in.read(newBuffer);
                in.close();

                String strOldJsonVersion = EncodingUtils.getString(buffer, "UTF-8");
                String strNewJsonVersion = EncodingUtils.getString(newBuffer, "UTF-8");

                JSONTokener jsonParser = new JSONTokener(strOldJsonVersion);
                JSONTokener newJsonParser = new JSONTokener(strNewJsonVersion);

                try {
                    JSONObject versionObj = (JSONObject) jsonParser.nextValue();

                    String strVersion = versionObj.getString("version");

                    oldVersionArray = strVersion.split("\\.");

                    JSONObject newVersionObj = (JSONObject) newJsonParser.nextValue();

                    strVersion = newVersionObj.getString("version");

                    newVersionArray = strVersion.split("\\.");

                    int nOldAppVersion0 = Integer.parseInt(oldVersionArray[0]);
                    int nNewAppVersion0 = Integer.parseInt(newVersionArray[0]);

                    int nOldAppVersion1 = Integer.parseInt(oldVersionArray[1]);
                    int nNewAppVersion1 = Integer.parseInt(newVersionArray[1]);

                    if (nNewAppVersion0 > nOldAppVersion0) {
                        return true;
                    } else if (nNewAppVersion0 == nOldAppVersion0) {
                        if (nNewAppVersion1 > nOldAppVersion1) {
                            return true;
                        } else {
                            return false;
                        }
                    } else {
                        return false;
                    }
                } catch (JSONException ex) {
                    return true;
                }
            } catch (FileNotFoundException e) {
                e.printStackTrace();
                return true;
            } catch (IOException e) {
                e.printStackTrace();
                return true;
            }
        } else {
            // there is no version file in sd-card. need copy first.
            return true;
        }
    }

    private void delFolder(String folderPath) {
        try {
            // first delete all files in this folder.
            delAllFile(folderPath);
            String filePath = folderPath;
            filePath = filePath.toString();
            java.io.File myFilePath = new java.io.File(filePath);
            myFilePath.delete();
        } catch (Exception e) {
            System.out.println("can not delete forlder");
            e.printStackTrace();
        }
    }

    /**
     * delete all the file and folders in path.
     *
     * @param path String
     */
    private void delAllFile(String path) {
        File file = new File(path);
        if (!file.exists()) {
            return;
        }
        if (!file.isDirectory()) {
            return;
        }

        String[] tempList = file.list();
        File temp = null;
        for (int i = 0; i < tempList.length; i++) {
            if (path.endsWith(File.separator)) {
                temp = new File(path + tempList[i]);
            } else {
                temp = new File(path + File.separator + tempList[i]);
            }
            if (temp.isFile()) {
                temp.delete();
            }
            if (temp.isDirectory()) {
                delAllFile(path + "/" + tempList[i]);// recursive call to delete the folder's files.
                delFolder(path + "/" + tempList[i]);// delete the folder.
            }
        }
    }

    private int getTotalFileCount(String strAssetDir) {
        int nFileCount = 0;
        String[] files;
        try {
            files = mContext.getResources().getAssets().list(strAssetDir);
        } catch (IOException e1) {
            return 0;
        }
        int nCount = files.length;
        for (int i = 0; i < nCount; i++) {
            String fileName = files[i];
            // we make sure file name not contains '.' to be a folder.
            if (!fileName.contains(".")) {
                nFileCount += getTotalFileCount(strAssetDir + "/" + fileName);
                continue;
            } else {
                ++nFileCount;
            }
        }
        return nFileCount;
    }

    private void copyToSDCard(String strAssetDir, String strRootDir) {
        String[] files;
        try {
            files = mContext.getResources().getAssets().list(strAssetDir);
        } catch (IOException e1) {
            return;
        }
        File mWorkingPath = new File(strRootDir);
        // if this directory does not exists, make one.
        if (!mWorkingPath.exists()) {
            mWorkingPath.mkdirs();
        }
        int nCount = files.length;
        for (int i = 0; i < nCount; i++) {
            String fileName = files[i];
            if (fileName.contains(".version")) {
                continue;
            }
            // we make sure file name not contains '.' to be a folder.
            if (!fileName.contains(".")) {
                // recursive call to copy folder.
                copyToSDCard(strAssetDir + "/" + fileName, strRootDir + fileName + "/");
                continue;
            }

            copySingleFile(strAssetDir, strRootDir, fileName);
        }
    }

    private void copySingleFile(String strAssetDir, String strRootPath, String strFileName) {
        try {
            File outFile = new File(strRootPath, strFileName);
            InputStream in = null;
            in = mContext.getAssets().open(strAssetDir + "/" + strFileName);
            OutputStream out = new FileOutputStream(outFile, true);

            // Transfer bytes from in to out
            byte[] buf = new byte[1024 * 5];
            int len;
            while ((len = in.read(buf)) > 0) {
                out.write(buf, 0, len);
            }

            in.close();
            out.close();

            ++m_nCopyedFileCount;
        } catch (FileNotFoundException e) {
            e.printStackTrace();
        } catch (IOException e) {
            e.printStackTrace();
        }

        if (mContext instanceof Activity) {
            ((Activity)mContext).runOnUiThread(() -> mListener.copyProgress(m_nCopyedFileCount, m_nTotalFileCount));
        } else {
            mListener.copyProgress(m_nCopyedFileCount, m_nTotalFileCount);
        }
    }

    class ChildThread extends Thread {
        public void run() {
            doCopyResAndCheckUpdate();
        }
    }

    public interface CopyListener {
        public void copyDone();
        public void copyFailed();
        public void copyProgress(int copyFileCount, int totalFileCount);
    }

}

