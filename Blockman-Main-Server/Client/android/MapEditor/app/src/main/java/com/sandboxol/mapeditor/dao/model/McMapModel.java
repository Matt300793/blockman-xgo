package com.sandboxol.mapeditor.dao.model;

import android.net.Uri;
import android.support.annotation.NonNull;
import android.text.TextUtils;

import com.sandboxol.common.base.dao.DaoException;
import com.sandboxol.common.base.dao.DaoSubscribe;
import com.sandboxol.common.base.model.IModel;
import com.sandboxol.common.base.web.HttpPageListSubscriber;
import com.sandboxol.common.base.web.HttpResponse;
import com.sandboxol.common.base.web.OnResponseListener;
import com.sandboxol.common.utils.ResponseUtils;
import com.sandboxol.common.widget.rv.pagerv.PageData;
import com.sandboxol.mapeditor.config.FileConstant;
import com.sandboxol.mapeditor.dao.helper.McMapHelper;
import com.sandboxol.mapeditor.entity.dao.McMap;
import com.sandboxol.mapeditor.utils.FileUtils;
import com.sandboxol.mapeditor.utils.ZipUtils;

import java.io.File;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import rx.Observable;
import rx.android.schedulers.AndroidSchedulers;
import rx.exceptions.Exceptions;
import rx.functions.Func1;
import rx.schedulers.Schedulers;

/**
 * Created by Jimmy on 2017/11/29 0029.
 */
public class McMapModel implements IModel {

    private static McMapModel instance;

    private McMapModel() {
    }

    public static McMapModel newInstance() {
        if (instance == null) {
            instance = new McMapModel();
        }
        return instance;
    }

    public McMap findMyMap(long mapId) {
        return McMapHelper.newInstance().findMyMap(mapId);
    }

    public McMap findMyMap(String name) {
        return McMapHelper.newInstance().findMyMap(name);
    }

    public long insertMyMap(McMap map) {
        return McMapHelper.newInstance().insertMcMap(map);
    }

    public void updateMyMap(McMap map) {
        McMapHelper.newInstance().updateMcMap(map);
    }

    public void deleteMyMap(long mapId) {
        McMapHelper.newInstance().deleteMcMap(mapId);
    }

    public void getMyMaps(int page, int size, OnResponseListener<PageData<McMap>> listener) {
        Observable.just(McMapHelper.newInstance().getMcMaps(page, size))
                .flatMap(new Func1<List<McMap>, Observable<HttpResponse<PageData<McMap>>>>() {
                    @Override
                    public Observable<HttpResponse<PageData<McMap>>> call(List<McMap> maps) {
                        PageData<McMap> data = getMyMapPageData(page, size);
                        List<McMap> result = new ArrayList<>();
                        for (McMap map : maps) {
                            if (new File(FileConstant.MY_MAP_DIR, map.getName()).exists()) {
                                result.add(map);
                            } else {
                                McMapHelper.newInstance().deleteMcMap(map.getId());
                            }
                        }
                        data.setData(result);
                        return Observable.just(ResponseUtils.success(data));
                    }
                })
                .subscribeOn(Schedulers.newThread())
                .observeOn(AndroidSchedulers.mainThread())
                .subscribe(new HttpPageListSubscriber<>(listener));
    }

    private PageData<McMap> getMyMapPageData(int page, int size) {
        PageData<McMap> data = new PageData<>();
        data.setPageNo(page);
        data.setPageSize(size);
        long count = McMapHelper.newInstance().getMcMapsCount();
        data.setTotalPage((int) (count % size == 0 ? count / size : count / size + 1));
        return data;
    }

    public void importMaps(List<Uri> uris, @NonNull OnResponseListener<Map<McMap, Boolean>> listener) {
        Map<McMap, Boolean> results = new HashMap<>();
        Observable.just(uris)
                .flatMap(new Func1<List<Uri>, Observable<Map<McMap, Boolean>>>() {
                    @Override
                    public Observable<Map<McMap, Boolean>> call(List<Uri> uris) {
                        for (Uri uri : uris) {
                            importMap(uri, results);
                        }
                        return Observable.just(results);
                    }
                })
                .subscribeOn(Schedulers.newThread())
                .observeOn(AndroidSchedulers.mainThread())
                .subscribe(new DaoSubscribe<>(listener));
    }

    public void importMap(Uri uri, @NonNull OnResponseListener<McMap> listener) {
        Map<McMap, Boolean> results = new HashMap<>();
        Observable.just(uri)
                .flatMap(new Func1<Uri, Observable<McMap>>() {
                    @Override
                    public Observable<McMap> call(Uri uri) {
                        importMap(uri, results);
                        if (results.size() > 0) {
                            return Observable.just(results.keySet().iterator().next());
                        }
                        throw Exceptions.propagate(new DaoException(1001));
                    }
                })
                .subscribeOn(Schedulers.newThread())
                .observeOn(AndroidSchedulers.mainThread())
                .subscribe(new DaoSubscribe<>(listener));
    }

