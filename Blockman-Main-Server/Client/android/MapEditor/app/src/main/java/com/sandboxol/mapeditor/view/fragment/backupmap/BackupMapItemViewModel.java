package com.sandboxol.mapeditor.view.fragment.backupmap;

import android.content.Context;
import android.databinding.ObservableField;

import com.sandboxol.common.base.viewmodel.ListItemViewModel;
import com.sandboxol.common.base.web.OnResponseListener;
import com.sandboxol.common.command.ReplyCommand;
import com.sandboxol.common.messenger.Messenger;
import com.sandboxol.common.utils.DateUtils;
import com.sandboxol.common.utils.ToastUtils;
import com.sandboxol.common.widget.rv.msg.RemoveMsg;
import com.sandboxol.mapeditor.R;
import com.sandboxol.mapeditor.config.MessageToken;
import com.sandboxol.mapeditor.dao.model.BackupManageModel;
import com.sandboxol.mapeditor.entity.dao.McMapBackup;
import com.sandboxol.mapeditor.view.dialog.YerOrNoDialog;

/**
 * Created by Jimmy on 2017/12/4 0004.
 */
public class BackupMapItemViewModel extends ListItemViewModel<McMapBackup> {

    public ObservableField<String> name = new ObservableField<>();
    public ObservableField<String> image = new ObservableField<>();
    public ObservableField<String> time = new ObservableField<>();

    public ReplyCommand onRemoveCommand = new ReplyCommand(this::onRemove);
    public ReplyCommand onRestoreCommand = new ReplyCommand(this::onRestore);

    public BackupMapItemViewModel(Context context, McMapBackup item) {
        super(context, item);
        initUI();
    }

    private void initUI() {
        name.set(item.getName());
        image.set(item.getImage());
        time.set(context.getResources().getString(R.string.backup_map_backup_time, DateUtils.timeStamp2Date(item.getTime(), null)));
    }

    private void onRemove() {
        new YerOrNoDialog(context)
                .setContentText(context.getResources().getString(R.string.backup_map_remove_hint, item.getName()))
                .setConfirmListener(this::removeMcMapBackup)
                .show();
    }

    private void onRestore() {
        new YerOrNoDialog(context)
                .setContentText(R.string.backup_map_restore_hint)
                .setConfirmListener(this::restoreMcMapBackup)
                .show();
    }

    private void removeMcMapBackup() {
        BackupManageModel.newInstance().removeMcMapBackup(item, new OnResponseListener<McMapBackup>() {
            @Override
            public void onSuccess(McMapBackup data) {
                Messenger.getDefault().send(RemoveMsg.createItem(item), MessageToken.REMOVE_BACKUP_MAP);
                Messenger.getDefault().sendNoMsg(String.format(MessageToken.CHANGE_BACKUP_MAP, item.getMapId()));
                ToastUtils.showShortToast(context, R.string.delete_map_delete_success);
            }

            @Override
            public void onError(int code, String msg) {

            }

            @Override
            public void onServerError(int error) {

            }
        });
    }

    private void restoreMcMapBackup() {
        BackupManageModel.newInstance().restoreMcMapBackupToMyMap(item, new OnResponseListener<McMapBackup>() {
            @Override
            public void onSuccess(McMapBackup data) {
                showRestoreSuccessDialog();
            }

            @Override
            public void onError(int code, String msg) {
                ToastUtils.showShortToast(context, R.string.backup_map_restore_failed);
            }

            @Override
            public void onServerError(int error) {

            }
        });
    }

    private void showRestoreSuccessDialog() {
        new YerOrNoDialog(context)
                .setContentText(R.string.backup_map_restore_success)
                .setConfirmText(R.string.backup_map_start_game)
                .setConfirmListener(this::startGame)
                .show();
    }

    private void startGame() {
        ToastUtils.showShortToast(context, R.string.backup_map_start_game);
    }

}
