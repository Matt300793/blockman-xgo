package com.sandboxol.mapeditor.view.fragment.backupmanager;

import android.content.Context;

import com.sandboxol.common.base.viewmodel.ViewModel;
import com.sandboxol.mapeditor.R;

/**
 * Created by Jimmy on 2017/12/2 0002.
 */
public class BackupManageViewModel extends ViewModel {

    public BackupManageListModel backupManageListModel;

    public BackupManageViewModel(Context context) {
        backupManageListModel = new BackupManageListModel(context, R.string.my_map_no_map);
    }
}