    private void importMap(Uri uri, Map<McMap, Boolean> results) {
        File zipMap = FileUtils.getFile(uri);
        String targetName = zipMap.getName().replace(".zip", "");
        Observable.just(zipMap)
                .filter(map -> {
                    McMap mcMap = findMyMap(targetName);
                    if (mcMap == null) {
                        return true;
                    }
                    results.put(mcMap, false);
                    return false;
                })
                .doOnNext(map -> FileUtils.deleteFolder(new File(FileConstant.MY_MAP_DIR, map.getName().replace(".zip", ""))))
                .filter(map -> ZipUtils.upZipFile(map, FileConstant.MY_MAP_DIR))
                .doOnNext(map -> {
                    String root = ZipUtils.getZipRootFileName(map);
                    if (root != null && !TextUtils.equals(targetName, root)) {
                        FileUtils.renameFile(new File(FileConstant.MY_MAP_DIR, root), new File(FileConstant.MY_MAP_DIR, targetName));
                    }
                })
                .filter(map -> new File(FileConstant.MY_MAP_DIR + File.separator + targetName, "level.dat").exists())
                .doOnNext(map -> {
                    File target = new File(FileConstant.MY_MAP_DIR, targetName);
                    McMap mcMap = new McMap();
                    mcMap.setName(target.getName());
                    if (target.isDirectory()) {
                        mcMap.setSize(FileUtils.getFolderSize(target));
                    } else {
                        mcMap.setSize(FileUtils.getFileSize(target));
                    }
                    insertMyMap(mcMap);
                    results.put(mcMap, true);
                })
                .subscribe();
    }

    public void copyMcMap(McMap source, String name, OnResponseListener<McMap> listener) {
        Observable.just(name)
                .flatMap(new Func1<String, Observable<Boolean>>() {
                    @Override
                    public Observable<Boolean> call(String name) {
                        return Observable.just(FileUtils.copyFolder(FileConstant.MY_MAP_DIR + File.separator + source.getName(), FileConstant.MY_MAP_DIR + File.separator + name));
                    }
                })
                .doOnNext(isSuccess -> {
                    if (!isSuccess) {
                        FileUtils.deleteFolder(new File(FileConstant.MY_MAP_DIR, name));
                    }
                })
                .filter(isSuccess -> isSuccess)
                .flatMap(new Func1<Boolean, Observable<McMap>>() {
                    @Override
                    public Observable<McMap> call(Boolean isSuccess) {
                        McMap copy = new McMap();
                        copy.setName(name);
                        copy.setImage(source.getImage());
                        copy.setSize(source.getSize());
                        copy.setId(insertMyMap(copy));
                        return Observable.just(copy);
                    }
                })
                .subscribeOn(Schedulers.newThread())
                .observeOn(AndroidSchedulers.mainThread())
                .subscribe(new DaoSubscribe<>(listener));
    }

    public void removeMyMaps(List<Object> maps, OnResponseListener<Integer> listener) {
        Observable.just(maps)
                .flatMap(new Func1<List<Object>, Observable<Integer>>() {
                    @Override
                    public Observable<Integer> call(List<Object> maps) {
                        int count = 0;
                        for (Object map : maps) {
                            if (map instanceof McMap) {
                                removeMyMap((McMap) map);
                                count++;
                            }
                        }
                        return Observable.just(count);
                    }
                })
                .subscribeOn(Schedulers.newThread())
                .observeOn(AndroidSchedulers.mainThread())
                .subscribe(new DaoSubscribe<>(listener));
    }

    private void removeMyMap(McMap map) {
        Observable.just(map)
                .doOnNext(m -> FileUtils.deleteFolder(new File(FileConstant.MY_MAP_DIR, m.getName())))
                .doOnNext(m -> deleteMyMap(m.getId()))
                .doOnNext(m -> BackupManageModel.newInstance().removeMcMapBackupsByMapId(m.getId()))
                .subscribe();
    }

    public void renameMap(McMap item, String name, @NonNull OnResponseListener<McMap> listener) {
        Observable.just(item)
                .subscribeOn(Schedulers.io())
                .filter(map -> !TextUtils.isEmpty(name) && !TextUtils.equals(name, map.getName()))
                .flatMap(new Func1<McMap, Observable<McMap>>() {
                    @Override
                    public Observable<McMap> call(McMap map) {
                        if (findMyMap(name) == null && !new File(FileConstant.MY_MAP_DIR, name).exists()) {
                            return Observable.just(map);
                        } else {
                            return Observable.just(null);
                        }
                    }
                })
                .observeOn(AndroidSchedulers.mainThread())
                .doOnNext(map -> {
                    if (map == null) {
                        listener.onError(1001, "name is exists");
                    }
                })
                .subscribeOn(Schedulers.io())
                .filter(map -> map != null)
                .doOnNext(map -> FileUtils.renameFile(new File(FileConstant.MY_MAP_DIR, map.getName()), new File(FileConstant.MY_MAP_DIR, name)))
                .doOnNext(map -> map.setName(name))
                .doOnNext(this::updateMyMap)
                .observeOn(AndroidSchedulers.mainThread())
                .subscribe(new DaoSubscribe<>(listener));
    }

    public void exportMyMaps(List<Object> maps, Uri uri, OnResponseListener<Integer> listener) {
        List<McMap> success = new ArrayList<>();
        Observable.just(maps)
                .flatMap(new Func1<List<Object>, Observable<Integer>>() {
                    @Override
                    public Observable<Integer> call(List<Object> list) {
                        for (Object map : maps) {
                            if (map instanceof McMap) {
                                exportMyMap((McMap) map, uri.getPath(), success);
                            }
                        }
                        return Observable.just(success.size());
                    }
                })
                .subscribeOn(Schedulers.newThread())
                .observeOn(AndroidSchedulers.mainThread())
                .subscribe(new DaoSubscribe<>(listener));
    }

    private void exportMyMap(McMap map, String path, List<McMap> success) {
        Observable.just(map)
                .filter(m -> FileUtils.copyFolder(FileConstant.MY_MAP_DIR + File.separator + m.getName(), path + File.separator + m.getName()))
                .subscribe(success::add);
    }
}
