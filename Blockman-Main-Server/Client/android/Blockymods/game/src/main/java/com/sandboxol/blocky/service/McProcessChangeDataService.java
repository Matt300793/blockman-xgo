package com.sandboxol.blocky.service;

import android.app.Service;
import android.content.Intent;
import android.os.IBinder;
import android.os.RemoteException;

import com.sandboxol.game.IMcProcessChangeDataInterface;

/**
 * Created by Mr.Luo on 2016/12/14.
 */

public class McProcessChangeDataService extends Service {

    public McProcessChangeDataService() {
    }

    @Override
    public IBinder onBind(Intent intent) {
        return mBinder;
    }

    private final IMcProcessChangeDataInterface.Stub mBinder = new IMcProcessChangeDataInterface.Stub() {

        @Override
        public void buildRewardSettlement(int gold, int experience, int activeValues) throws RemoteException {

        }

        @Override
        public void onlineTimeSettlement(int lv, int maxExp, int exp) throws RemoteException {

        }

        @Override
        public void doHeartBeat() throws RemoteException {

        }
    };

    @Override
    public void onDestroy() {
        super.onDestroy();
    }
}
