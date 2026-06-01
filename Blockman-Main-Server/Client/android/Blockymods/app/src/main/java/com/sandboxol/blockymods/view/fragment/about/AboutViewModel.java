package com.sandboxol.blockymods.view.fragment.about;

import android.content.Context;
import android.content.pm.PackageInfo;
import android.content.pm.PackageManager;
import android.databinding.ObservableField;

import com.sandboxol.blockymods.R;
import com.sandboxol.common.base.viewmodel.ViewModel;

/**
 * Created by Bob on 2017/10/23.
 */
public class AboutViewModel extends ViewModel {

    public ObservableField<String> version = new ObservableField<>("");

    private Context context;

    public AboutViewModel(Context context) {
        this.context = context;
        setVersion();
    }

    private void setVersion() {
        try {
            PackageInfo info = (context.getPackageManager().getPackageInfo(context.getPackageName(), 0));
            version.set(context.getString(R.string.about_version) +  info.versionName + " build " +  info.versionCode);
        } catch (PackageManager.NameNotFoundException e) {
            e.printStackTrace();
        }
    }
}
