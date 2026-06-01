package com.sandboxol.mapeditor.dao.helper;

import android.support.annotation.NonNull;

import com.sandboxol.mapeditor.entity.dao.DaoSession;
import com.sandboxol.mapeditor.entity.dao.McMapBackup;
import com.sandboxol.mapeditor.entity.dao.McMapBackupDao;

import java.util.List;

/**
 * Created by Jimmy on 2017/12/2 0002.
 */
public class McMapBackupHelper extends IDbHelper {

    private static McMapBackupHelper instance = null;
    private McMapBackupDao dao;

    public synchronized static McMapBackupHelper newInstance() {
        if (instance == null)
            instance = new McMapBackupHelper("mc-map-backup-db");
        return instance;
    }

    private McMapBackupHelper(@NonNull String dbName) {
        super(dbName);
    }

    @Override
    protected void init(DaoSession daoSession) {
        dao = daoSession.getMcMapBackupDao();
    }

    public List<McMapBackup> getMcMapBackupByMcMapId(long mapId) {
        return dao.queryBuilder().where(McMapBackupDao.Properties.MapId.eq(mapId)).orderDesc(McMapBackupDao.Properties.Time).list();
    }

    public long getMcMapBackupCountByMcMapId(long mapId) {
        return dao.queryBuilder().where(McMapBackupDao.Properties.MapId.eq(mapId)).count();
    }

    public long insertMcMapBackup(McMapBackup backup) {
        return dao.insertOrReplace(backup);
    }

    public void deleteMcMapBackupByName(String name) {
        McMapBackup backup = dao.queryBuilder().where(McMapBackupDao.Properties.Name.eq(name)).unique();
        if (backup != null) {
            deleteMcMapBackup(backup.getId());
        }
    }

    public void deleteMcMapBackup(long backupId) {
        dao.rx().deleteByKey(backupId).subscribe();
    }

}
