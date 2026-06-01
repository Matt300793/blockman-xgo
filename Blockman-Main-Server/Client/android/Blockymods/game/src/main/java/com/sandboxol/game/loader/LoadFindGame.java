package com.sandboxol.game.loader;

import android.content.Context;
import android.os.AsyncTask;

import com.sandboxol.game.entity.FindItem;
import com.sandboxol.game.entity.GameData;
import com.sandboxol.game.entity.GameListResult;
import com.sandboxol.game.interfaces.LoadDataListener;
import com.sandboxol.game.utils.PreUtils;
import com.sandboxol.game.webapi.GameWebApi;

import java.util.List;

/**
 * Created by luoweiyi on 16/2/26.
 */
public class LoadFindGame extends AsyncTask<Void, Void, GameListResult> {

    private FindItem mList;
    private long mUserId;
    private String userKey;
    private Context mContext;
    private LoadDataListener<List<GameData>> mListener;

    public LoadFindGame(Context ctx, FindItem list, long userId, String userKey, LoadDataListener<List<GameData>> listener) {
        this.mContext = ctx;
        this.mList = list;
        this.mUserId = userId;
        this.userKey = userKey;
        this.mListener = listener;
    }

    @Override
    protected GameListResult doInBackground(Void... params) {
        int areaId = PreUtils.NewInstance(mContext).getCurrentRegionId();
        return GameWebApi.findGame(mList, mUserId, userKey, areaId);
    }

    @Override
    protected void onPostExecute(GameListResult result) {
        super.onPostExecute(result);
        mListener.postDate(result.getGameList());
    }
}
