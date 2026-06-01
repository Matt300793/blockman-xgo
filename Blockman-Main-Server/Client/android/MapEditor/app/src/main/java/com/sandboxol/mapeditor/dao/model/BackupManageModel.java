package com.sandboxol.mapeditor.dao.model;

import com.sandboxol.common.base.dao.DaoException;
import com.sandboxol.common.base.dao.DaoSubscribe;
import com.sandboxol.common.base.web.HttpListSubscriber;
import com.sandboxol.common.base.web.HttpPageListSubscriber;
import com.sandboxol.common.base.web.HttpResponse;
import com.sandboxol.common.base.web.OnResponseListener;
import com.sandboxol.common.utils.ResponseUtils;
import com.sandboxol.common.widget.rv.pagerv.PageData;
import com.sandboxol.mapeditor.config.FileConstant;
import com.sandboxol.mapeditor.dao.helper.McMapBackupHelper;
import com.sandboxol.mapeditor.dao.helper.McMapHelper;
import com.sandboxol.mapeditor.entity.BackupItem;
import com.sandboxol.mapeditor.entity.dao.McMap;
import com.sandboxol.mapeditor.entity.dao.McMapBackup;
import com.sandboxol.mapeditor.utils.FileUtils;

import java.io.File;
import java.util.ArrayList;
import java.util.List;

import rx.Observable;
import rx.android.schedulers.AndroidSchedulers;
import rx.exceptions.Exceptions;
import rx.functions.Func1;
import rx.schedulers.Schedulers;

/**
 * Created by Jimmy on 2017/12/2 0002.
 */
public class BackupManageModel {

    private static BackupManageModel instance;

    private BackupManageModel() {
    }

    public static BackupManageModel newInstance() {
        if (instance == null) {
            instance = new BackupManageModel();
        }
        return instance;
    }

    public long getMcMapBackupCountByMcMapId(long mapId) {
        return McMapBackupHelper.newInstance().getMcMapBackupCountByMcMapId(mapId);
    }

    public List<McMapBackup> getMcMapBackupByMcMapId(long mapId) {
        return McMapBackupHelper.newInstance().getMcMapBackupByMcMapId(mapId);
    }

    public long insertMcMapBackup(McMapBackup backup) {
        return McMapBackupHelper.newInstance().insertMcMapBackup(backup);
    }

    public void deleteMcMapBackupByName(String name) {
        McMapBackupHelper.newInstance().deleteMcMapBackupByName(name);
    }

    public void deleteMcMapBackupById(long backupId) {
        McMapBackupHelper.newInstance().deleteMcMapBackup(backupId);
    }

    public BackupItem getMyMapFormatBackup(McMap map) {
        BackupItem item;
        List<McMapBackup> backups = getMcMapBackupByMcMapId(map.getId());
        if (backups.size() > 0) {
            item = new BackupItem(map, backups.get(0).getTime(), backups.size());
        } else {
            item = new BackupItem(map, 0, 0);
        }
        return item;
    }

    public void getMyMapsFormatBackup(int page, int size, OnResponseListener<PageData<BackupItem>> listener) {
        Observable.just(McMapHelper.newInstance().getMcMaps(page, size))
                .flatMap(new Func1<List<McMap>, Observable<HttpResponse<PageData<BackupItem>>>>() {
                    @Override
                    public Observable<HttpResponse<PageData<BackupItem>>> call(List<McMap> maps) {
                        PageData<BackupItem> data = getMyMapPageData(page, size);
                        List<BackupItem> items = new ArrayList<>();
                        Observable.from(maps)
                                .doOnNext(map -> items.add(getMyMapFormatBackup(map)))
                                .subscribe();
                        data.setData(items);
                        return Observable.just(ResponseUtils.success(data));
                    }
                })
                .subscribeOn(Schedulers.newThread())
                .observeOn(AndroidSchedulers.mainThread())
                .subscribe(new HttpPageListSubscriber<>(listener));
    }

