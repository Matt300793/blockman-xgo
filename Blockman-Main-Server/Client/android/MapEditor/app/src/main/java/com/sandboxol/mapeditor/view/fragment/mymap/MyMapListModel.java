package com.sandboxol.mapeditor.view.fragment.mymap;

import android.content.Context;

import com.sandboxol.common.base.viewmodel.ListItemViewModel;
import com.sandboxol.common.base.web.OnResponseListener;
import com.sandboxol.common.widget.rv.pagerv.PageData;
import com.sandboxol.common.widget.rv.pagerv.PageListModel;
import com.sandboxol.mapeditor.BR;
import com.sandboxol.mapeditor.R;
import com.sandboxol.mapeditor.config.MessageToken;
import com.sandboxol.mapeditor.dao.model.McMapModel;
import com.sandboxol.mapeditor.entity.dao.McMap;

import me.tatarka.bindingcollectionadapter.ItemView;

/**
 * Created by Jimmy on 2017/11/29 0029.
 */
public class MyMapListModel extends PageListModel<McMap> {

    public MyMapListModel(Context context, int errorResId) {
        super(context, errorResId);
    }

    @Override
    public void onBind(ItemView itemView, int position, ListItemViewModel<McMap> item) {
        itemView.set(BR.ViewModel, R.layout.item_my_map);
    }

    @Override
    public int getViewTypeCount() {
        return 1;
    }

    @Override
    public ListItemViewModel<McMap> getItemViewModel(McMap item) {
        return new MyMapItemViewModel(context, item);
    }

    @Override
    public void onLoad(int page, int size, OnResponseListener<PageData<McMap>> listener) {
        McMapModel.newInstance().getMyMaps(page, size, listener);
    }

    @Override
    public String getInsertToken() {
        return MessageToken.IMPORT_MY_MAP;
    }

    @Override
    public String getRemoveToken() {
        return MessageToken.REMOVE_MY_MAP;
    }

}
