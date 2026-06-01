package com.sandboxol.mapeditor.view.activity.start;

import android.view.WindowManager;

import com.sandboxol.common.base.app.BaseActivity;
import com.sandboxol.mapeditor.R;
import com.sandboxol.mapeditor.config.EventConstant;
import com.sandboxol.mapeditor.databinding.ActivityStartBinding;
import com.tendcloud.tenddata.TCAgent;

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
        getWindow().setFlags(WindowManager.LayoutParams.FLAG_FULLSCREEN, WindowManager.LayoutParams.FLAG_FULLSCREEN);
    }

    @Override
    protected void onResume() {
        super.onResume();
        TCAgent.onEvent(this, EventConstant.HOME_START_APP);
    }
}
