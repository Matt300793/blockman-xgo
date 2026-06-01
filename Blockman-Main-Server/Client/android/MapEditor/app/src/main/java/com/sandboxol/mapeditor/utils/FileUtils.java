/* 
 * Copyright (C) 2007-2008 OpenIntents.org
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

package com.sandboxol.mapeditor.utils;

import android.content.Context;
import android.content.res.XmlResourceParser;
import android.database.Cursor;
import android.net.Uri;
import android.provider.MediaStore.Audio;
import android.provider.MediaStore.Video;
import android.text.format.Formatter;
import android.util.Log;

import com.sandboxol.mapeditor.R;
import com.sandboxol.mapeditor.config.FileConstant;
import com.sandboxol.mapeditor.entity.MimeTypeParser;
import com.sandboxol.mapeditor.entity.MimeTypes;

import java.io.File;
import java.io.FileFilter;
import java.io.FileInputStream;
import java.io.FileOutputStream;
import java.io.IOException;
import java.net.URISyntaxException;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.Collections;
import java.util.Comparator;
import java.util.List;


/**
 * @author Peli
 * @version 2009-07-03
 */
public class FileUtils {
    /**
     * TAG for log messages.
     */
    static final String TAG = "FileUtils";
    private static final boolean DEBUG = false; // Set to true to enable logging

    public static final String MIME_TYPE_AUDIO = "audio/*";
    public static final String MIME_TYPE_TEXT = "text/*";
    public static final String MIME_TYPE_IMAGE = "images/*";
    public static final String MIME_TYPE_VIDEO = "video/*";
    public static final String MIME_TYPE_APP = "application/*";

    public static final String EXTRA_MIME_TYPES = "net.zhuoweizhang.afilechooser.extra.MIME_TYPES";
    public static final String EXTRA_SORT_METHOD = "net.zhuoweizhang.afilechooser.extra.SORT_METHOD";
    public static final String SORT_LAST_MODIFIED = "net.zhuoweizhang.afilechooser.extra.SORT_LAST_MODIFIED";

    public static String getFileSizeWithByte(Context context, Long initialSize) {
        String sizeText = "0";
        if (initialSize != null && initialSize >= 0) {
            sizeText = Formatter.formatFileSize(context, initialSize);
        }
        return sizeText;
    }

