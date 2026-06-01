package com.sandboxol.blockymods.view.fragment.dress;

import android.content.Context;
import android.databinding.ObservableMap;

import com.sandboxol.blockymods.R;
import com.sandboxol.blockymods.config.MessageToken;
import com.sandboxol.blockymods.entity.DressItem;
import com.sandboxol.blockymods.web.DecorationApi;
import com.sandboxol.common.BR;
import com.sandboxol.common.base.viewmodel.ListItemViewModel;
import com.sandboxol.common.base.web.OnResponseListener;
import com.sandboxol.common.widget.rv.datarv.DataListModel;

import java.util.List;

import me.tatarka.bindingcollectionadapter.ItemView;

/**
 * Created by Jimmy on 2017/12/4 0004.
 */
public class DressPageListModel extends DataListModel<DressItem> {

    private int type;
    private ObservableMap<Long, String> ids;
    private ObservableMap<Long, String> dressUrl;

    public DressPageListModel(Context context, int errorResId, int type, ObservableMap<Long, String> ids, ObservableMap<Long, String> dressUrl) {
        super(context, errorResId);
        this.type = type;
        this.ids = ids;
        this.dressUrl = dressUrl;
    }

    @Override
    public void onBind(ItemView itemView, int position, ListItemViewModel<DressItem> item) {
        itemView.set(BR.ViewModel, R.layout.content_dress_item);
    }

    @Override
    public int getViewTypeCount() {
        return 1;
    }

    @Override
    public ListItemViewModel<DressItem> getItemViewModel(DressItem item) {
        return new DressItemViewModel(context, item, ids, type, dressUrl);
    }

    @Override
    public void onLoad(OnResponseListener<List<DressItem>> listener) {
        if (type == 0) {
            DecorationApi.isUsingList(context, listener);
        } else
            DecorationApi.dressList(context, type, listener);
    }

    @Override
    public String getRefreshToken() {
        if (type == 0)
            return MessageToken.TOKEN_REFRESH_DECORATION_TYPE;
        else
            return super.getRefreshToken();
    }
}
