package com.sandboxol.blockymods.entity.dao;

import android.content.Context;
import android.database.sqlite.SQLiteDatabase;
import android.support.annotation.NonNull;

import com.sandboxol.blockymods.App;

/**
 * Created by Mr.Luo on 2016/12/1.
 */

abstract class IDbHelper {

    protected final String TAG = IDbHelper.class.getSimpleName();
    protected Context context;

    IDbHelper(@NonNull String dbName) {
        context = App.getApp();
        DaoMaster.DevOpenHelper helper = new DaoMaster.DevOpenHelper(context, dbName, null);
        SQLiteDatabase db = helper.getWritableDatabase();
        DaoMaster daoMaster = new DaoMaster(db);
        DaoSession daoSession = daoMaster.newSession();
        init(daoSession);
    }

    protected abstract void init(DaoSession daoSession);
}
