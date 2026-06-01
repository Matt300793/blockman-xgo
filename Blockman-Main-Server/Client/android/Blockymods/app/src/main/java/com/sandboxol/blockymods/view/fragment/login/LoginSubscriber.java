package com.sandboxol.blockymods.view.fragment.login;

import com.google.gson.Gson;
import com.sandboxol.common.base.web.BaseSubscriber;
import com.sandboxol.common.base.web.HttpResponse;
import com.sandboxol.common.base.web.OnResponseListener;
import com.sandboxol.common.config.HttpCode;

/**
 * Created by Jimmy on 2017/11/29 0029.
 */
public class LoginSubscriber<T, R extends HttpResponse<T>> extends BaseSubscriber<T, R> {

    public LoginSubscriber(OnResponseListener<T> listener) {
        super(listener);
    }

    @Override
    public void onNext(R response) {
        if (listener != null) {
            if (response.getCode() == HttpCode.SUCCESS) {
                listener.onSuccess(response.getData());
            } else if (response.getCode() == 1002) {
                listener.onError(response.getCode(), new Gson().toJson(response.getData()));
            } else {
                listener.onError(response.getCode(), response.getMsg());
            }
        }
    }

    @Override
    public boolean isCheckNetwork() {
        return false;
    }
}
