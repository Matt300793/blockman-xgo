package com.sandboxol.common.base.web;


import com.sandboxol.common.base.app.BaseApplication;
import com.sandboxol.common.config.CommonMessageToken;
import com.sandboxol.common.config.HttpCode;
import com.sandboxol.common.messenger.Messenger;
import com.sandboxol.common.utils.NetworkUtil;

import java.net.ConnectException;
import java.net.SocketTimeoutException;
import java.net.UnknownHostException;

import retrofit2.adapter.rxjava.HttpException;
import rx.Subscriber;

/**
 * Created by Jimmy on 2017/11/17 0017.
 */
public abstract class BaseSubscriber<T, R extends HttpResponse<T>> extends Subscriber<R> {

    protected OnResponseListener<T> listener;

    public BaseSubscriber(OnResponseListener<T> listener) {
        this.listener = listener;
    }

    @Override
    public void onCompleted() {

    }

    @Override
    public void onError(Throwable e) {
        if (listener != null) {
            if (e instanceof HttpException) {
                int error = ((HttpException) e).code();
                if (error == HttpCode.AUTH_FAILED) {
                    Messenger.getDefault().sendNoMsg(CommonMessageToken.TOKEN_REPEAT_LOGIN);
                }
                listener.onServerError(error);
            } else if (e instanceof ConnectException || e instanceof UnknownHostException) {
                listener.onServerError(HttpCode.NO_CONNECTED);
            } else if (e instanceof SocketTimeoutException) {
                listener.onServerError(HttpCode.TIMEOUT);
            } else {
                listener.onServerError(HttpCode.UN_KNOW);
            }
        }
    }

    @Override
    public void onNext(R response) {
        if (listener != null) {
            if (response.getCode() == HttpCode.SUCCESS) {
                listener.onSuccess(response.getData());
            } else {
                listener.onError(response.getCode(), response.getMsg());
            }
        }
    }

    @Override
    public void onStart() {
        super.onStart();
        if (!isCheckNetwork())
            return;
        if (!NetworkUtil.isNetworkConnected(BaseApplication.getContext())) {
            onError(new ConnectException("no connect exception"));
        }
    }

    public abstract boolean isCheckNetwork();

}
