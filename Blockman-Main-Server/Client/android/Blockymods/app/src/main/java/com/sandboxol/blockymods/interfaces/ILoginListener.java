package com.sandboxol.blockymods.interfaces;

/**
 * Created by Bob on 2017/11/22.
 */
public interface ILoginListener {
    void loginSuccessful(String userId, String userName, String token, String loginType);

    void loginSuccessful(String userId, String userName, String picUrl, String token, String loginType);

    void loginFailure();

}
