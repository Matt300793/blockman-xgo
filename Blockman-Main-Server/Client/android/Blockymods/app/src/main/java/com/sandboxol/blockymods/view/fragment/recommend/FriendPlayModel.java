package com.sandboxol.blockymods.view.fragment.recommend;

import android.content.Context;

import com.sandboxol.blocky.entity.Game;
import com.sandboxol.blockymods.BR;
import com.sandboxol.blockymods.R;
import com.sandboxol.blockymods.config.EventConstant;
import com.sandboxol.blockymods.config.IntConstant;
import com.sandboxol.blockymods.config.MessageToken;
import com.sandboxol.blockymods.web.GameApi;
import com.sandboxol.common.base.viewmodel.ListItemViewModel;
import com.sandboxol.common.base.web.OnResponseListener;
import com.sandboxol.common.messenger.Messenger;
import com.sandboxol.common.widget.rv.datarv.DataListModel;

import java.util.List;

import me.tatarka.bindingcollectionadapter.ItemView;

/**
 * Created by Bob on 2017/10/31.
 */
public class FriendPlayModel extends DataListModel<Game> {

    public FriendPlayModel(Context context, int errorResId) {
        super(context, errorResId);
    }

    @Override
    public void onBind(ItemView itemView, int position, ListItemViewModel<Game> item) {
        itemView.set(BR.ReGameItemViewModel, R.layout.item_game_lately_view);
    }

    @Override
    public int getViewTypeCount() {
        return 1;
    }

    @Override
    public ListItemViewModel<Game> getItemViewModel(Game item) {
        return new ReGameItemViewModel(context, item, EventConstant.HOME_FRIGAMES);
    }

    @Override
    public void onLoad(OnResponseListener<List<Game>> listener) {
//        GameApi.friendPlayList(context, new OnResponseListener<List<Game>>() {
//            @Override
//            public void onSuccess(List<Game> data) {
//                if (data != null && data.size() != 0) {
//                    Messenger.getDefault().send(IntConstant.RECOMMEND_SHOW_FRIEND_VIEW, MessageToken.TOKEN_SHOW_LATELY_FRIEND_VIEW);
//                    listener.onSuccess(data);
//                }
//            }
//
//            @Override
//            public void onError(int code, String msg) {
//                listener.onError(code, msg);
//            }
//
//            @Override
//            public void onServerError(int error) {
//                listener.onServerError(error);
//            }
//        });
    }
}
