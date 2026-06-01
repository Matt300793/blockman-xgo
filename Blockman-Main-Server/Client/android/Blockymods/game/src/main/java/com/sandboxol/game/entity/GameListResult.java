package com.sandboxol.game.entity;

import com.google.gson.annotations.SerializedName;

import java.util.List;

/**
 * Created by luoweiyi on 16/1/7.
 */
public class GameListResult {

    @SerializedName("code")
    private int code;

    @SerializedName("info")
    private String info;

    @SerializedName("Itor")
    private String iTor;

    @SerializedName("games")
    private List<GameData> gameList;

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

    public String getITor() {
        return iTor;
    }

    public void setiTor(String iTor) {
        this.iTor = iTor;
    }

    public List<GameData> getGameList() {
        return gameList;
    }

    public void setGameList(List<GameData> gameList) {
        this.gameList = gameList;
    }
}
