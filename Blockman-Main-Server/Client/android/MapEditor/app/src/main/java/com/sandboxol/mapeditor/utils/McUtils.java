package com.sandboxol.mapeditor.utils;

import android.content.Context;
import android.content.pm.PackageInfo;
import android.content.pm.PackageManager;
import android.os.Environment;
import android.text.TextUtils;

import com.sandboxol.common.utils.CommonHelper;
import com.sandboxol.mapeditor.R;
import com.sandboxol.mapeditor.config.FileConstant;
import com.sandboxol.mapeditor.config.StringConstant;
import com.sandboxol.mapeditor.entity.ApkVersion;
import com.sandboxol.mapeditor.entity.McVersion;

import java.util.List;

/**
 * Created by Jimmy on 2017/11/28 0028.
 */
public class McUtils {

    public static String getLocalMcPackageName(Context context) {
        PackageManager packageManager = context.getPackageManager();
        // 获取所有已安装程序的包信息
        List<PackageInfo> packages = packageManager.getInstalledPackages(0);
        for (String mc : StringConstant.MC_PACKAGES) {
            for (int i = 0; i < packages.size(); i++) {
                if (packages.get(i).packageName.equalsIgnoreCase(mc))
                    return mc;
            }
        }
        return null;
    }

    public static McVersion getMcVersion(Context context) {
        try {
            String version = "";
            int name = R.string.wy_minecraft, icon = R.mipmap.ic_wy_minecraft;
            PackageInfo packageInfo = null;
            String packageName = getLocalMcPackageName(context);
            if (!TextUtils.isEmpty(packageName)) {
                packageInfo = context.getPackageManager().getPackageInfo(packageName, 0);
                if (StringConstant.MINECRAFT_PACKAGE.equals(packageName)) {
                    icon = R.mipmap.ic_minecraft;
                    name = R.string.minecraft;
                } else {
                    icon = R.mipmap.ic_wy_minecraft;
                    name = R.string.wy_minecraft;
                }
            }
            if (packageInfo != null) {
                version = packageInfo.versionName;
                version = threeVersionMatch(version);
            }
            return new McVersion(name, version, icon);
        } catch (Exception e) {
            e.printStackTrace();
            return new McVersion(R.string.wy_minecraft, null, R.mipmap.ic_wy_minecraft);
        }
    }

    public static String getMcMapPath(Context context) {
        String packageName = getLocalMcPackageName(context);
        if (!TextUtils.isEmpty(packageName)) {
            if (StringConstant.MINECRAFT_PACKAGE.equals(packageName)) {
                return FileConstant.MINECRAFT_MAP_DIR;
            } else {
                return String.format(FileConstant.WY_MINECRAFT_MAP_DIR, packageName);
            }
        } else {
            return Environment.getExternalStorageDirectory().getPath();
        }
    }

    private static String threeVersionMatch(String version) {
        ApkVersion apkVersion = ApkVersion.fromVersionString(version);
        if (apkVersion.getTest() != 0)
            return apkVersion.getMajor() + "." + apkVersion.getMinor() + "." + apkVersion.getPatch() + "." + apkVersion.getTest();
        return apkVersion.getMajor() + "." + apkVersion.getMinor() + "." + apkVersion.getPatch();
    }

}
