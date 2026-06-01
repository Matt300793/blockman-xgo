package com.sandboxol.mapeditor.dao.helper;

import android.support.annotation.NonNull;

import com.sandboxol.mapeditor.entity.dao.DaoSession;
import com.sandboxol.mapeditor.entity.dao.McMap;
import com.sandboxol.mapeditor.entity.dao.McMapDao;

import java.util.List;

/**
 * Created by Jimmy on 2017/11/30 0030.
 */
public class McMapHelper extends IDbHelper {

    private static McMapHelper instance = null;
    private McMapDao dao;

    public synchronized static McMapHelper newInstance() {
        if (instance == null)
            instance = new McMapHelper("mc-map-db");
        return instance;
    }

    private McMapHelper(@NonNull String dbName) {
        super(dbName);
    }

    @Override
    protected void init(DaoSession daoSession) {
        dao = daoSession.getMcMapDao();
    }

    public long insertMcMap(McMap map) {
        return dao.insertOrReplace(map);
    }

    public void updateMcMap(McMap map) {
        dao.rx().update(map).subscribe();
    }

    public void insertMcMaps(List<McMap> maps) {
        dao.rx().insertOrReplaceInTx(maps).subscribe();
    }

    public void deleteMcMap(long mapId) {
        dao.rx().deleteByKey(mapId).subscribe();
    }

    public McMap findMyMap(long mapId) {
        return dao.load(mapId);
    }

    public McMap findMyMap(String name) {
        return dao.queryBuilder().where(McMapDao.Properties.Name.eq(name)).unique();
    }

    public List<McMap> getMcMaps(int page, int size) {
        return dao.queryBuilder().offset(page * size).limit(size).list();
    }

    public long getMcMapsCount() {
        return dao.queryBuilder().count();
    }

}
