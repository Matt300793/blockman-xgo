package com.sandboxol.blockymods.view.activity.main;

import android.content.Context;
import android.util.Log;

import com.sandboxol.blockymods.BuildConfig;
import com.sandboxol.blockymods.R;
import com.sandboxol.blockymods.config.SharedConstant;
import com.sandboxol.blockymods.config.StringConstant;
import com.sandboxol.blockymods.entity.AppConfig;
import com.sandboxol.blockymods.entity.LatestVersion;
import com.sandboxol.blockymods.view.dialog.CheckAppVersionDialog;
import com.sandboxol.blockymods.web.UserApi;
import com.sandboxol.common.base.web.OnResponseListener;
import com.sandboxol.common.utils.SharedUtils;
import com.sandboxol.common.utils.ToastUtils;

/**
 * Created by Bob on 2017/11/21
 */
public class MainModel {

    private boolean mIsManualCheck = false;//是否手动更新

    void loadAppConfig(Context context) {
        UserApi.loadAppConfig(context, new OnResponseListener<AppConfig>() {
            @Override
            public void onSuccess(AppConfig data) {
                SharedUtils.putBoolean(context, SharedConstant.APP_CONFIG_SHOW_THIRD_PART_LOGIN, data.isShowThirdPart());
            }

            @Override
            public void onError(int code, String msg) {

            }

            @Override
            public void onServerError(int error) {

            }
        });
    }

    public void checkAppVersion(Context context, boolean isManualCheck) {
        mIsManualCheck = isManualCheck;
        UserApi.checkAppVersion(new OnResponseListener<LatestVersion>() {
            @Override
            public void onSuccess(LatestVersion data) {
                checkAppVersionDialog(context, data);
            }

            @Override
            public void onError(int code, String msg) {
                ToastUtils.showLongToast(context, R.string.dialog_check_app_version_failed);
            }

            @Override
            public void onServerError(int error) {
                ToastUtils.showLongToast(context, R.string.dialog_check_app_version_failed);
            }
        });
    }

    private void checkAppVersionDialog(Context context, LatestVersion version) {
        try {
            if (version == null)
                return;
            int cVersion = BuildConfig.VERSION_CODE;
            //是否强制更新
            boolean isForceUpdate = cVersion < version.getSmallerThanVersion() ||
                    cVersion >= version.getForceUpdateMinVersionCode() && cVersion <= version.getForceUpdateMaxVersionCode() ||
                    version.getNeedTobeForceUpdateVersions().contains(context.getPackageManager().getPackageInfo(context.getPackageName(), 0).versionName);

            if ((version.getNewVersionCode() == SharedUtils.getInt(context, SharedConstant.CHECKED_APP_VERSION) && !mIsManualCheck) && !isForceUpdate) {
                return;
            }

            if (version.getNewVersionCode() == 0) {
                return;
            } else if (cVersion >= version.getNewVersionCode() && mIsManualCheck) {
                ToastUtils.showShortToast(context, context.getString(R.string.app_is_latest));
            } else {
                if (cVersion < version.getNewVersionCode()) {
                    new CheckAppVersionDialog(context, version, mIsManualCheck, isForceUpdate).show();
                }
            }
        } catch (Exception e) {
            Log.d("latestVersion", "get latest version failed");
        }
    }



}
