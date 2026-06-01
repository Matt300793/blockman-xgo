package com.sandboxol.mapeditor.view.fragment.backupmanager;

import android.content.Context;
import android.databinding.ObservableField;

import com.sandboxol.common.base.viewmodel.ListItemViewModel;
import com.sandboxol.common.command.ReplyCommand;
import com.sandboxol.common.messenger.Messenger;
import com.sandboxol.common.utils.DateUtils;
import com.sandboxol.mapeditor.R;
import com.sandboxol.mapeditor.config.MessageToken;
import com.sandboxol.mapeditor.dao.model.BackupManageModel;
import com.sandboxol.mapeditor.entity.BackupItem;
import com.sandboxol.mapeditor.utils.FragmentUtils;

import rx.Observable;
import rx.android.schedulers.AndroidSchedulers;
import rx.schedulers.Schedulers;

/**
 * Created by Jimmy on 2017/11/29 0029.
 */
public class BackupManageItemViewModel extends ListItemViewModel<BackupItem> {

    public ObservableField<String> image = new ObservableField<>();
    public ObservableField<String> name = new ObservableField<>();
    public ObservableField<String> lately = new ObservableField<>();
    public ObservableField<String> num = new ObservableField<>();
    public ObservableField<Boolean> hasBackup = new ObservableField<>(false);

    public ReplyCommand onItemClickCommand = new ReplyCommand(this::onItemClick);

    public BackupManageItemViewModel(Context context, BackupItem item) {
        super(context, item);
        initUI();
        initMessages();
    }

    private void initMessages() {
        Messenger.getDefault().register(this, String.format(MessageToken.CHANGE_BACKUP_MAP, item.map.getId()), this::refreshItem);
    }

    private void refreshItem() {
        Observable.just(item.map)
                .doOnNext(map -> {
                    BackupItem backup = BackupManageModel.newInstance().getMyMapFormatBackup(item.map);
                    item.map = backup.map;
                    item.lately = backup.lately;
                    item.num = backup.num;
                })
                .subscribeOn(Schedulers.newThread())
                .observeOn(AndroidSchedulers.mainThread())
                .subscribe(map -> initUI());
    }

    private void initUI() {
        image.set(item.map.getImage());
        name.set(item.map.getName());
        hasBackup.set(item.num > 0);
        if (item.num > 0) {
            lately.set(context.getResources().getString(R.string.backup_manage_backup_lately, DateUtils.timeStamp2Date(item.lately, null)));
            num.set(context.getResources().getString(R.string.backup_manage_backup_num, item.num));
        } else {
            num.set(context.getResources().getString(R.string.backup_manage_backup_null));
        }
    }

    private void onItemClick() {
        FragmentUtils.startBackupMapFragment(context, item.map);
    }

    @Override
    public void onDestroy() {
        super.onDestroy();
        Messenger.getDefault().unregister(this, String.format(MessageToken.CHANGE_BACKUP_MAP, item.map.getId()));
    }
}
