package com.sandboxol.blockymods.view.fragment.recommend;

import android.content.Context;

import com.sandboxol.blocky.entity.Game;
import com.sandboxol.blockymods.BR;
import com.sandboxol.blockymods.R;
import com.sandboxol.blockymods.config.EventConstant;
import com.sandboxol.blockymods.config.MessageToken;
import com.sandboxol.blockymods.web.GameApi;
import com.sandboxol.common.base.viewmodel.ListItemViewModel;
import com.sandboxol.common.base.web.HttpResponse;
import com.sandboxol.common.base.web.OnResponseListener;
import com.sandboxol.common.widget.rv.datarv.DataListModel;

import java.util.List;

import me.tatarka.bindingcollectionadapter.ItemView;

/**
 * Created by Bob on 2017/10/31.
 */
public class HotRecommendModel extends DataListModel<Game> {

    public HotRecommendModel(Context context, int errorResId) {
        super(context, errorResId);
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
        return new ReGameItemViewModel(context, item, EventConstant.HOME_RECOGAMES);
    }

    @Override
    public void onLoad(OnResponseListener<List<Game>> listener) {
        GameApi.recommendation(context, listener);
    }

    @Override
    public String getRefreshToken() {
        return MessageToken.TOKEN_REFRESH_RECOMMEND_TYPE;
    }
}
