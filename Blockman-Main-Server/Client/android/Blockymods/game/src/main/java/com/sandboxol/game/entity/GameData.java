package com.sandboxol.game.entity;

import com.google.gson.annotations.SerializedName;

/**
 * Created by luoweiyi on 16/1/7.
 */
public class GameData {

    @SerializedName("hid")
    private long hostId;

    @SerializedName("size")
    private long mapSize;

    @SerializedName("crtt")
    private long createTime;

    @SerializedName("id")
    private String id;

    @SerializedName("name")
    private String name;

    @SerializedName("pic")
    private String picUrl;

    @SerializedName("ver")
    private String gameVersion;

    @SerializedName("ping")
    private int ping;

    @SerializedName("pri")
    private int pri;

    @SerializedName("net")
    private int netType;

    @SerializedName("pend")
    private int suspend;

    @SerializedName("type")
    private int gameType;

    @SerializedName("max")
    private int maxGuest;

    @SerializedName("cur")
    private int curGuest;

    @SerializedName("lev")
    private int level;

    @SerializedName("hostName")
    private String hostName;

    @SerializedName("novst")
    private int noVisitor;

    @SerializedName("vip")
    private int vip;

    @SerializedName("showType")
    private int showType;

    @SerializedName("gla")
    private int charmRank;

    @SerializedName("ctrb")
    private int contributionRank;

    @SerializedName("nlev")
    private int lv;

    @SerializedName("cupid")
    private String cupId;

    @SerializedName("isspecial")
    private boolean isSpecial;

    public GameData() {
    }

    public GameData(int type) {
        this.showType = type;
    }

    public String getHostName() {
        return hostName;
    }

    public void setHostName(String hostName) {
        this.hostName = hostName;
    }

    public long getHostId() {
        return hostId;
    }

    public void setHostId(long hostId) {
        this.hostId = hostId;
    }

    public long getCreateTime() {
        return createTime;
    }

    public void setCreateTime(long createTime) {
        this.createTime = createTime;
    }

    public String getId() {
        return id;
    }

    public void setId(String id) {
        this.id = id;
    }

    public String getName() {
        return name;
    }

    public void setName(String name) {
        this.name = name;
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

    public int getPing() {
        return ping;
    }

    public void setPing(int ping) {
        this.ping = ping;
    }

    public int getPri() {
        return pri;
    }

    public void setPri(int pri) {
        this.pri = pri;
    }

    public long getMapSize() {
        return mapSize;
    }

    public void setMapSize(long mapSize) {
        this.mapSize = mapSize;
    }

    public int getNetType() {
        return netType;
    }

    public void setNetType(int netType) {
        this.netType = netType;
    }

    public int getSuspend() {
        return suspend;
    }

    public void setSuspend(int suspend) {
        this.suspend = suspend;
    }

    public int getGameType() {
        return gameType;
    }

    public void setGameType(int gameType) {
        this.gameType = gameType;
    }

    public int getMaxGuest() {
        return maxGuest;
    }

    public void setMaxGuest(int maxGuest) {
        this.maxGuest = maxGuest;
    }

    public int getCurGuest() {
        return curGuest;
    }

    public void setCurGuest(int curGuest) {
        this.curGuest = curGuest;
    }

    public int getLevel() {
        return level;
    }

    public void setLevel(int level) {
        this.level = level;
    }

    public boolean isVip() {
        return vip != 0;
    }

    public void setVip(int vip) {
        this.vip = vip;
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

    public int getShowType() {
        return showType;
    }

    public void setShowType(int showType) {
        this.showType = showType;
    }

    public int getCharmRank() {
        return charmRank;
    }

    public int getContributionRank() {
        return contributionRank;
    }

    public int getCharmOrContributionRank() {
        if (charmRank != 0 && contributionRank != 0) {
            return Math.min(charmRank, contributionRank);
        }
        return Math.max(charmRank, contributionRank);
    }

    public boolean isCharm() {
        if (charmRank != 0 && contributionRank != 0) {
            return charmRank < contributionRank;
        }
        return charmRank > contributionRank;
    }

    public int getLv() {
        return lv;
    }

    public void setLv(int lv) {
        this.lv = lv;
    }

    public boolean isShowNewLv() {
        return lv >= level;
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
