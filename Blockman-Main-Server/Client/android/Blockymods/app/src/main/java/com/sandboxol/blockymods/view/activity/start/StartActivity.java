package com.sandboxol.blockymods.view.activity.start;

import android.os.Environment;
import android.view.WindowManager;

import com.sandboxol.blockymods.R;
import com.sandboxol.blockymods.config.EventConstant;
import com.sandboxol.blockymods.config.StringConstant;
import com.sandboxol.blockymods.databinding.ActivityStartBinding;
import com.sandboxol.common.base.app.BaseActivity;
import com.tendcloud.tenddata.TCAgent;

import java.io.File;

/**
 * Created by Bob on 2017/10/16.
 */
public class StartActivity extends BaseActivity<StartViewModel, ActivityStartBinding> {

    @Override
    protected int getLayoutId() {
        return R.layout.activity_start;
    }

    @Override
    protected StartViewModel getViewModel() {
        return new StartViewModel(this);
    }

    @Override
    protected void bindViewModel(ActivityStartBinding binding, StartViewModel viewModel) {
        binding.setStartViewModel(viewModel);
        getWindow().setFlags(WindowManager.LayoutParams.FLAG_FULLSCREEN, WindowManager.LayoutParams.FLAG_FULLSCREEN);//全屏

        createLocalDocument();
    }

    /**
     * 创建本地文件
     */
    private void createLocalDocument() {
        try {
            File file = new File(Environment.getExternalStorageDirectory(), StringConstant.BLOCKY_MODS_CACHE_PATH_ICON);
            if (!file.isDirectory()) {
                file.mkdirs();
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    @Override
    protected void onResume() {
        super.onResume();
        TCAgent.onEvent(this, EventConstant.HOME_STARTAPP);
    }
}
