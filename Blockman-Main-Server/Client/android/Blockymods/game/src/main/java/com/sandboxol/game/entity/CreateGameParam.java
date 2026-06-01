package com.sandboxol.game.entity;

import com.google.gson.annotations.SerializedName;

import java.util.List;

/**
 * Created by luoweiyi on 16/1/7.
 */
public class CreateGameParam {

    @SerializedName("hname")
    private String hostNickName;

    @SerializedName("hpic")
    private String hostPicUrl;

    @SerializedName("hexp")
    private int hostExp;

    @SerializedName("hlev")
    private int hostLevel;

    @SerializedName("pass")
    private String password;

    @SerializedName("name")
    private String roomName;

    @SerializedName("pic")
    private String picUrl;

    @SerializedName("ver")
    private String gameVersion;

    @SerializedName("type")
    private int gameType;

    @SerializedName("size")
    private int mapSize;

    @SerializedName("max")
    private int maxGuest;

    @SerializedName("bls")
    private List<Long> bls;

    @SerializedName("novst")
    private int noVisitor;

    @SerializedName("vip")
    private int vip;

    @SerializedName("hctrb")
    private int contributionRank;

    @SerializedName("hgla")
    private int charmRank;

    @SerializedName("hnlev")
    private int lv;

    @SerializedName("cupid")
    private String cupId;

    @SerializedName("isspecial")
    private boolean isSpecial;

    public String getHostNickName() {
        return hostNickName;
    }

    public void setHostNickName(String hostNickName) {
        this.hostNickName = hostNickName;
    }

    public String getHostPicUrl() {
        return hostPicUrl;
    }

    public void setHostPicUrl(String hostPicUrl) {
        this.hostPicUrl = hostPicUrl;
    }

    public int getHostExp() {
        return hostExp;
    }

    public void setHostExp(int hostExp) {
        this.hostExp = hostExp;
    }

    public int getHostLevel() {
        return hostLevel;
    }

    public void setHostLevel(int hostLevel) {
        this.hostLevel = hostLevel;
    }

    public String getPassword() {
        return password;
    }

    public void setPassword(String password) {
        this.password = password;
    }

    public String getRoomName() {
        return roomName;
    }

    public void setRoomName(String roomName) {
        this.roomName = roomName;
    }

    public String getPicUrl() {
        return picUrl;
    }

    public void setPicUrl(String picUrl) {
        this.picUrl = picUrl;
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

    public int getMapSize() {
        return mapSize;
    }

    public void setMapSize(int mapSize) {
        this.mapSize = mapSize;
    }

    public int getMaxGuest() {
        return maxGuest;
    }

    public void setMaxGuest(int maxGuest) {
        this.maxGuest = maxGuest;
    }

    public List<Long> getBls() {
        return bls;
    }

    public void setBls(List<Long> bls) {
        this.bls = bls;
    }

    public void setVip(boolean isVip) {
        this.vip = isVip ? 1 : 0;
    }

    public int getNoVisitor() {
        return noVisitor;
    }

    public void setNoVisitor(int noVisitor) {
        this.noVisitor = noVisitor;
    }

    public int getVip() {
        return vip;
    }

    public void setVip(int vip) {
        this.vip = vip;
    }

    public int getCharmRank() {
        return charmRank;
    }

    public void setCharmRank(int charmRank) {
        this.charmRank = charmRank;
    }

    public int getLv() {
        return lv;
    }

    public void setLv(int lv) {
        this.lv = lv;
    }

    public void setContributionRank(int contributionRank) {
        this.contributionRank = contributionRank;
    }

    public String getCupId() {
        return cupId;
    }

    public void setCupId(String cupId) {
        this.cupId = cupId;
    }

    public boolean isSpecial() {
        return isSpecial;
    }

    public void setSpecial(boolean special) {
        isSpecial = special;
    }
}
