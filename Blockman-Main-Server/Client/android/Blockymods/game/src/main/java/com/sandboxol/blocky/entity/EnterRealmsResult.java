package com.sandboxol.blocky.entity;

import com.sandboxol.blockmango.entity.*;

import java.util.List;

/**
 * Created by Mr.Luo on 16/8/10.
 */
public class EnterRealmsResult {

    private long userId;
    private int gameMode;

    private String gameAddr;
    private String userName;
    private String userToken;
    private long timestamp;
    private String chatRoomId;
    private String mapName;
    private String mapUrl;
    private Game game;
    private List<Talent> talents;

    public long getUserId() {
        return userId;
    }

    public void setUserId(long userId) {
        this.userId = userId;
    }

    public String getGameAddr() {
        return gameAddr;
    }

    public void setGameAddr(String gameAddr) {
        this.gameAddr = gameAddr;
    }

    public String getUserName() {
        return userName;
    }

    public void setUserName(String userName) {
        this.userName = userName;
    }

    public String getUserToken() {
        return userToken;
    }

    public void setUserToken(String userToken) {
        this.userToken = userToken;
    }

    public Game getGame() {
        return game;
    }

    public void setGame(Game realms) {
        this.game = realms;
    }

    public List<Talent> getTalents() {
        return talents;
    }

    public void setTalents(List<Talent> talents) {
        this.talents = talents;
    }


    public int getGameMode() {
        return gameMode;
    }

    public void setGameMode(int gameMode) {
        this.gameMode = gameMode;
    }

    public long getTimestamp() {
        return timestamp;
    }

    public void setTimestamp(long timestamp) {
        this.timestamp = timestamp;
    }

    public String getChatRoomId() {
        return chatRoomId;
    }

    public void setChatRoomId(String chatRoomId) {
        this.chatRoomId = chatRoomId;
    }

    public String getMapName() {
        return mapName;
    }

    public void setMapName(String mapName) {
        this.mapName = mapName;
    }

    public String getMapUrl() {
        return mapUrl;
    }

    public void setMapUrl(String mapUrl) {
        this.mapUrl = mapUrl;
    }
}
