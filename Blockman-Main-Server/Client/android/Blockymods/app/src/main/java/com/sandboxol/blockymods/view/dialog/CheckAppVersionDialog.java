package com.sandboxol.blockymods.view.dialog;

import android.content.Context;
import android.content.Intent;
import android.databinding.DataBindingUtil;
import android.databinding.ObservableField;
import android.net.Uri;
import android.support.annotation.NonNull;
import android.view.LayoutInflater;

import com.sandboxol.blockymods.R;
import com.sandboxol.blockymods.config.EventConstant;
import com.sandboxol.blockymods.config.SharedConstant;
import com.sandboxol.blockymods.config.UrlConstant;
import com.sandboxol.blockymods.databinding.DialogAppCheckAppVersionBinding;
import com.sandboxol.blockymods.entity.LatestVersion;
import com.sandboxol.common.base.viewmodel.ViewModel;
import com.sandboxol.common.command.ReplyCommand;
import com.sandboxol.common.dialog.FullScreenDialog;
import com.sandboxol.common.utils.SharedUtils;
import com.tendcloud.tenddata.TCAgent;

/**
 * Created by Bob on 2017/11/21
 */
public class CheckAppVersionDialog extends FullScreenDialog {

    private LatestVersion version;
    private Context context;
    private boolean isManualCheck;//是否手动更新
    private boolean isForceUpdate = false;//是否强制更新

    public CheckAppVersionDialog(@NonNull Context context, LatestVersion version, boolean isManualCheck, boolean isForceUpdate) {
        super(context);
        this.version = version;
        this.context = context;
        this.isManualCheck = isManualCheck;
        this.isForceUpdate = isForceUpdate;
        initView();
    }

    private void initView() {
        super.init(context);
        DialogAppCheckAppVersionBinding binding = DataBindingUtil.inflate(LayoutInflater.from(context), R.layout.dialog_app_check_app_version, null, false);
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
            }
        }

        private void onUpdateClick() {
            saveCheckedVersion(version.getNewVersionCode());
            Intent browserIntent = new Intent(Intent.ACTION_VIEW, Uri.parse(UrlConstant.PLAY_STORE_URL));
            context.startActivity(browserIntent);
            TCAgent.onEvent(context, EventConstant.HOME_UPDATE);
        }

        private void onCancelClick() {
            saveCheckedVersion(version.getNewVersionCode());
            dismiss();
            TCAgent.onEvent(context, EventConstant.HOME_CANCEL);
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
