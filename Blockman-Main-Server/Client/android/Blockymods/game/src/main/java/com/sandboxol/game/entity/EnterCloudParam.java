package com.sandboxol.game.entity;

import com.google.gson.annotations.SerializedName;

/**
 * Created by luoweiyi on 16/1/7.
 */
public class EnterCloudParam {

    @SerializedName("name")
    private String nickName;

    @SerializedName("pic")
    private String picUrl;


    public String getNickName() {
        return nickName;
    }

    public void setNickName(String nickName) {
        this.nickName = nickName;
    }

    public String getPicUrl() {
        return picUrl;
    }

    public void setPicUrl(String picUrl) {
        this.picUrl = picUrl;
    }

}
