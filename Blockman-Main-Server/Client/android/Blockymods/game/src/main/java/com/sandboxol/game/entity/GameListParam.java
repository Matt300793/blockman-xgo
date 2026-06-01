package com.sandboxol.game.entity;

import com.google.gson.annotations.SerializedName;

/**
 * Created by luoweiyi on 16/1/7.
 */
public class GameListParam {

    @SerializedName("itor")
    private String iTor;

    @SerializedName("ver")
    private String gameVersion;

    @SerializedName("type")
    private int gameType;

    public String getiTor() {
        return iTor;
    }

    public void setiTor(String iTor) {
        this.iTor = iTor;
    }

    public String getGameVersion() {
        return gameVersion;
    }

    public void setGameVersion(String gameVersion) {
        this.gameVersion = gameVersion;
    }

    public int getGameType() {
        return gameType;
    }

    public void setGameType(int gameType) {
        this.gameType = gameType;
    }
}
