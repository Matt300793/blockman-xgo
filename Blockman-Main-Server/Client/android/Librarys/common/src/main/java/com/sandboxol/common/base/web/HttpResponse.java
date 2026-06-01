package com.sandboxol.common.base.web;

import com.sandboxol.common.config.HttpCode;

/**
 * Created by Jimmy on 2017/9/27 0027.
 */
public class HttpResponse<D> {

    private int code;
    private String msg;
    private D data;

    public int getCode() {
        return code;
    }

    public void setCode(int code) {
        this.code = code;
    }

    public String getMsg() {
        return msg;
    }

    public void setMsg(String msg) {
        this.msg = msg;
    }

    public D getData() {
        return data;
    }

    public void setData(D data) {
        this.data = data;
    }

    public boolean isSuccess() {
        return code == HttpCode.SUCCESS;
    }

    public boolean isFailed() {
        return code != HttpCode.SUCCESS;
    }

}
