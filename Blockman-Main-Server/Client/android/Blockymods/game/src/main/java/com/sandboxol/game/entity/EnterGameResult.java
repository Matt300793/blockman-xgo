package com.sandboxol.game.entity;

import com.google.gson.annotations.SerializedName;

import java.util.List;

/**
 * Created by luoweiyi on 16/1/7.
 */
public class EnterGameResult {

    @SerializedName("code")
    private int code;

    @SerializedName("info")
    private String info;

    @SerializedName("gameaddr")
    private String gameAddr;

    @SerializedName("guesttoken")
    private String guestToken;

    @SerializedName("hosttoken")
    private String hostToken;

    @SerializedName("hostname")
    private String hostName;

    @SerializedName("game")
    private GameData gameData;

    @SerializedName("guestname")
    private String guestName;

    @SerializedName("users")
    private List<UserData> userList;

    public int getCode() {
        return code;
    }

    public void setCode(int code) {
        this.code = code;
    }

    public String getInfo() {
        return info;
    }

    public void setInfo(String info) {
        this.info = info;
    }

    public String getGameAddr() {
        return gameAddr;
    }

    public void setGameAddr(String gameAddr) {
        this.gameAddr = gameAddr;
    }

    public GameData getGameData() {
        return gameData;
    }

    public void setGameData(GameData gameData) {
        this.gameData = gameData;
    }

    public String getGuestToken() {
        return guestToken;
    }

    public void setGuestToken(String guestToken) {
        this.guestToken = guestToken;
    }

    public List<UserData> getUserList() {
        return userList;
    }

    public void setUserList(List<UserData> userList) {
        this.userList = userList;
    }

    public String getGuestName() {
        return guestName;
    }

    public String getHostToken() {
        return hostToken;
    }

    public void setHostToken(String hostToken) {
        this.hostToken = hostToken;
    }

    public void setGuestName(String guestName) {
        this.guestName = guestName;
    }

    public String getHostName() {
        return hostName;
    }

    public void setHostName(String hostName) {
        this.hostName = hostName;
    }
}
