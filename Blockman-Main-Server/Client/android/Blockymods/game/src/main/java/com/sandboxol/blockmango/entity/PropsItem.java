package com.sandboxol.blockmango.entity;

import java.io.Serializable;

/**
 * Created by Jimmy on 2016/8/15 0015.
 */
public class PropsItem implements Serializable {

    private String payType;
    private String propsId;
    private String propsName;
    private String propsDesc;
    private double propsPrice;
    private String propsType;
    private String propsTypeId;
    private String propsUrl;
    private int qty;
    private int number;
    private int limit;
    private int usageCount;
    private int vip;

    public String getPayType() {
        return payType;
    }

    public void setPayType(String payType) {
        this.payType = payType;
    }

    public String getPropsId() {
        return propsId;
    }

    public void setPropsId(String propsId) {
        this.propsId = propsId;
    }

    public String getPropsName() {
        return propsName;
    }

    public void setPropsName(String propsName) {
        this.propsName = propsName;
    }

    public String getPropsDesc() {
        return propsDesc;
    }

    public void setPropsDesc(String propsDesc) {
        this.propsDesc = propsDesc;
    }

    public double getPropsPrice() {
        return propsPrice;
    }

    public void setPropsPrice(double propsPrice) {
        this.propsPrice = propsPrice;
    }

    public String getPropsTypeId() {
        return propsTypeId;
    }

    public void setPropsTypeId(String propsTypeId) {
        this.propsTypeId = propsTypeId;
    }

    public String getPropsUrl() {
        return propsUrl;
    }

    public void setPropsUrl(String propsUrl) {
        this.propsUrl = propsUrl;
    }

    public int getQty() {
        return qty;
    }

    public void setQty(int qty) {
        this.qty = qty;
    }

    public String getPropsType() {
        return propsType;
    }

    public void setPropsType(String propsType) {
        this.propsType = propsType;
    }

    public int getNumber() {
        return number;
    }

    public void setNumber(int number) {
        this.number = number;
    }

    public int getLimit() {
        return limit;
    }

    public void setLimit(int limit) {
        this.limit = limit;
    }

    public int getUsageCount() {
        return usageCount;
    }

    public void setUsageCount(int usageCount) {
        this.usageCount = usageCount;
    }

    public int getVip() {
        return vip;
    }

    public void setVip(int vip) {
        this.vip = vip;
    }
}
