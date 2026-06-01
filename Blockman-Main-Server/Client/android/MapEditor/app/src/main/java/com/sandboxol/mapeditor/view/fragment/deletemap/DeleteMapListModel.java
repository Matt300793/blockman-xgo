package com.sandboxol.mapeditor.view.fragment.deletemap;

import android.content.Context;
import android.databinding.ObservableArrayList;

import com.sandboxol.common.base.viewmodel.ListItemViewModel;
import com.sandboxol.common.base.web.OnResponseListener;
import com.sandboxol.common.messenger.Messenger;
import com.sandboxol.common.utils.ToastUtils;
import com.sandboxol.common.widget.rv.msg.RemoveMsg;
import com.sandboxol.common.widget.rv.pagerv.PageData;
import com.sandboxol.common.widget.rv.pagerv.PageListModel;
import com.sandboxol.mapeditor.BR;
import com.sandboxol.mapeditor.R;
import com.sandboxol.mapeditor.config.MessageToken;
import com.sandboxol.mapeditor.dao.model.McMapModel;
import com.sandboxol.mapeditor.entity.dao.McMap;
import com.sandboxol.mapeditor.view.dialog.YerOrNoDialog;

import java.util.ArrayList;
import java.util.List;

import me.tatarka.bindingcollectionadapter.ItemView;

/**
 * Created by Jimmy on 2017/11/29 0029.
 */
public class DeleteMapListModel extends PageListModel<McMap> {

    public ArrayList<Object> removeItems;

    private boolean isChecked = false;

    public DeleteMapListModel(Context context, int errorResId) {
        super(context, errorResId);
        removeItems = new ObservableArrayList<>();
    }

    @Override
    public void onBind(ItemView itemView, int position, ListItemViewModel<McMap> item) {
        itemView.set(BR.ViewModel, R.layout.item_delete_map);
    }

    @Override
    public int getViewTypeCount() {
        return 1;
    }

    @Override
    public ListItemViewModel<McMap> getItemViewModel(McMap item) {
        return new DeleteMapItemViewModel(context, item, getData(), removeItems, isChecked);
    }

    @Override
    public void onLoad(int page, int size, OnResponseListener<PageData<McMap>> listener) {
        McMapModel.newInstance().getMyMaps(page, size, listener);
    }

    public void setChecked(boolean isChecked) {
        this.isChecked = isChecked;
    }

    @Override
    public String getRemoveToken() {
        return MessageToken.REMOVE_MY_MAP;
    }

    public void deleteRemoveItems() {
        McMapModel.newInstance().removeMyMaps(removeItems, new OnResponseListener<Integer>() {
            @Override
            public void onSuccess(Integer data) {
                if (data > 0) {
                    Messenger.getDefault().send(RemoveMsg.createList(removeItems), getRemoveToken());
                    Messenger.getDefault().send(false, MessageToken.CHANGE_REMOVE_SELECT_ALL);
                    Messenger.getDefault().send(false, MessageToken.ENABLED_REMOVE);
                    removeItems.clear();
                    ToastUtils.showShortToast(context, R.string.delete_map_delete_success);
                }
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
