package com.sandboxol.game.entity;

import com.google.gson.annotations.SerializedName;

/**
 * Created by luoweiyi on 16/1/7.
 */
public class EnterGameSexMatchParam {

    @SerializedName("gname")
    private String guestNickName;

    @SerializedName("gpic")
    private String guestPicUrl;

    @SerializedName("ver")
    private String gameVersion;

    @SerializedName("vip")
    private int vip;

    public EnterGameSexMatchParam() {
    }

    public EnterGameSexMatchParam(String guestNickName, String gameVersion, String guestPicurl) {
        this.guestNickName = guestNickName;
        this.guestPicUrl = guestPicurl;
        this.gameVersion = gameVersion;
    }

    public String getGuestNickName() {
        return guestNickName;
    }

    public void setGuestNickName(String guestNickName) {
        this.guestNickName = guestNickName;
    }

    public String getGameVersion() {
        return gameVersion;
    }

    public void setGameVersion(String gameVersion) {
        this.gameVersion = gameVersion;
    }

    public void setVip(boolean isVip) {
        this.vip = isVip ? 1 : 0;
    }

    public int getVip() {
        return vip;
    }

    public void setVip(int vip) {
        this.vip = vip;
    }

    public String getGuestPicUrl() {
        return guestPicUrl;
    }

    public void setGuestPicUrl(String guestPicUrl) {
        this.guestPicUrl = guestPicUrl;
    }
}
