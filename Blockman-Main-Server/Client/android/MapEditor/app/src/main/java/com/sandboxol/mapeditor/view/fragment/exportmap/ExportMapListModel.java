package com.sandboxol.mapeditor.view.fragment.exportmap;

import android.content.Context;
import android.net.Uri;

import com.sandboxol.common.base.viewmodel.ListItemViewModel;
import com.sandboxol.common.base.web.OnResponseListener;
import com.sandboxol.common.messenger.Messenger;
import com.sandboxol.common.utils.ToastUtils;
import com.sandboxol.common.widget.rv.pagerv.PageData;
import com.sandboxol.common.widget.rv.pagerv.PageListModel;
import com.sandboxol.mapeditor.BR;
import com.sandboxol.mapeditor.R;
import com.sandboxol.mapeditor.config.MessageToken;
import com.sandboxol.mapeditor.dao.model.McMapModel;
import com.sandboxol.mapeditor.entity.dao.McMap;

import java.util.ArrayList;
import java.util.List;

import me.tatarka.bindingcollectionadapter.ItemView;

/**
 * Created by Jimmy on 2017/11/29 0029.
 */
public class ExportMapListModel extends PageListModel<McMap> {

    private boolean isChecked = false;
    private List<Object> exportItems;

    public ExportMapListModel(Context context, int errorResId) {
        super(context, errorResId);
        exportItems = new ArrayList<>();
    }

    @Override
    public void onBind(ItemView itemView, int position, ListItemViewModel<McMap> item) {
        itemView.set(BR.ViewModel, R.layout.item_export_map);
    }

    @Override
    public int getViewTypeCount() {
        return 1;
    }

    @Override
    public ListItemViewModel<McMap> getItemViewModel(McMap item) {
        return new ExportMapItemViewModel(context, item, getViewModel().getData(), exportItems, isChecked);
    }

    @Override
    public void onLoad(int page, int size, OnResponseListener<PageData<McMap>> listener) {
        McMapModel.newInstance().getMyMaps(page, size, listener);
    }

    public void setChecked(boolean isChecked) {
        this.isChecked = isChecked;
    }

    public void exportItems(Uri uri) {
        McMapModel.newInstance().exportMyMaps(exportItems, uri, new OnResponseListener<Integer>() {
            @Override
            public void onSuccess(Integer data) {
                if (data > 0) {
                    ToastUtils.showShortToast(context, R.string.export_map_export_success);
                } else {
                    ToastUtils.showShortToast(context, R.string.export_map_export_failed);
                }
                Messenger.getDefault().send(false, MessageToken.CHANGE_EXPORT_SELECT_ALL);
                Messenger.getDefault().send(false, MessageToken.EXPORT_MY_MAP_SELECT_ALL);
                exportItems.clear();
            }

            @Override
            public void onError(int code, String msg) {

            }

            @Override
            public void onServerError(int error) {

            }
        });
    }
}
