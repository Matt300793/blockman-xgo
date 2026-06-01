package com.sandboxol.blockymods.view.fragment.minigamedetail;

import android.content.Context;

import com.sandboxol.blocky.entity.Game;
import com.sandboxol.blockymods.entity.Dispatch;
import com.sandboxol.blockymods.web.GameApi;
import com.sandboxol.common.base.model.IModel;
import com.sandboxol.common.base.web.OnResponseListener;

/**
 * Created by Bob on 2017/11/2.
 */
public class MiniGameDetailModel implements IModel {

    void miniGameDetail(Context context, String gameId, OnResponseListener<Game> listener) {
        GameApi.miniGameDetail(context, gameId, listener);
    }

    void appreciation(Context context, String gameId, OnResponseListener<Integer> listener) {
        GameApi.appreciation(context, gameId, listener);
    }

}
