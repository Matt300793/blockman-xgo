package com.sandboxol.blocky.activity;

import android.app.Activity;
import android.content.Intent;
import android.databinding.DataBindingUtil;
import android.os.Build;
import android.os.Bundle;
import android.util.Log;
import android.view.View;

import com.sandboxol.blocky.utils.GameSharedUtils;
import com.sandboxol.blocky.entity.EnterRealmsResult;
import com.sandboxol.blocky.router.Controller;
import com.sandboxol.blocky.router.ControllerType;
import com.sandboxol.blocky.router.RealmsController;
import com.sandboxol.common.utils.CommonHelper;
import com.sandboxol.game.R;
import com.sandboxol.game.databinding.ActivityStartMcBinding;


public class StartMcActivity extends Activity {

    public static final int FINISH_MAIN_ACTIVITY_ACTIVITY = 115;

    Intent result;
    private long startTime = 0;

    private ActivityStartMcBinding binding;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        try {
            toggleHideBar();
            getWindow().getDecorView().setOnSystemUiVisibilityChangeListener(visibility -> {
                if ((visibility & View.SYSTEM_UI_FLAG_FULLSCREEN) == 0) {
                    toggleHideBar();
                }
            });
        } catch (Exception e) {
            e.printStackTrace();
        }
        super.onCreate(savedInstanceState);
        binding = DataBindingUtil.setContentView(this, R.layout.activity_start_mc);
        startTime = System.currentTimeMillis();
        binding.plvLoading.postDelayed(() -> binding.plvLoading.setVisibility(View.INVISIBLE), 10000);
        Intent intent = getIntent();
        String gameInfo = GameSharedUtils.newInstance().getStartGameInfo();
        ControllerType controllerType = (ControllerType) intent.getSerializableExtra("controllerType");
        if (gameInfo == null || controllerType == null) {
            finish();
            return;
        }

        Controller controller;
        switch (controllerType) {
            case BLOCK_MAN:
                controller = RealmsController.newInstance(this);
                if (!controller.isInit()) {
                    EnterRealmsResult result = CommonHelper.formatObject(gameInfo, EnterRealmsResult.class);
                    if (result == null || result.getGame() == null) {
                        finish();
                        return;
                    }
                    controller.setEnterRealmsResult(controllerType, result);
                }
                break;
        }

    }

    public void setRouterConnectionFails() {
        binding.plvLoading.setVisibility(View.VISIBLE);
    }

    public void toggleHideBar() {

        if (getWindow() == null || getWindow().getDecorView() == null) {
            return;
        }

        if (Build.VERSION.SDK_INT > 18) {
            int newUiOptions = View.SYSTEM_UI_FLAG_LAYOUT_STABLE
                    | View.SYSTEM_UI_FLAG_LAYOUT_HIDE_NAVIGATION
                    | View.SYSTEM_UI_FLAG_LAYOUT_FULLSCREEN
                    | View.SYSTEM_UI_FLAG_HIDE_NAVIGATION
                    | View.SYSTEM_UI_FLAG_FULLSCREEN
                    | View.SYSTEM_UI_FLAG_IMMERSIVE_STICKY;

            getWindow().getDecorView().setSystemUiVisibility(newUiOptions);
        }
    }

    @Override
    protected void onResume() {
        super.onResume();
    }

    @Override
    public void onWindowFocusChanged(boolean hasFocus) {
        if (hasFocus) {
            toggleHideBar();
        }
    }

    @Override
    protected void onNewIntent(Intent intent) {
        Log.e("router-jni", "onNewIntent");
        setIntent(new Intent());
    }

    @Override
    protected void onActivityResult(int requestCode, int resultCode, Intent data) {
        super.onActivityResult(requestCode, resultCode, data);
        if (requestCode == FINISH_MAIN_ACTIVITY_ACTIVITY) {
            this.result = data;
            finish();
        }
    }

    @Override
    public void onBackPressed() {
        if (System.currentTimeMillis() - startTime > 10 * 1000) {
            super.onBackPressed();
        }
    }

    @Override
    public void finish() {
        try {
            Intent intent = getIntent();
            ControllerType controllerType = (ControllerType) intent.getSerializableExtra("controllerType");
            if (controllerType != null) {
                Controller controller = null;
                switch (controllerType) {
                    case BLOCK_MAN:
                        controller = RealmsController.getMe();
                        break;
                }
                if (controller != null) {
                    controller.stop();
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        setResult(StartMcActivity.FINISH_MAIN_ACTIVITY_ACTIVITY, result);
        GameSharedUtils.newInstance().putStartGameInfo(null);
        super.finish();
    }

    @Override
    protected void onDestroy() {
        super.onDestroy();
        android.os.Process.killProcess(android.os.Process.myPid());
    }
}
