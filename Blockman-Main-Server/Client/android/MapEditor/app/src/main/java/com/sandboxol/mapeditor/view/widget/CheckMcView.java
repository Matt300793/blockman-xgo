package com.sandboxol.mapeditor.view.widget;

import android.content.Context;
import android.support.annotation.AttrRes;
import android.support.annotation.NonNull;
import android.support.annotation.Nullable;
import android.text.TextUtils;
import android.util.AttributeSet;
import android.view.View;
import android.widget.FrameLayout;
import android.widget.ImageView;
import android.widget.ProgressBar;
import android.widget.TextView;

import com.sandboxol.common.utils.SharedUtils;
import com.sandboxol.mapeditor.R;
import com.sandboxol.mapeditor.config.SharedConstant;
import com.sandboxol.mapeditor.entity.McVersion;
import com.sandboxol.mapeditor.utils.McUtils;
import com.sandboxol.mapeditor.view.dialog.ConfirmDialog;

/**
 * Created by Jimmy on 2017/11/28 0028.
 */
public class CheckMcView extends FrameLayout implements View.OnClickListener {

    private View vProgress, vFinish;
    private ProgressBar pbProgress;
    private ImageView ivMcIcon;
    private TextView tvMcName, tvMcVersion;

    public CheckMcView(@NonNull Context context) {
        this(context, null);
    }

    public CheckMcView(@NonNull Context context, @Nullable AttributeSet attrs) {
        this(context, attrs, 0);
    }

    public CheckMcView(@NonNull Context context, @Nullable AttributeSet attrs, @AttrRes int defStyleAttr) {
        super(context, attrs, defStyleAttr);
        init();
    }

    private void init() {
        View.inflate(getContext(), R.layout.view_check_mc, this);
        vProgress = findViewById(R.id.vProgress);
        vFinish = findViewById(R.id.vFinish);
        pbProgress = findViewById(R.id.pbProgress);
        ivMcIcon = findViewById(R.id.ivMcIcon);
        tvMcName = findViewById(R.id.tvMcName);
        tvMcVersion = findViewById(R.id.tvMcVersion);
        findViewById(R.id.llInstructions).setOnClickListener(this);
        checkMcVersion();
    }

    private void checkMcVersion() {
        showProgress();
        changeProgress(0);
    }

    private void showFinish() {
        vProgress.setVisibility(GONE);
        vFinish.setVisibility(VISIBLE);
        McVersion version = McUtils.getMcVersion(getContext());
        if (TextUtils.isEmpty(version.version)) {
            tvMcName.setText(getResources().getString(R.string.no_install_mc));
            tvMcVersion.setText("");
            showMcNoInstallDialog();
        } else {
            ivMcIcon.setImageResource(version.icon);
            tvMcName.setText(version.name);
            tvMcVersion.setText(version.version);
        }
    }

    private void showMcNoInstallDialog() {
        if (!SharedUtils.getBoolean(getContext(), SharedConstant.SHOW_MC_NO_INSTALL_DIALOG)) {
            SharedUtils.putBoolean(getContext(), SharedConstant.SHOW_MC_NO_INSTALL_DIALOG, true);
            new ConfirmDialog(getContext())
                    .setContentText(R.string.check_finish_no_install_content)
                    .setConfirmText(R.string.check_finish_no_install_confirm)
                    .show();
        }
    }

    private void showProgress() {
        vProgress.setVisibility(VISIBLE);
        vFinish.setVisibility(GONE);
    }

    private void changeProgress(int progress) {
        pbProgress.setProgress(progress);
        if (progress < 100)
            postDelayed(() -> changeProgress(progress + 1), 30);
        else
            showFinish();
    }

    @Override
    public void onClick(View v) {
        switch (v.getId()) {
            case R.id.llInstructions:

                break;
        }
    }
}
