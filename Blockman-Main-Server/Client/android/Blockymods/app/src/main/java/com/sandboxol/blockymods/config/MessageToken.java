package com.sandboxol.blockymods.config;

/**
 * Created by Bob on 2017/10/18
 */
public interface MessageToken {

    String TOKEN_CHANGE_LOGIN_OR_REGISTER = "token.change.login.or.register";
    String TOKEN_ACCOUNT = "token.account";//账号信息更改
    String TOKEN_LOGIN_REGISTER_SUCCESS = "token.login.register.success";//登录或注册成功返回到首页
    String TOKEN_REGISTER_SUCCESS = "token.register.success";//注册成功，显示账号密码截图消息
    String TOKEN_SHOW_LATELY_FRIEND_VIEW = "token.show.lately.friend.view";
    String TOKEN_REFRESH_CATEGORY_TYPE = "token.refresh.category.type";
    String TOKEN_REFRESH_RECOMMEND_TYPE = "token.refresh.recommend.type";
    String TOKEN_REFRESH_LATELY_TYPE = "token.refresh.lately.type";
    String TOKEN_STOP_TIMER = "token.stop.timer";
    String TOKEN_CHANGE_SEX = "token.change.sex";

    String TOKEN_REFRESH_DECORATION_TYPE = "token.refresh.decoration.type";
    String TOKEN_DECORATION_LOADING_FINISH_TYPE = "token.decoration.loading.finish.type";
    String TOKEN_APP_CHECK_UPDATE = "token.app.check.update";
}
