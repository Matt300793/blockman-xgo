package com.sandboxol.blockymods.entity;

import com.google.gson.annotations.SerializedName;

/**
 * Created by Bob on 2017/11/16
 */
public class Dispatch {

    @SerializedName("code")
    public int code;

    @SerializedName("gaddr")
    public String gAddr;

    @SerializedName("name")
    public String name;

    @SerializedName("signature")
    public String signature;

    @SerializedName("croomid")
    public String chatRoomId;

    @SerializedName("timestamp")
    public long timestamp;

    @SerializedName("mname")
    public String mapName;

    @SerializedName("downurl")
    public String mapUrl;
}
