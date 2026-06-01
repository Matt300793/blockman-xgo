package com.sandboxol.mapeditor;

import com.sandboxol.common.base.app.BaseApplication;
import com.tendcloud.tenddata.TCAgent;

/**
 * Created by Bob on 2017/10/14.
 */
public class App extends BaseApplication {

    @Override
    public void onCreate() {
        super.onCreate();
        initLoadDate();
    }

    private void initLoadDate() {
        TCAgent.init(this.getApplicationContext(), getContext().getResources().getString(R.string.td_app_id), "TalkingData");
        TCAgent.setReportUncaughtExceptions(true);
    }
}
