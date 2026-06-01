package com.sandboxol.game.utils;

import android.content.Context;
import android.content.SharedPreferences;

import com.google.gson.Gson;
import com.google.gson.reflect.TypeToken;
import com.sandboxol.game.entity.Region;
import com.sandboxol.game.parse.RegionList;

import java.io.ByteArrayOutputStream;
import java.io.IOException;
import java.io.InputStream;
import java.util.ArrayList;
import java.util.List;

/**
 * Created by luoweiyi on 16/2/27.
 */
public class PreUtils {

    private final static String fileName = "game_module";
    private Context mContext;
    private static PreUtils me = null;

    private PreUtils(Context ctx) {
        mContext = ctx;
    }

    public static PreUtils NewInstance(Context ctx) {
        if (me == null) {
            me = new PreUtils(ctx);
        }
        return me;
    }

    private SharedPreferences getPre() {
        return mContext.getSharedPreferences(fileName, Context.MODE_PRIVATE);
    }

    public boolean putString(String key, String value) {
        SharedPreferences.Editor editor = getPre().edit();
        editor.putString(key, value);
        return editor.commit();
    }

    public String getString(String key, String dfValue) {
        return getPre().getString(key, dfValue);
    }

    public boolean putLong(String key, long value) {
        SharedPreferences.Editor editor = getPre().edit();
        editor.putLong(key, value);
        return editor.commit();
    }

    public long getLong(String key, long dfValue) {
        return getPre().getLong(key, dfValue);
    }

    public boolean putInt(String key, int value) {
        SharedPreferences.Editor editor = getPre().edit();
        editor.putInt(key, value);
        return editor.commit();
    }

    public int getInt(String key, int dfValue) {
        return getPre().getInt(key, dfValue);
    }

    public boolean putBoolean(String key, boolean value) {
        SharedPreferences.Editor editor = getPre().edit();
        editor.putBoolean(key, value);
        return editor.commit();
    }

    public boolean getBoolean(String key, boolean dfValue) {
        return getPre().getBoolean(key, dfValue);
    }

    public boolean putCurrentRegionId(int value) {
        SharedPreferences.Editor editor = getPre().edit();
        editor.putInt(Constant.CURRENT_REGION_ID, value);
        return editor.commit();
    }

    public int getCurrentRegionId() {
        return getPre().getInt(Constant.CURRENT_REGION_ID, 0);
    }

    public boolean putCurrentRegion(String value) {
        SharedPreferences.Editor editor = getPre().edit();
        editor.putString(Constant.CURRENT_REGION_INFO, value);
        return editor.commit();
    }

    public boolean putCurrentRegion(Region value) {
        SharedPreferences.Editor editor = getPre().edit();
        editor.putString(Constant.CURRENT_REGION_INFO, new Gson().toJson(value != null ? value : new Region()));
        return editor.commit();
    }

    public Region getCurrentRegion() {
        String str = getPre().getString(Constant.CURRENT_REGION_INFO, null);
        Gson gson = new Gson();
        if (str != null) {
            try {
                return gson.fromJson(str, Region.class);
            } catch (Exception e) {
                return getRegionItem();
            }
        } else {
            return getRegionItem();
        }
    }

    public boolean putRegionList(String value) {
        SharedPreferences.Editor editor = getPre().edit();
        editor.putString(Constant.REGION_LIST, value);
        return editor.commit();
    }


    public Region getRegionItem() {
        List<Region> list = getRegionList();
        if (list.size() > 0) {
            Region item = list.get(list.size() - 1);
            putCurrentRegionId(item.getId());
            putCurrentRegion(item);
            return item;
        } else {
            Region r = new Region();
            r.setId(1002);
            r.setIp("hall2.sandboxol.com");
            r.setPing(null);
            r.setName("North America");
            r.setHallCreator("http://hall2.sandboxol.com:9121/");
            r.setHallEnter("http://hall2.sandboxol.com:9122/");
            r.setHallQuerier("http://hall2.sandboxol.com:9123/");
            r.setBulletin("bulletin2.sandboxol.com:9511");
            r.setMgsQueue("queue2.mgs.sandboxol.com:9612");
            r.setMgsTeam("queue2.mgs.sandboxol.com:9210");
            r.setMsgOrganizeTeam("queue2.mgs.sandboxol.com:9921");
            r.setMsgBlockManOrganizeTeam("queue.bmg.sandboxol.com:9921");
            putCurrentRegionId(r.getId());
            putCurrentRegion(r);
            return r;
        }
    }

    public List<Region> getRegionList() {
        String str = getPre().getString(Constant.REGION_LIST, null);
        Gson gson = new Gson();
        if (str != null) {
            try {
                return gson.fromJson(str, new TypeToken<List<Region>>() {
                }.getType());
            } catch (Exception e) {
                return loadLocalRegionList();
            }
        } else {
            return loadLocalRegionList();
        }
    }


    public List<Region> loadLocalRegionList() {
        try {
            Gson gson = new Gson();
            InputStream inputStream = mContext.getAssets().open("regionList.json");
            String str = inputStream2String(inputStream);
            RegionList item = gson.fromJson(str, new TypeToken<RegionList>() {
            }.getType());
            if (item != null) {
                putRegionList(gson.toJson(item.getRegionList()));
                return item.getRegionList();
            } else {
                return new ArrayList<>();
            }
        } catch (Exception e) {
            return new ArrayList<>();
        }
    }

    public String inputStream2String(InputStream is) throws IOException {
        ByteArrayOutputStream bao = new ByteArrayOutputStream();
        int i = -1;
        while ((i = is.read()) != -1) {
            bao.write(i);
        }
        bao.close();
        return bao.toString();
    }
}
