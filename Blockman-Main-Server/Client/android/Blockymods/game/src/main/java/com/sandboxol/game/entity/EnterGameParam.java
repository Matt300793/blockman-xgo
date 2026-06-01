package com.sandboxol.game.entity;

import com.google.gson.annotations.SerializedName;

/**
 * Created by luoweiyi on 16/1/7.
 */
public class EnterGameParam {

    @SerializedName("gname")
    private String guestNickName;

    @SerializedName("gpic")
    private String guestPicUrl;

    @SerializedName("gexp")
    private int guestExp;

    @SerializedName("glev")
    private int guestLevel;

    @SerializedName("id")
    private String gameId;

    @SerializedName("pass")
    private String password;

    @SerializedName("ver")
    private String gameVersion;

    @SerializedName("vip")
    private int vip;

    public EnterGameParam() {
    }

    public EnterGameParam(String guestNickName, String guestPicUrl, int guestExp, int guestLevel, String gameId, String password, String gameVersion) {
        this.guestNickName = guestNickName;
        this.guestPicUrl = guestPicUrl;
        this.guestExp = guestExp;
        this.guestLevel = guestLevel;
        this.gameId = gameId;
        this.password = password;
        this.gameVersion = gameVersion;
    }

    public String getGuestNickName() {
        return guestNickName;
    }

    public void setGuestNickName(String guestNickName) {
        this.guestNickName = guestNickName;
    }

    public String getGuestPicUrl() {
        return guestPicUrl;
    }

    public void setGuestPicUrl(String guestPicUrl) {
        this.guestPicUrl = guestPicUrl;
    }

    public int getGuestExp() {
        return guestExp;
    }

    public void setGuestExp(int guestExp) {
        this.guestExp = guestExp;
    }

    public int getGuestLevel() {
        return guestLevel;
    }

    public void setGuestLevel(int guestLevel) {
        this.guestLevel = guestLevel;
    }

    public String getGameId() {
        return gameId;
    }

    public void setGameId(String gameId) {
        this.gameId = gameId;
    }

    public String getPassword() {
        return password;
    }

    public void setPassword(String password) {
        this.password = password;
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
}
