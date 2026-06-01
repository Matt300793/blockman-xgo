package com.sandboxol.blockymods.entity.dao;

import android.support.annotation.NonNull;

/**
 * Created by Bob on 2017/10/25.
 */
public class AccountDbHelper extends IDbHelper {

    private static AccountDbHelper me = null;
    private AccountDao accountDao;

    private AccountDbHelper(@NonNull String dbName) {
        super(dbName);
    }

    public synchronized static AccountDbHelper newInstance() {
        if (me == null)
            me = new AccountDbHelper("bm-account-db");
        return me;
    }

    @Override
    protected void init(DaoSession daoSession) {
        accountDao = daoSession.getAccountDao();
    }


}
