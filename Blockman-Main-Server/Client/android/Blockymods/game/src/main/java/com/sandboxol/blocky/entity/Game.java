package com.sandboxol.blocky.entity;

import java.util.List;

/**
 * Created by Bob on 2017/10/31.
 */
public class Game {

    private String gameId;
    private String gameTitle;
    private String gameName;
    private String gameCoverPic;
    private List<String> bannerPic;
    private String gameDetail;
    private List<String> gameTypes;
    private int praiseNumber;
    private boolean appreciate;
    private int onlineNumber;
    private int gameMode;

    public String getGameId() {
        return gameId;
    }

    public void setGameId(String gameId) {
        this.gameId = gameId;
    }

    public String getGameTitle() {
        return gameTitle;
    }

    public void setGameTitle(String gameTitle) {
        this.gameTitle = gameTitle;
    }

    public String getGameCoverPic() {
        return gameCoverPic;
    }

    public void setGameCoverPic(String gameCoverPic) {
        this.gameCoverPic = gameCoverPic;
    }

    public List<String> getBannerPic() {
        return bannerPic;
    }

    public void setBannerPic(List<String> bannerPic) {
        this.bannerPic = bannerPic;
    }

    public String getGameDetail() {
        return gameDetail;
    }

    public void setGameDetail(String gameDetail) {
        this.gameDetail = gameDetail;
    }

    public List<String> getGameTypes() {
        return gameTypes;
    }

    public void setGameTypes(List<String> gameTypes) {
        this.gameTypes = gameTypes;
    }

    public int getPraiseNumber() {
        return praiseNumber;
    }

    public void setPraiseNumber(int praiseNumber) {
        this.praiseNumber = praiseNumber;
    }

    public boolean isAppreciate() {
        return appreciate;
    }

    public void setAppreciate(boolean appreciate) {
        this.appreciate = appreciate;
    }

    public int getOnlineNumber() {
        return onlineNumber;
    }

    public void setOnlineNumber(int onlineNumber) {
        this.onlineNumber = onlineNumber;
    }

    public String getGameName() {
        return gameName;
    }

    public void setGameName(String gameName) {
        this.gameName = gameName;
    }

    public int getGameMode() {
        return gameMode;
    }

    public void setGameMode(int gameMode) {
        this.gameMode = gameMode;
    }
}
