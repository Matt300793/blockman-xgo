package com.sandboxol.blockmango.entity;

import java.io.Serializable;
import java.util.ArrayList;
import java.util.List;

/**
 * Created by Jimmy on 2016/8/1 0001.
 */
public class Realms implements Serializable {

    private int minNum;
    private int gameMode;
    private int appVersionCode;

    private boolean isAd;
    private boolean isShowJob;
    private boolean isShowRankList;
    private boolean isShowCultivate;
    private boolean isStartBlockMan;
    private boolean isStartBlockManOverseas;
    private boolean isShowSuperPlayer;

    private String type;
    private String mapId;
    private String icon;
    private String desc;
    private String typeName;
    private String gameName;
    private String bgColor;
    private String defaultMcVersion;
    private int onlineNum;

    private List<String> descIcons;
    private List<String> props;

    private List<PropsItem> propsList;
    private List<String> versions;
    private List<String> unShowRegion;
    private List<String> showRewardType;

    public int getAppVersionCode() {
        return appVersionCode;
    }

    public void setAppVersionCode(int appVersionCode) {
        this.appVersionCode = appVersionCode;
    }

    public int getMinNum() {
        return minNum;
    }

    public void setMinNum(int minNum) {
        this.minNum = minNum;
    }

    public String getType() {
        return type;
    }

    public void setType(String type) {
        this.type = type;
    }

    public String getTypeName() {
        return typeName;
    }

    public void setTypeName(String typeName) {
        this.typeName = typeName;
    }

    public String getGameName() {
        return gameName;
    }

    public void setGameName(String gameName) {
        this.gameName = gameName;
    }

    public String getMapId() {
        return mapId;
    }

    public void setMapId(String mapId) {
        this.mapId = mapId;
    }

    public String getIcon() {
        return icon;
    }

    public void setIcon(String icon) {
        this.icon = icon;
    }

    public String getDesc() {
        return desc;
    }

    public void setDesc(String desc) {
        this.desc = desc;
    }

    public List<String> getDescIcons() {
        return descIcons;
    }

    public void setDescIcons(List<String> descIcons) {
        this.descIcons = descIcons;
    }

    public List<PropsItem> getPropsList() {
        return propsList == null ? new ArrayList<PropsItem>() : propsList;
    }

    public void setPropsList(List<PropsItem> propsList) {
        this.propsList = propsList;
    }

    public boolean isShowRankList() {
        return isShowRankList;
    }

    public void setShowRankList(boolean showRankList) {
        isShowRankList = showRankList;
    }

    public List<String> getProps() {
        return props;
    }

    public void setProps(List<String> props) {
        this.props = props;
    }

    public List<String> getVersions() {
        return versions;
    }

    public int getGameMode() {
        return gameMode;
    }

    public void setGameMode(int gameMode) {
        this.gameMode = gameMode;
    }

    public void setVersions(List<String> versions) {
        this.versions = versions;
    }

    public boolean isShowJob() {
        return isShowJob;
    }

    public void setShowJob(boolean showJob) {
        isShowJob = showJob;
    }

    public boolean isShowCultivate() {
        return isShowCultivate;
    }

    public void setShowCultivate(boolean showCultivate) {
        isShowCultivate = showCultivate;
    }

    public boolean isShowSuperPlayer() {
        return isShowSuperPlayer;
    }

    public void setShowSuperPlayer(boolean showSuperPlayer) {
        isShowSuperPlayer = showSuperPlayer;
    }

    public boolean isAd() {
        return isAd;
    }

    public void setAd(boolean ad) {
        isAd = ad;
    }

    public List<String> getUnShowRegion() {
        return unShowRegion;
    }

    public void setUnShowRegion(List<String> unShowRegion) {
        this.unShowRegion = unShowRegion;
    }

    public boolean getIsAd() {
        return this.isAd;
    }

    public void setIsAd(boolean isAd) {
        this.isAd = isAd;
    }

    public boolean getIsShowJob() {
        return this.isShowJob;
    }

    public void setIsShowJob(boolean isShowJob) {
        this.isShowJob = isShowJob;
    }

    public boolean getIsShowRankList() {
        return this.isShowRankList;
    }

    public void setIsShowRankList(boolean isShowRankList) {
        this.isShowRankList = isShowRankList;
    }

    public boolean getIsShowCultivate() {
        return this.isShowCultivate;
    }

    public void setIsShowCultivate(boolean isShowCultivate) {
        this.isShowCultivate = isShowCultivate;
    }

    public boolean getIsShowSuperPlayer() {
        return this.isShowSuperPlayer;
    }

    public void setIsShowSuperPlayer(boolean isShowSuperPlayer) {
        this.isShowSuperPlayer = isShowSuperPlayer;
    }

    public String getBgColor() {
        return this.bgColor;
    }

    public void setBgColor(String bgColor) {
        this.bgColor = bgColor;
    }

    public String getDefaultMcVersion() {
        return this.defaultMcVersion;
    }

    public void setDefaultMcVersion(String defaultMcVersion) {
        this.defaultMcVersion = defaultMcVersion;
    }

    public List<String> getShowRewardType() {
        return showRewardType;
    }

    public void setShowRewardType(List<String> showRewardType) {
        this.showRewardType = showRewardType;
    }

    public int getOnlineNum() {
        return onlineNum;
    }

    public void setOnlineNum(int onlineNum) {
        this.onlineNum = onlineNum;
    }



    public boolean getIsStartBlockMan() {
        return this.isStartBlockMan;
    }



    public void setIsStartBlockMan(boolean isStartBlockMan) {
        this.isStartBlockMan = isStartBlockMan;
    }

    public boolean isStartBlockMan() {
        return isStartBlockMan;
    }

    public boolean isStartBlockManOverseas() {
        return isStartBlockManOverseas;
    }

    public boolean getIsStartBlockManOverseas() {
        return this.isStartBlockManOverseas;
    }

    public void setIsStartBlockManOverseas(boolean isStartBlockManOverseas) {
        this.isStartBlockManOverseas = isStartBlockManOverseas;
    }
}
