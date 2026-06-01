package com.sandboxol.blockymods.entity;

/**
 * Created by Jimmy on 2017/9/27 0027.
 */
public class AppConfig {

    private boolean isShowThirdPart;//是否显示第三方登录

    public boolean isShowThirdPart() {
        return isShowThirdPart;
    }

    public void setShowThirdPart(boolean showThirdPart) {
        isShowThirdPart = showThirdPart;
    }
}
