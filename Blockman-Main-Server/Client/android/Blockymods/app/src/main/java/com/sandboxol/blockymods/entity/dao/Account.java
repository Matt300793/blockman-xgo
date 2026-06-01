package com.sandboxol.blockymods.entity.dao;

import org.greenrobot.greendao.annotation.Entity;
import org.greenrobot.greendao.annotation.Id;
import org.greenrobot.greendao.annotation.Generated;

/**
 * Created by Bob on 2017/10/25.
 */
@Entity
public class Account {

    @Id
    private Long id;
    private String token;
    private String nickName;
    private int sex;
    private String details;
    private String picUrl;

    @Generated(hash = 243715070)
    public Account(Long id, String token, String nickName, int sex, String details,
            String picUrl) {
        this.id = id;
        this.token = token;
        this.nickName = nickName;
        this.sex = sex;
        this.details = details;
        this.picUrl = picUrl;
    }

    @Generated(hash = 882125521)
    public Account() {
    }

    public Long getId() {
        return this.id;
    }

    public void setId(Long id) {
        this.id = id;
    }

    public String getToken() {
        return this.token;
    }

    public void setToken(String token) {
        this.token = token;
    }

    public String getNickName() {
        return this.nickName;
    }

    public void setNickName(String nickName) {
        this.nickName = nickName;
    }

    public int getSex() {
        return this.sex;
    }

    public void setSex(int sex) {
        this.sex = sex;
    }

    public String getDetails() {
        return this.details;
    }

    public void setDetails(String details) {
        this.details = details;
    }

    public String getPicUrl() {
        return this.picUrl;
    }

    public void setPicUrl(String picUrl) {
        this.picUrl = picUrl;
    }
}
