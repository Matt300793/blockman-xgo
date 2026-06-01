package com.sandboxol.mapeditor.utils;

import android.content.Context;

import com.sandboxol.common.base.dao.DaoSubscribe;
import com.sandboxol.common.base.web.OnResponseListener;
import com.sandboxol.mapeditor.R;
import com.sandboxol.mapeditor.config.FileConstant;
import com.sandboxol.mapeditor.dao.model.BackupManageModel;
import com.sandboxol.mapeditor.dao.model.McMapModel;
import com.sandboxol.mapeditor.entity.dao.McMap;
import com.sandboxol.mapeditor.entity.dao.McMapBackup;

import java.io.File;

import rx.Observable;
import rx.android.schedulers.AndroidSchedulers;
import rx.functions.Func1;
import rx.schedulers.Schedulers;

/**
 * Created by Jimmy on 2017/12/4 0004.
 */
public class MapUtils {

    public static void backupMap(Context context, long mapId, OnResponseListener<McMapBackup> listener) {
        Observable.just(McMapModel.newInstance().findMyMap(mapId))
                .filter(map -> map != null)
                .flatMap(new Func1<McMap, Observable<McMapBackup>>() {
                    @Override
                    public Observable<McMapBackup> call(McMap map) {
                        return BackupManageModel.newInstance().backupMcMap(map, getBackupName(context, map.getName()));
                    }
                })
                .subscribeOn(Schedulers.newThread())
                .observeOn(AndroidSchedulers.mainThread())
                .subscribe(new DaoSubscribe<>(listener));
    }

    private static String getBackupName(Context context, String name) {
        String pre = name + context.getResources().getString(R.string.map_backup);
        int index = 1;
        while (new File(FileConstant.MY_MAP_BACKUP_DIR, pre + index).exists()) {
            index++;
        }
        return pre + index;
    }

}
