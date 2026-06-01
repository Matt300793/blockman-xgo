package com.sandboxol.mapeditor.view.fragment.backupmanager;

import android.content.Context;

import com.sandboxol.common.base.viewmodel.ListItemViewModel;
import com.sandboxol.common.base.web.OnResponseListener;
import com.sandboxol.common.widget.rv.pagerv.PageData;
import com.sandboxol.common.widget.rv.pagerv.PageListModel;
import com.sandboxol.mapeditor.BR;
import com.sandboxol.mapeditor.R;
import com.sandboxol.mapeditor.dao.model.BackupManageModel;
import com.sandboxol.mapeditor.entity.BackupItem;

import me.tatarka.bindingcollectionadapter.ItemView;

/**
 * Created by Jimmy on 2017/11/29 0029.
 */
public class BackupManageListModel extends PageListModel<BackupItem> {

    public BackupManageListModel(Context context, int errorResId) {
        super(context, errorResId);
    }

    @Override
    public void onBind(ItemView itemView, int position, ListItemViewModel<BackupItem> item) {
        itemView.set(BR.ViewModel, R.layout.item_backup_manager);
    }

    @Override
    public int getViewTypeCount() {
        return 1;
    }

    @Override
    public ListItemViewModel<BackupItem> getItemViewModel(BackupItem item) {
        return new BackupManageItemViewModel(context, item);
    }

    @Override
    public void onLoad(int page, int size, OnResponseListener<PageData<BackupItem>> listener) {
        BackupManageModel.newInstance().getMyMapsFormatBackup(page, size, listener);
    }
}
