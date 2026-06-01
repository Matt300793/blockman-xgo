package com.sandboxol.game.entity;

import com.google.gson.annotations.SerializedName;

/**
 * Created by luoweiyi on 16/1/7.
 */
public class CreateGameResult {

    @SerializedName("code")
    private int code;

    @SerializedName("info")
    private String info;

    @SerializedName("gameaddr")
    private String gameAddr;

    @SerializedName("hosttoken")
    private String hostToken;

    @SerializedName("hostname")
    private String hostName;

    @SerializedName("gameMode")
    private int gameMode;

    @SerializedName("game")
    private GameData gameData;

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

    public String getHostToken() {
        return hostToken;
    }

    public void setHostToken(String hostToken) {
        this.hostToken = hostToken;
    }

    public GameData getGameData() {
        return gameData;
    }

    public void setGameData(GameData gameData) {
        this.gameData = gameData;
    }

    public String getHostName() {
        return hostName;
    }

    public void setHostName(String hostName) {
        this.hostName = hostName;
    }

    public int getGameMode() {
        return gameMode;
    }

    public void setGameMode(int gameMode) {
        this.gameMode = gameMode;
    }
}
