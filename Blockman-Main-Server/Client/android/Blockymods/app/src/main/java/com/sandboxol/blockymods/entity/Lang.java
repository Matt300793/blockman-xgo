package com.sandboxol.blockymods.entity;

/**
 * Created by Mr.Luo on 2017/1/18.
 */

public class Lang {

    private String lang;
    private String name;
    private String desc;
    private String groupName;

    private String notice;
    private String normal;
    private String forcible;

    public String getLang() {
        return lang;
    }

    public void setLang(String lang) {
        this.lang = lang;
    }

    public String getName() {
        return name;
    }

    public void setName(String name) {
        this.name = name;
    }

    public String getGroupName() {
        return groupName;
    }

    public void setGroupName(String groupName) {
        this.groupName = groupName;
    }

    public String getDesc() {
        return desc;
    }

    public void setDesc(String desc) {
        this.desc = desc;
    }


    public String getNormal() {
        return normal;
    }

    public void setNormal(String normal) {
        this.normal = normal;
    }

    public String getForcible() {
        return forcible;
    }

    public void setForcible(String forcible) {
        this.forcible = forcible;
    }

    public String getNotice() {
        return notice;
    }

    public void setNotice(String notice) {
        this.notice = notice;
    }
}
