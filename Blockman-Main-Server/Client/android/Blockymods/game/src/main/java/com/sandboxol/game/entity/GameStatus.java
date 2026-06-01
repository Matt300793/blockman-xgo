package com.sandboxol.game.entity;

import com.google.gson.annotations.SerializedName;

/**
 * Created by Mr.Luo on 16/3/1.
 */
public class GameStatus {

    @SerializedName("a")
    private int curGuest;

    @SerializedName("b")
    private int ping;

    @SerializedName("c")
    private int suspend;

    public int getCurGuest() {
        return curGuest;
    }

    public void setCurGuest(int curGuest) {
        this.curGuest = curGuest;
    }

    public int getPing() {
        return ping;
    }

    public void setPing(int ping) {
        this.ping = ping;
    }

    public int getSuspend() {
        return suspend;
    }

    public void setSuspend(int suspend) {
        this.suspend = suspend;
    }
}
