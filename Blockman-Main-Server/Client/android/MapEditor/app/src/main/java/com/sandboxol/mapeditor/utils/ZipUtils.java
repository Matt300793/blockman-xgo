package com.sandboxol.mapeditor.utils;

import android.text.TextUtils;

import com.file.zip.ZipEntry;
import com.file.zip.ZipFile;
import com.file.zip.ZipOutputStream;

import java.io.BufferedInputStream;
import java.io.BufferedOutputStream;
import java.io.File;
import java.io.FileInputStream;
import java.io.FileNotFoundException;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.InputStream;
import java.util.Enumeration;

import retrofit2.http.HTTP;

/**
 * Created by Jimmy on 2016/5/30 0030.
 */
public class ZipUtils {

    /**
     * 解压缩一个文件
     *
     * @param file 压缩文件
     * @param dir  解压缩的目标目录
     */
    public static boolean upZipFile(File file, String dir) {
        try {
            ZipFile zipFile = new ZipFile(file, "UTF-8");
            Enumeration<ZipEntry> entries = zipFile.getEntries();
            ZipEntry zipEntry;
            File tmpFile;
            BufferedOutputStream bos;
            InputStream is;
            byte[] buf = new byte[1024];
            int len;
            while (entries.hasMoreElements()) {
                zipEntry = entries.nextElement();
                tmpFile = new File(dir, zipEntry.getName());
                if (zipEntry.isDirectory()) {
                    continue;
                }
                if (!tmpFile.getParentFile().exists()) {
                    tmpFile.getParentFile().mkdirs();
                }
                if (!tmpFile.exists()) {
                    tmpFile.createNewFile();
                }
                is = zipFile.getInputStream(zipEntry);
                bos = new BufferedOutputStream(new FileOutputStream(tmpFile));
                while ((len = is.read(buf)) > 0) {
                    bos.write(buf, 0, len);
                }
                bos.flush();
                bos.close();
            }
            zipFile.close();
            return true;
        } catch (IOException e) {
            e.printStackTrace();
            return false;
        }
    }

    public static String getZipRootFileName(File file) {
        try {
            ZipFile zipFile = new ZipFile(file, "UTF-8");
            Enumeration<ZipEntry> entries = zipFile.getEntries();
            if (entries.hasMoreElements()) {
                ZipEntry zipEntry = entries.nextElement();
                return zipEntry.getName();
            }
            return null;
        } catch (IOException e) {
            e.printStackTrace();
            return null;
        }
    }

    /**
     * 压缩文件
     *
     * @param resFile 需要压缩的文件（夹）
     * @param target  压缩的文件路径
     */
    public static boolean zipFile(File resFile, String target) {
        try {
            File zipFile = new File(target, resFile.getName() + ".zip");
            zipFile.createNewFile();
            FileOutputStream fos = new FileOutputStream(zipFile);
            ZipOutputStream zos = new ZipOutputStream(fos);
            boolean result = zipFile(resFile, zos, "");
            zos.close();
            fos.close();
            return result;
        } catch (Exception e) {
            e.printStackTrace();
            return false;
        }
    }

    /**
     * 压缩文件
     *
     * @param resFile  需要压缩的文件（夹）
     * @param zipOut   压缩的目的文件
     * @param rootPath 压缩的文件路径
     */
    public static boolean zipFile(File resFile, ZipOutputStream zipOut, String rootPath) {
        try {
            rootPath = rootPath + (rootPath.trim().length() == 0 ? "" : File.separator) + resFile.getName();
            if (resFile.isDirectory()) {
                zipOut.putNextEntry(new ZipEntry(rootPath + File.separator));
                File[] fileList = resFile.listFiles();
                for (File file : fileList) {
                    zipFile(file, zipOut, rootPath);
                }
            } else {
                byte buffer[] = new byte[1024];
                BufferedInputStream in = new BufferedInputStream(new FileInputStream(resFile), 1024);
                zipOut.putNextEntry(new ZipEntry(rootPath));
                int realLength;
                while ((realLength = in.read(buffer)) != -1) {
                    zipOut.write(buffer, 0, realLength);
                }
                in.close();
                zipOut.flush();
                zipOut.closeEntry();
            }
            return true;
        } catch (Exception e) {
            return false;
        }
    }

}
