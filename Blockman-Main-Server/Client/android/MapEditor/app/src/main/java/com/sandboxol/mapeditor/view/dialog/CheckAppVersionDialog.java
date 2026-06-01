package com.sandboxol.mapeditor.view.dialog;

import android.content.Context;
import android.content.Intent;
import android.databinding.DataBindingUtil;
import android.databinding.ObservableField;
import android.net.Uri;
import android.support.annotation.NonNull;
import android.view.LayoutInflater;
import android.widget.Button;

import com.sandboxol.common.base.viewmodel.ViewModel;
import com.sandboxol.common.command.ReplyCommand;
import com.sandboxol.common.dialog.FullScreenDialog;
import com.sandboxol.common.utils.SharedUtils;
import com.sandboxol.mapeditor.R;
import com.sandboxol.mapeditor.config.EventConstant;
import com.sandboxol.mapeditor.config.SharedConstant;
import com.sandboxol.mapeditor.config.UrlConstant;
import com.sandboxol.mapeditor.databinding.DialogAppCheckAppVersionBinding;
import com.sandboxol.mapeditor.entity.LatestVersion;
import com.tendcloud.tenddata.TCAgent;

/**
 * Created by Bob on 2017/11/21.
 */
public class CheckAppVersionDialog extends FullScreenDialog {

    private LatestVersion version;
    private Context context;
    private boolean isManualCheck;//是否手动更新
    private boolean isForceUpdate = false;//是否强制更新

    private Button btnConfirm;
    public CheckAppVersionDialog(@NonNull Context context, LatestVersion version, boolean isManualCheck, boolean isForceUpdate) {
        super(context);
        this.version = version;
        this.context = context;
        this.isManualCheck = isManualCheck;
        this.isForceUpdate = isForceUpdate;
        initView();
    }

    @Override
    protected boolean isBlurBackground() {
        return true;
    }

    @Override
    protected float getBlurScale() {
        return 2.5f;
    }

    @Override
    protected int getBlurRadius() {
        return 3;
    }

    private void initView() {
        super.init(context);
        DialogAppCheckAppVersionBinding binding = DataBindingUtil.inflate(LayoutInflater.from(context), R.layout.dialog_app_check_app_version, null, false);
        btnConfirm = binding.btnConfirm;
        setContentView(binding.getRoot());
        binding.setCheckAppVersionDialogViewModel(new CheckAppVersionDialogViewModel());
    }

    public class CheckAppVersionDialogViewModel extends ViewModel {

        public ObservableField<String> updateText = new ObservableField<>();
        public ObservableField<Boolean> isShowPic = new ObservableField<>(false);
        public ObservableField<Boolean> isMandatory = new ObservableField<>(false);
        public ObservableField<String> picUrl = new ObservableField<>();

        public ReplyCommand onClickCancelCommand = new ReplyCommand(this::onCancelClick);
        public ReplyCommand onClickUpdateCommand = new ReplyCommand(this::onUpdateClick);

        public CheckAppVersionDialogViewModel() {
            initData();
        }

        private void initData() {
            if (version.getContent(isForceUpdate) != null && !version.getContent(isForceUpdate).isEmpty()) {
                updateText.set(version.getContent(isForceUpdate));
            } else {
                updateText.set(context.getString(R.string.app_not_latest));
            }
            if (version.getPicUrl() == null || "".equals(version.getPicUrl()))
                isShowPic.set(false);
            else {
                isShowPic.set(true);
                picUrl.set(version.getPicUrl());
            }
            if (isForceUpdate) {
                setCancelable(false);
                isMandatory.set(true);
                btnConfirm.setBackgroundResource(R.drawable.btn_dialog_confirm);
            }
        }

        private void onUpdateClick() {
            saveCheckedVersion(version.getNewVersionCode());
            Intent browserIntent = new Intent(Intent.ACTION_VIEW, Uri.parse(UrlConstant.PLAY_STORE_URL));
            context.startActivity(browserIntent);
            TCAgent.onEvent(context, EventConstant.HOME_CHECK_VERSION_UPDATE);
        }

        private void onCancelClick() {
            saveCheckedVersion(version.getNewVersionCode());
            dismiss();
            TCAgent.onEvent(context, EventConstant.HOME_CHECK_VERSION_CANCEL);
        }

        /**
         * 保存版本号
         *
         * @param versionCode
         */
        private void saveCheckedVersion(int versionCode) {
            if (!isManualCheck)
                SharedUtils.putInt(context, SharedConstant.CHECKED_APP_VERSION, versionCode);
        }

    }
}