    public static long getFolderSize(File file) {
        long size = 0;
        try {
            File[] fileList = file.listFiles();
            for (File child : fileList) {
                if (child.isDirectory()) {
                    size = size + getFolderSize(child);
                } else {
                    size = size + child.length();
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return size;
    }

    public static long getFileSize(File file) {
        long size = 0;
        if (file.exists()) {
            try {
                FileInputStream fis = new FileInputStream(file);
                size = fis.available();
                file.createNewFile();
            } catch (IOException e) {
                e.printStackTrace();
            }
        } else {
            Log.e("获取文件大小", "文件不存在!");
        }
        return size;
    }

    /**
     * Whether the URI is a local one.
     *
     * @param uri
     * @return
     */
    public static boolean isLocal(String uri) {
        if (uri != null && !uri.startsWith("http://")) {
            return true;
        }
        return false;
    }

    /**
     * Gets the extension of a file name, like ".png" or ".jpg".
     *
     * @param uri
     * @return Extension including the dot("."); "" if there is no extension;
     * null if uri was null.
     */
    public static String getExtension(String uri) {
        if (uri == null) {
            return null;
        }

        int dot = uri.lastIndexOf(".");
        if (dot >= 0) {
            return uri.substring(dot);
        } else {
            // No extension.
            return "";
        }
    }

    /**
     * Returns true if uri is a media uri.
     *
     * @param uri
     * @return
     */
    public static boolean isMediaUri(Uri uri) {
        String uriString = uri.toString();
        if (uriString.startsWith(Audio.Media.INTERNAL_CONTENT_URI.toString())
                || uriString.startsWith(Audio.Media.EXTERNAL_CONTENT_URI.toString())
                || uriString.startsWith(Video.Media.INTERNAL_CONTENT_URI.toString())
                || uriString.startsWith(Video.Media.EXTERNAL_CONTENT_URI.toString())) {
            return true;
        } else {
            return false;
        }
    }

    /**
     * Convert File into Uri.
     *
     * @param file
     * @return uri
     */
    public static Uri getUri(File file) {
        if (file != null) {
            return Uri.fromFile(file);
        }
        return null;
    }

    /**
     * Convert Uri into File.
     *
     * @param uri
     * @return file
     */
    public static File getFile(Uri uri) {
        if (uri != null) {
            String filepath = uri.getPath();
            if (filepath != null) {
                return new File(filepath);
            }
        }
        return null;
    }

    /**
     * Returns the image only (without file name).
     *
     * @param file
     * @return
     */
    public static File getPathWithoutFilename(File file) {
        if (file != null) {
            if (file.isDirectory()) {
                // no file to be split off. Return everything
                return file;
            } else {
                String filename = file.getName();
                String filepath = file.getAbsolutePath();

                // Construct image without file name.
                String path = filepath.substring(0, filepath.length() - filename.length());
                if (path.endsWith("/")) {
                    path = path.substring(0, path.length() - 1);
                }
                return new File(path);
            }
        }
        return null;
    }

    /**
     * Constructs a file from a image and file name.
     *
     * @param curdir
     * @param file
     * @return
     */
    public static File getFile(String curdir, String file) {
        String separator = "/";
        if (curdir.endsWith("/")) {
            separator = "";
        }
        File clickedFile = new File(curdir + separator
                + file);
        return clickedFile;
    }

    public static File getFile(File curdir, String file) {
        return getFile(curdir.getAbsolutePath(), file);
    }

    /**
     * Get a file image from a Uri.
     *
     * @param context
     * @param uri
     * @return
     * @throws URISyntaxException
     * @author paulburke
     */
    public static String getPath(Context context, Uri uri) throws URISyntaxException {
        if ("content".equalsIgnoreCase(uri.getScheme())) {
            String[] projection = {"_data"};
            Cursor cursor = null;
            try {
                cursor = context.getContentResolver().query(uri, projection, null, null, null);
                if (cursor != null) {
                    int column_index = cursor.getColumnIndexOrThrow("_data");
                    if (cursor.moveToFirst()) {
                        return cursor.getString(column_index);
                    }
                    cursor.close();
                }
            } catch (Exception e) {
                if (cursor != null) {
                    cursor.close();
                }
            }
        } else if ("file".equalsIgnoreCase(uri.getScheme())) {
            return uri.getPath();
        }
        return null;
    }

    /**
     * Load MIME types from XML
     *
     * @param context
     * @return
     */
    private static MimeTypes getMimeTypes(Context context) {
        MimeTypes mimeTypes = null;
        final MimeTypeParser mtp = new MimeTypeParser();
        final XmlResourceParser in = context.getResources().getXml(R.xml.mimetypes);

        try {
            mimeTypes = mtp.fromXmlResource(in);
        } catch (Exception e) {
            if (DEBUG) Log.e(TAG, "getMimeTypes", e);
        }
        return mimeTypes;
    }

    /**
     * Get the file MIME type
     *
     * @param context
     * @param file
     * @return
     */
    public static String getMimeType(Context context, File file) {
        String mimeType = null;
        final MimeTypes mimeTypes = getMimeTypes(context);
        if (file != null) mimeType = mimeTypes.getMimeType(file.getName());
        return mimeType;
    }

    private static final String HIDDEN_PREFIX = ".";

    /**
     * File and folder comparator.
     * TODO Expose sorting option method
     *
     * @author paulburke
     */
    private static Comparator<File> comparator = (f1, f2) -> {
        // Sort alphabetically by lower case, which is much cleaner
        return f1.getName().toLowerCase().compareTo(f2.getName().toLowerCase());
    };

    /**
     * File (not directories) filter.
     *
     * @author paulburke
     */
    private static FileFilter fileFilter = file -> {
        final String fileName = file.getName();
        // Return files only (not directories) and skip hidden files
        return file.isFile() && !fileName.startsWith(HIDDEN_PREFIX);
    };

    /**
     * Folder (directories) filter.
     *
     * @author paulburke
     */
    private static FileFilter dirFilter = file -> {
        final String fileName = file.getName();
        return file.isDirectory() && !fileName.startsWith(HIDDEN_PREFIX);
    };

    /**
     * Get a list of Files in the give image
     *
     * @param path
     * @return Collection of files in give directory
     * @author paulburke
     */
    public static List<File> getFileList(String path) {
        ArrayList<File> list = new ArrayList<>();

        // Current directory File instance
        final File pathDir = new File(path);

        // List file in this directory with the directory filter
        final File[] dirs = pathDir.listFiles(dirFilter);
        if (dirs != null) {
            // Sort the folders alphabetically
            Arrays.sort(dirs, comparator);
            // Add each folder to the File list for the list adapter
            Collections.addAll(list, dirs);
        }

        // List file in this directory with the file filter
        final File[] files = pathDir.listFiles(fileFilter);
        if (files != null) {
            // Sort the files alphabetically
            Arrays.sort(files, comparator);
            // Add each file to the File list for the list adapter
            Collections.addAll(list, files);
        }

        return list;
    }

    // 删除文件夹及文件夹里面所有的文件
    public static void deleteFolder(File file) {
        if (file.exists()) {
            if (file.isFile()) {
                file.delete();
                return;
            }
            if (file.isDirectory()) {
                File[] childFile = file.listFiles();
                if (childFile == null || childFile.length == 0) {
                    file.delete();
                    return;
                }
                for (File f : childFile) {
                    deleteFolder(f);
                }
                file.delete();
            }
        }
    }

    public static void renameFile(File file, File target) {
        if (file.exists())
            file.renameTo(target);
    }

    public static boolean copyFolder(String source, String target) {
        boolean result = true;
        try {
            new File(target).mkdirs();
            // 如果文件夹不存在 则建立新文件夹
            File a = new File(source);
            String[] file = a.list();
            File temp;
            for (String child : file) {
                if (source.endsWith(File.separator)) {
                    temp = new File(source + child);
                } else {
                    temp = new File(source + File.separator + child);
                }
                if (temp.isFile()) {
                    FileInputStream input = new FileInputStream(temp);
                    FileOutputStream output = new FileOutputStream(target + "/" + temp.getName(), false);
                    byte[] b = new byte[1024 * 5];
                    int len;
                    while ((len = input.read(b)) != -1) {
                        output.write(b, 0, len);
                    }
                    output.flush();
                    output.close();
                    input.close();
                }
                if (temp.isDirectory()) {
                    // 如果是子文件夹，递归调用copyFolder
                    copyFolder(source + "/" + child, target + "/" + child);
                }
            }
        } catch (Exception e) {
            Log.e("copyFolder", "copy folder error", e);
            result = false;
        }
        return result;
    }

}
