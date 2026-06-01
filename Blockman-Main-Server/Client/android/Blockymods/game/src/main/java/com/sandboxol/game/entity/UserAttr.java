package com.sandboxol.game.entity;

/**
 * Created by Mr.Luo on 16/8/8.
 */
public class UserAttr {

    private long id;
    private int lv;
    private int vip;
    private int prr;
    private int spp;
    private int rid;
    private int clz;
    private int multiexp;

    private float att;
    private float def;
    private float heal;

    private String name;
    private String title;

    public int getClz() {
        return clz;
    }

    public void setClz(int clz) {
        this.clz = clz;
    }

    public long getId() {
        return id;
    }

    public void setId(long id) {
        this.id = id;
    }

    public int getVip() {
        return vip;
    }

    public void setVip(int vip) {
        this.vip = vip;
    }

    public int getPrr() {
        return prr;
    }

    public void setPrr(int prr) {
        this.prr = prr;
    }

    public String getName() {
        return name;
    }

    public void setName(String name) {
        this.name = name;
    }

    public int getSpp() {
        return spp;
    }

    public void setSpp(int spp) {
        this.spp = spp;
    }

    public float getAtt() {
        return att;
    }

    public void setAtt(float att) {
        this.att = att;
    }

    public float getDef() {
        return def;
    }

    public void setDef(float def) {
        this.def = def;
    }

    public float getHeal() {
        return heal;
    }

    public void setHeal(float heal) {
        this.heal = heal;
    }

    public int getMultiexp() {
        return multiexp;
    }

    public void setMultiexp(int multiexp) {
        this.multiexp = multiexp;
    }

    public int getLv() {
        return lv;
    }

    public void setLv(int lv) {
        this.lv = lv;
    }

    public int getRid() {
        return rid;
    }

    public void setRid(int rid) {
        this.rid = rid;
    }

    public String getTitle() {
        return title;
    }

    public void setTitle(String title) {
        this.title = title;
    }
}
