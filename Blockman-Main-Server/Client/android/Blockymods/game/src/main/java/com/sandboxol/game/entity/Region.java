package com.sandboxol.game.entity;

import android.text.TextUtils;

/**
 * Created by Mr.Luo on 16/2/27.
 */
public class Region {

    private int id;
    private String ip;
    private String ping;
    private String name;
    private String hallCreator;
    private String hallEnter;
    private String hallQuerier;
    private String bulletin;
    private String mgsqueue;
    private String mgsteam;
    private String msgOrganizeTeam;
    private String msgBlockManOrganizeTeam;

    public int getId() {
        return id;
    }

    public void setId(int id) {
        this.id = id;
    }

    public String getIp() {
        return ip;
    }

    public void setIp(String ip) {
        this.ip = ip;
    }

    public String getPing() {
        return TextUtils.isEmpty(ping) ? "10" : ping;
    }

    public void setPing(String ping) {
        this.ping = ping;
    }

    public String getName() {
        return name;
    }

    public void setName(String name) {
        this.name = name;
    }

    public String getHallCreator() {
        return hallCreator;
    }

    public void setHallCreator(String hallCreator) {
        this.hallCreator = hallCreator;
    }

    public String getHallEnter() {
        return hallEnter;
    }

    public void setHallEnter(String hallEnter) {
        this.hallEnter = hallEnter;
    }

    public String getHallQuerier() {
        return hallQuerier;
    }

    public void setHallQuerier(String hallQuerier) {
        this.hallQuerier = hallQuerier;
    }

    public String getBulletin() {
        return bulletin;
    }

    public void setBulletin(String bulletin) {
        this.bulletin = bulletin;
    }

    public String getMgsQueue() {
        return mgsqueue;
    }

    public String getMgsTeam() {
        return mgsteam;
    }

    public void setMgsQueue(String mgsQueue) {
        this.mgsqueue = mgsQueue;
    }

    public void setMgsTeam(String mgTeam) {
        this.mgsteam = mgTeam;
    }

    public String getMsgOrganizeTeam() {
        return msgOrganizeTeam;
    }

    public void setMsgOrganizeTeam(String msgOrganizeTeam) {
        this.msgOrganizeTeam = msgOrganizeTeam;
    }

    public String getMsgBlockManOrganizeTeam() {
        return msgBlockManOrganizeTeam;
    }

    public void setMsgBlockManOrganizeTeam(String msgBlockManOrganizeTeam) {
        this.msgBlockManOrganizeTeam = msgBlockManOrganizeTeam;
    }
}
