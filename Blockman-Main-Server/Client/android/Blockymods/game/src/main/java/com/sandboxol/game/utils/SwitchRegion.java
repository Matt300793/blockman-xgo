package com.sandboxol.game.utils;

import android.content.Context;

import com.google.gson.Gson;
import com.sandboxol.game.entity.Region;
import com.sandboxol.game.webapi.GameWebApi;
import com.sandboxol.game.webapi.GameWebUtils;

import java.util.List;

/**
 * Created by luoweiyi on 16/2/27.
 */
public class SwitchRegion {

    private static SwitchRegion mMe;
    private Context mContext;
    private boolean isInit = false;

    public static SwitchRegion newInstance(Context ctx) {
        if (mMe == null) {
            mMe = new SwitchRegion(ctx);
        }
        return mMe;
    }

    public SwitchRegion(Context ctx) {
        this.mContext = ctx;
    }

    public boolean isInit() {
        return isInit;
    }

    public void initApi() {
        Region item = PreUtils.NewInstance(mContext).getCurrentRegion();
        GameWebUtils.creatorApi = null;
        GameWebUtils.enterApi = null;
        GameWebUtils.querierApi = null;

        GameWebUtils.CREATOR_BASE_URL = item.getHallCreator();
        GameWebUtils.ENTER_BASE_URL = item.getHallEnter();
        GameWebUtils.QUERIER_BASE_URL = item.getHallQuerier();
        GameWebUtils.BULLETIN_BASE_URL = item.getBulletin();
        GameWebUtils.MGS_QUEUE_BASE_URL = item.getMgsQueue();
        GameWebUtils.MGS_TEAM_BASE_URL = item.getMgsTeam();
        GameWebUtils.MSG_ORGANIZE_TEAM_BASE_URL = item.getMsgOrganizeTeam();
        GameWebUtils.BLOCK_MAN_MSG_ORGANIZE_TEAM_BASE_URL = item.getMsgBlockManOrganizeTeam();

        // TODO Hall server need set oversea default url.
        if (GameWebUtils.CREATOR_BASE_URL == null) {
            GameWebUtils.CREATOR_BASE_URL = "http://hall2.sandboxol.com:9121/";
        }

        if (GameWebUtils.ENTER_BASE_URL == null) {
            GameWebUtils.ENTER_BASE_URL = "http://hall2.sandboxol.com:9122/";
        }

        if (GameWebUtils.QUERIER_BASE_URL == null) {
            GameWebUtils.QUERIER_BASE_URL = "http://hall2.sandboxol.com:9123/";
        }

        if (GameWebUtils.BULLETIN_BASE_URL == null) {
            GameWebUtils.BULLETIN_BASE_URL = "bulletin2.sandboxol.com:9511";
        }

        if (GameWebUtils.MGS_QUEUE_BASE_URL == null) {
            GameWebUtils.MGS_QUEUE_BASE_URL = "queue2.mgs.sandboxol.com:9612";
        }

        if (GameWebUtils.MGS_TEAM_BASE_URL == null) {
            GameWebUtils.MGS_TEAM_BASE_URL = "queue2.mgs.sandboxol.com:9210";
        }

        if (GameWebUtils.MSG_ORGANIZE_TEAM_BASE_URL == null) {
            GameWebUtils.MSG_ORGANIZE_TEAM_BASE_URL = "queue2.mgs.sandboxol.com:9921";
        }

        if (GameWebUtils.BLOCK_MAN_MSG_ORGANIZE_TEAM_BASE_URL == null) {
            GameWebUtils.BLOCK_MAN_MSG_ORGANIZE_TEAM_BASE_URL = "queue.bmg.sandboxol.com:9921";
        }


        GameWebApi.initGameApi();
        this.isInit = true;
    }

    public boolean switchRegion(int regionId) {
        List<Region> list = PreUtils.NewInstance(mContext).getRegionList();
        boolean switchSucceed = false;
        for (Region item : list) {
            if (item.getId() == regionId) {
                PreUtils.NewInstance(mContext).putCurrentRegionId(regionId);
                PreUtils.NewInstance(mContext).putCurrentRegion(new Gson().toJson(item));
                initApi();
                switchSucceed = true;
                break;
            }
        }

        return switchSucceed;
    }


    public String enterGameSwitchRegion(int regionId) {
        List<Region> list = PreUtils.NewInstance(mContext).getRegionList();
        String url = null;
        for (Region item : list) {
            if (item.getId() == regionId) {
                url = item.getHallEnter();
                break;
            }
        }
        return url;
    }

}
