package com.sandboxol.blockymods.view.fragment.category;

import android.content.Context;

import com.sandboxol.blocky.entity.Game;
import com.sandboxol.blockymods.BR;
import com.sandboxol.blockymods.R;
import com.sandboxol.blockymods.config.EventConstant;
import com.sandboxol.blockymods.config.MessageToken;
import com.sandboxol.blockymods.view.fragment.recommend.ReGameItemViewModel;
import com.sandboxol.blockymods.web.GameApi;
import com.sandboxol.common.base.viewmodel.ListItemViewModel;
import com.sandboxol.common.base.web.HttpResponse;
import com.sandboxol.common.base.web.OnResponseListener;
import com.sandboxol.common.config.PageConfig;
import com.sandboxol.common.messenger.Messenger;
import com.sandboxol.common.widget.rv.msg.RefreshMsg;
import com.sandboxol.common.widget.rv.pagerv.PageData;
import com.sandboxol.common.widget.rv.pagerv.PageListModel;

import me.tatarka.bindingcollectionadapter.ItemView;

/**
 * Created by Bob on 2017/10/31.
 */
public class CategoryGameModel extends PageListModel<Game> {

    private String orderType;
    private long typeId;

    public CategoryGameModel(Context context, int errorResId, String orderType, long typeId) {
        super(context, errorResId);
        this.orderType = orderType;
        this.typeId = typeId;
    }

    @Override
    public void onBind(ItemView itemView, int position, ListItemViewModel<Game> item) {
        itemView.set(BR.ReGameItemViewModel, R.layout.item_game_view);
    }

    @Override
    public int getViewTypeCount() {
        return 1;
    }

    @Override
    public ListItemViewModel<Game> getItemViewModel(Game item) {
        return new ReGameItemViewModel(context, item, EventConstant.HOME_CLASSGAMES);
    }

    @Override
    public void onLoad(int page, int size, OnResponseListener<PageData<Game>> listener) {
        GameApi.category(context, String.valueOf(page), String.valueOf(size), orderType, typeId, PageConfig.ORDER_DSC, listener);
    }

    void refreshGames(String orderType, long typeId) {
        this.orderType = orderType;
        this.typeId = typeId;
        Messenger.getDefault().send(RefreshMsg.create(), getRefreshToken());
    }

    @Override
    public String getRefreshToken() {
        return MessageToken.TOKEN_REFRESH_CATEGORY_TYPE;
    }
}
