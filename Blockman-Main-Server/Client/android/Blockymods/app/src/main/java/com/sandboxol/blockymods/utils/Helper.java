package com.sandboxol.blockymods.utils;

import android.content.Context;

import com.sandboxol.blockymods.entity.AccountCenter;
import com.sandboxol.blockymods.entity.LoginRegisterAccountForm;
import com.sandboxol.common.utils.CommonHelper;

/**
 * Created by Bob on 2017/11/20.
 */

public class Helper {
    public static void getSystemInfo(Context context, LoginRegisterAccountForm form) {
        //获取手机IMEI
        String uid = CommonHelper.getDeviceId(context);
        if (uid == null) {
            form.setImei(String.valueOf(AccountCenter.newInstance().userId.get()));
        } else {
            form.setImei(uid);
        }
        //OS版本(系统版本 eg. 7.0)
        form.setOs(android.os.Build.VERSION.RELEASE);
        //手机型号
        form.setDeviceId("Android:" + android.os.Build.MODEL);
    }
}
