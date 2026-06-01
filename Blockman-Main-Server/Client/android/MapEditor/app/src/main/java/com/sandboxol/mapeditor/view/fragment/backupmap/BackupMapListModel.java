package com.sandboxol.mapeditor.view.fragment.backupmap;

import android.content.Context;

import com.android.databinding.library.baseAdapters.BR;
import com.sandboxol.common.base.viewmodel.ListItemViewModel;
import com.sandboxol.common.base.web.OnResponseListener;
import com.sandboxol.common.widget.rv.datarv.DataListModel;
import com.sandboxol.mapeditor.R;
import com.sandboxol.mapeditor.config.MessageToken;
import com.sandboxol.mapeditor.dao.model.BackupManageModel;
import com.sandboxol.mapeditor.entity.dao.McMapBackup;

import java.util.List;

import me.tatarka.bindingcollectionadapter.ItemView;

/**
 * Created by Jimmy on 2017/12/4 0004.
 */
public class BackupMapListModel extends DataListModel<McMapBackup> {

    private long mapId;

    public BackupMapListModel(Context context, int errorResId, long mapId) {
        super(context, errorResId);
        this.mapId = mapId;
    }

    @Override
    public void onBind(ItemView itemView, int position, ListItemViewModel<McMapBackup> item) {
        itemView.set(BR.ViewModel, R.layout.item_backup_map);
    }

    @Override
    public int getViewTypeCount() {
        return 1;
    }

    @Override
    public ListItemViewModel<McMapBackup> getItemViewModel(McMapBackup item) {
        return new BackupMapItemViewModel(context, item);
    }

    @Override
    public String getRemoveToken() {
        return MessageToken.REMOVE_BACKUP_MAP;
    }

    @Override
    public void onLoad(OnResponseListener<List<McMapBackup>> listener) {
        BackupManageModel.newInstance().getMcMapBackupByMcMapId(mapId, listener);
    }
}
