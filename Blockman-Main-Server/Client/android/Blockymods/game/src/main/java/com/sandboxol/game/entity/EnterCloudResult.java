package com.sandboxol.game.entity;

import com.google.gson.annotations.SerializedName;

import java.util.List;

/**
 * Created by Mr.Luo on 16/5/11.
 */
public class EnterCloudResult {

    @SerializedName("code")
    private int code;
    @SerializedName("hall")
    private String hall;
    @SerializedName("token")
    private String token;

    @SerializedName("gameId")
    private String gameId;

    @SerializedName("info")
    private String info;

    @SerializedName("gaddr")
    private String gameAddress;

    @SerializedName("gtoken")
    private String gameToken;

    @SerializedName("gdata")
    private GameData gameData;

    @SerializedName("users")
    private List<UserData> userList;


    public int getCode() {
        return code;
    }

    public void setCode(int code) {
        this.code = code;
    }

    public String getHall() {
        return hall;
    }

    public void setHall(String hall) {
        this.hall = hall;
    }

    public String getToken() {
        return token;
    }

    public void setToken(String token) {
        this.token = token;
    }

    public String getGameId() {
        return gameId;
    }

    public void setGameId(String gameId) {
        this.gameId = gameId;
    }

    public String getInfo() {
        return info;
    }

    public void setInfo(String info) {
        this.info = info;
    }

    public String getGameAddress() {
        return gameAddress;
    }

    public void setGameAddress(String gameAddress) {
        this.gameAddress = gameAddress;
    }

    public String getGameToken() {
        return gameToken;
    }

    public void setGameToken(String gameToken) {
        this.gameToken = gameToken;
    }

    public GameData getGameData() {
        return gameData;
    }

    public void setGameData(GameData gameData) {
        this.gameData = gameData;
    }

    public List<UserData> getUserList() {
        return userList;
    }

    public void setUserList(List<UserData> userList) {
        this.userList = userList;
    }
}
