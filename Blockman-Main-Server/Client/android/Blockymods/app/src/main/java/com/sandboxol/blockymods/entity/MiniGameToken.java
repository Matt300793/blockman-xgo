package com.sandboxol.blockymods.entity;

/**
 * Created by Bob on 2017/11/16.
 */
public class MiniGameToken {

    private String token;
    private String signature;
    private long timestamp;

    public String getToken() {
        return token;
    }

    public String getSignature() {
        return signature;
    }

    public long getTimestamp() {
        return timestamp;
    }
}
