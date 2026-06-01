package com.sandboxol.blockymods.view.activity.main;

import android.os.SystemClock;

import com.sandboxol.blockymods.R;
import com.sandboxol.blockymods.config.EventConstant;
import com.sandboxol.blockymods.databinding.ActivityMainBinding;
import com.sandboxol.common.base.app.BaseActivity;
import com.sandboxol.common.utils.ToastUtils;
import com.tendcloud.tenddata.TCAgent;

/**
 * Created by Bob on 2017/10/12
 */
public class MainActivity extends BaseActivity<MainViewModel, ActivityMainBinding> {

    private long[] notes = new long[2];

    @Override
    protected int getLayoutId() {
        return R.layout.activity_main;
    }

    @Override
    protected MainViewModel getViewModel() {
        return new MainViewModel(this);
    }

    @Override
    protected void bindViewModel(ActivityMainBinding binding, MainViewModel viewModel) {
        binding.setMainViewModel(viewModel);
    }

    @Override
    public void onBackPressed() {
        System.arraycopy(notes, 1, notes, 0, notes.length - 1);
        notes[notes.length - 1] = SystemClock.uptimeMillis();
        if (SystemClock.uptimeMillis() - notes[0] < 1000) {
            finish();
        } else {
            ToastUtils.showShortToast(this, R.string.exit);
        }
    }

    @Override
    protected void onResume() {
        super.onResume();
        TCAgent.onEvent(this, EventConstant.HOME_VIEW);
    }

    @Override
    protected void onDestroy() {
        super.onDestroy();
        android.os.Process.killProcess(android.os.Process.myPid());
    }
}
