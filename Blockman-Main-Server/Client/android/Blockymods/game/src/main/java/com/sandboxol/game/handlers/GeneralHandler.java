package com.sandboxol.game.handlers;

import android.os.Handler;
import android.os.Message;

import com.sandboxol.game.interfaces.IHandlerMsgListener;

/**
 * Created by Mr.Luo on 16/5/24.
 */
public class GeneralHandler extends Handler {

    private IHandlerMsgListener mMsgListener;

    public GeneralHandler(IHandlerMsgListener msgListener) {
        this.mMsgListener = msgListener;
    }

    @Override
    public void handleMessage(Message msg) {
        super.handleMessage(msg);
        if (mMsgListener != null) {
            mMsgListener.onSendMsg(msg);
        }
    }
}
