package com.sandboxol.blockymods;

import com.sandboxol.blockymods.entity.AccountCenter;
import com.sandboxol.blockymods.entity.VisitorCenter;
import com.sandboxol.common.base.app.BaseApplication;
import com.tendcloud.tenddata.TCAgent;

/**
 * Created by Bob on 2017/10/14
 */
public class App extends BaseApplication {

    @Override
    public void onCreate() {
        super.onCreate();
        initLoadDate();
    }

    private void initLoadDate() {
        ChannelController.newInstance();
        AccountCenter.getAccountInfo();
        VisitorCenter.getVisitorInfo();

        //Talking Data
        TCAgent.init(this.getApplicationContext(), getContext().getResources().getString(R.string.td_app_id), "play.google.com");
        TCAgent.setReportUncaughtExceptions(true);
        CrashHandler.netInstance(this);
    }
}
