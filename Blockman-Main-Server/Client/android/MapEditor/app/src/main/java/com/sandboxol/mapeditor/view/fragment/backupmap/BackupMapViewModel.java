package com.sandboxol.mapeditor.view.fragment.backupmap;

import android.content.Context;

import com.sandboxol.common.base.viewmodel.ViewModel;
import com.sandboxol.mapeditor.R;

/**
 * Created by Jimmy on 2017/12/4 0004.
 */
public class BackupMapViewModel extends ViewModel {

    public BackupMapListModel backupMapListModel;

    public BackupMapViewModel(Context context, long mapId) {
        this.backupMapListModel = new BackupMapListModel(context, R.string.backup_map_no_backup, mapId);
    }
}
