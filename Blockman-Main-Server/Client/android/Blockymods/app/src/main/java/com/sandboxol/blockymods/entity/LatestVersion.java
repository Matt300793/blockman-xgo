package com.sandboxol.blockymods.entity;

import com.sandboxol.common.utils.CommonHelper;

import java.util.ArrayList;
import java.util.List;
import java.util.Map;

/**
 * Created by ender on 12/31/15.
 */
public class LatestVersion {

    private String picUrl;
    private String apkUrl;
    private String apkMd5;
    private String updateInfo = "";
    private int newVersionCode = 0;
    private int smallerThanVersion = 0;
    private int forceUpdateMinVersionCode = 0;
    private int forceUpdateMaxVersionCode = 0;
    private List<String> needTobeForceUpdateVersions;

    //Version Code 441之后的版本添加字段
    private Map<String, Lang> langMap;
    private String content;


    public String getUpdateInfo() {
        return updateInfo;
    }

    public String getPicUrl() {
        return picUrl;
    }

    public void setPicUrl(String picUrl) {
        this.picUrl = picUrl;
    }


    public int getNewVersionCode() {
        return newVersionCode;
    }

    public int getSmallerThanVersion() {
        return smallerThanVersion;
    }

    public int getForceUpdateMinVersionCode() {
        return forceUpdateMinVersionCode;
    }


    public int getForceUpdateMaxVersionCode() {
        return forceUpdateMaxVersionCode;
    }

    public String getApkUrl() {
        return apkUrl;
    }

    public void setApkUrl(String apkUrl) {
        this.apkUrl = apkUrl;
    }

    public String getApkMd5() {
        return apkMd5;
    }

    public void setApkMd5(String apkMd5) {
        this.apkMd5 = apkMd5;
    }

    public List<String> getNeedTobeForceUpdateVersions() {
        if (needTobeForceUpdateVersions == null)
            needTobeForceUpdateVersions = new ArrayList<>();
        return needTobeForceUpdateVersions;
    }

    public String getContent(boolean forcible) {
        if (langMap != null && content == null) {
            Lang lang = langMap.get(CommonHelper.getLanguage());
            if (lang == null) {
                lang = langMap.get("en_US");
            }
            if (lang != null) {
                content = forcible ? lang.getForcible() : lang.getNormal();
            }
        }
        if (content == null) {
            content = getUpdateInfo();
        }
        return content;
    }

}