    public Observable<McMapBackup> backupMcMap(McMap map, String name) {
        return Observable.just(map)
                .doOnNext(m -> {
                    File dir = new File(FileConstant.MY_MAP_BACKUP_DIR);
                    if (!dir.exists())
                        dir.mkdir();
                })
                .flatMap(new Func1<McMap, Observable<Boolean>>() {
                    @Override
                    public Observable<Boolean> call(McMap map) {
                        if (getMcMapBackupCountByMcMapId(map.getId()) < 3) {
                            return Observable.just(true);
                        }
                        throw Exceptions.propagate(new DaoException(1001, "backup is full (3)"));
                    }
                })
                .filter(isFull -> isFull)
                .flatMap(new Func1<Boolean, Observable<McMap>>() {
                    @Override
                    public Observable<McMap> call(Boolean aBoolean) {
                        return Observable.just(map);
                    }
                })
                .doOnNext(m -> {
                    File backup = new File(FileConstant.MY_MAP_BACKUP_DIR, name);
                    backup.deleteOnExit();
                    deleteMcMapBackupByName(name);
                })
                .filter(m -> {
                    if (!FileUtils.copyFolder(FileConstant.MY_MAP_DIR + File.separator + m.getName(), FileConstant.MY_MAP_BACKUP_DIR + File.separator + name)) {
                        throw Exceptions.propagate(new DaoException(1002, "copy map failed"));
                    }
                    return true;
                })
                .flatMap(new Func1<McMap, Observable<McMapBackup>>() {
                    @Override
                    public Observable<McMapBackup> call(McMap map) {
                        McMapBackup backup = new McMapBackup();
                        backup.setMapId(map.getId());
                        backup.setName(name);
                        backup.setImage(map.getImage());
                        backup.setTime(System.currentTimeMillis());
                        backup.setId(insertMcMapBackup(backup));
                        return Observable.just(backup);
                    }
                });
    }

    public void removeMcMapBackup(McMapBackup backup, OnResponseListener<McMapBackup> listener) {
        Observable.just(backup)
                .doOnNext(b -> deleteMcMapBackupById(b.getId()))
                .doOnNext(b -> FileUtils.deleteFolder(new File(FileConstant.MY_MAP_BACKUP_DIR, b.getName())))
                .subscribeOn(Schedulers.newThread())
                .observeOn(AndroidSchedulers.mainThread())
                .subscribe(new DaoSubscribe<>(listener));
    }

    public void removeMcMapBackupsByMapId(long mapId) {
        Observable.from(getMcMapBackupByMcMapId(mapId))
                .doOnNext(backup -> FileUtils.deleteFolder(new File(FileConstant.MY_MAP_BACKUP_DIR, backup.getName())))
                .doOnNext(backup -> deleteMcMapBackupById(backup.getId()))
                .subscribe();
    }

    public void getMcMapBackupByMcMapId(long mapId, OnResponseListener<List<McMapBackup>> listener) {
        Observable.just(getMcMapBackupByMcMapId(mapId))
                .flatMap(new Func1<List<McMapBackup>, Observable<HttpResponse<List<McMapBackup>>>>() {
                    @Override
                    public Observable<HttpResponse<List<McMapBackup>>> call(List<McMapBackup> backups) {
                        return Observable.just(ResponseUtils.success(backups));
                    }
                })
                .subscribeOn(Schedulers.newThread())
                .observeOn(AndroidSchedulers.mainThread())
                .subscribe(new HttpListSubscriber<>(listener));
    }

    public void restoreMcMapBackupToMyMap(McMapBackup backup, OnResponseListener<McMapBackup> listener) {
        Observable.just(backup)
                .filter(b -> {
                    McMap map = McMapModel.newInstance().findMyMap(b.getMapId());
                    if (map != null) {
                        FileUtils.deleteFolder(new File(FileConstant.MY_MAP_DIR, map.getName()));
                        boolean result = FileUtils.copyFolder(FileConstant.MY_MAP_BACKUP_DIR + File.separator + b.getName(), FileConstant.MY_MAP_DIR + File.separator + map.getName());
                        if (!result) {
                            throw Exceptions.propagate(new DaoException(1001, "map is destroy"));
                        }
                        return true;
                    }
                    throw Exceptions.propagate(new DaoException(1002, "map is no exist"));
                })
                .subscribeOn(Schedulers.newThread())
                .observeOn(AndroidSchedulers.mainThread())
                .subscribe(new DaoSubscribe<>(listener));
    }

    private PageData<BackupItem> getMyMapPageData(int page, int size) {
        PageData<BackupItem> data = new PageData<>();
        data.setPageNo(page);
        data.setPageSize(size);
        long count = McMapHelper.newInstance().getMcMapsCount();
        data.setTotalPage((int) (count % size == 0 ? count / size : count / size + 1));
        return data;
    }

}
