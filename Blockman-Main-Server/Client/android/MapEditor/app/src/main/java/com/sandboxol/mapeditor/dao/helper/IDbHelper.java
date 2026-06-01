package com.sandboxol.mapeditor.dao.helper;

import android.database.sqlite.SQLiteDatabase;
import android.support.annotation.NonNull;

import com.sandboxol.mapeditor.App;
import com.sandboxol.mapeditor.entity.dao.DaoMaster;
import com.sandboxol.mapeditor.entity.dao.DaoSession;

/**
 * Created by Mr.Luo on 2016/12/1.
 */

public abstract class IDbHelper {

    public IDbHelper(@NonNull String dbName) {
        DaoMaster.DevOpenHelper helper = new DaoMaster.DevOpenHelper(App.getApp(), dbName, null);
        SQLiteDatabase db = helper.getWritableDatabase();
        DaoMaster daoMaster = new DaoMaster(db);
        DaoSession daoSession = daoMaster.newSession();
        init(daoSession);
    }

    protected abstract void init(DaoSession daoSession);


}
