package com.sandboxol.mapeditor.view.fragment.mymap;

import android.app.Activity;
import android.content.Context;
import android.content.Intent;
import android.net.Uri;
import android.view.View;

import com.sandboxol.common.base.viewmodel.ViewModel;
import com.sandboxol.common.base.web.OnResponseListener;
import com.sandboxol.common.messenger.Messenger;
import com.sandboxol.common.utils.TemplateUtils;
import com.sandboxol.common.utils.ToastUtils;
import com.sandboxol.common.widget.rv.msg.InsertMsg;
import com.sandboxol.mapeditor.R;
import com.sandboxol.mapeditor.config.FileConstant;
import com.sandboxol.mapeditor.config.MessageToken;
import com.sandboxol.mapeditor.config.StringConstant;
import com.sandboxol.mapeditor.dao.model.McMapModel;
import com.sandboxol.mapeditor.entity.dao.McMap;
import com.sandboxol.mapeditor.utils.IntentUtils;
import com.sandboxol.mapeditor.view.activity.filechooser.FileChooserActivity;
import com.sandboxol.mapeditor.view.fragment.backupmanager.BackupManageFragment;
import com.sandboxol.mapeditor.view.fragment.deletemap.DeleteMapFragment;
import com.sandboxol.mapeditor.view.fragment.editormap.EditorMapFragment;
import com.sandboxol.mapeditor.view.fragment.exportmap.ExportMapFragment;
import com.sandboxol.mapeditor.view.widget.MoreView;

import java.util.ArrayList;
import java.util.List;
import java.util.Map;

import rx.Observable;

/**
 * Created by Jimmy on 2017/11/29 0029.
 */
public class MyMapViewModel extends ViewModel {

    private final int TYPE_EXPORT = 0;
    private final int TYPE_IMPORT = 1;
    private final int TYPE_EDITOR = 2;
    private final int TYPE_DELETE = 3;
    private final int TYPE_BACKUP = 4;

    private final int REQUEST_CODE_IMPORT = 1001;

    private Activity activity;

    public MyMapListModel myMapListModel;

    public MyMapViewModel(Context context) {
        this.activity = (Activity) context;
        myMapListModel = new MyMapListModel(activity, R.string.my_map_no_map);
    }

    void onMoreClick(View v) {
        new MoreView(activity).setOnMoreItemClickListener(position -> {
            switch (position) {
                case TYPE_EXPORT:
                    TemplateUtils.startTemplate(activity, ExportMapFragment.class, activity.getResources().getString(R.string.export_map_title));
                    break;
                case TYPE_IMPORT:
                    IntentUtils.startFileChooserActivity(activity, FileConstant.TYPE_ZIP, REQUEST_CODE_IMPORT);
                    break;
                case TYPE_EDITOR:
                    TemplateUtils.startTemplate(activity, EditorMapFragment.class, activity.getResources().getString(R.string.editor_map_title));
                    break;
                case TYPE_DELETE:
                    TemplateUtils.startTemplate(activity, DeleteMapFragment.class, activity.getResources().getString(R.string.delete_map_title));
                    break;
                case TYPE_BACKUP:
                    TemplateUtils.startTemplate(activity, BackupManageFragment.class, activity.getResources().getString(R.string.my_map_backup));
                    break;
            }
        }).showAsDropDown(v);
    }

    void onActivityResult(int requestCode, int resultCode, Intent data) {
        switch (requestCode) {
            case REQUEST_CODE_IMPORT:
                if (resultCode == FileChooserActivity.RESULT_CODE_IMPORT_FIlES) {
                    importMaps(data);
                }
                break;
        }
    }

    private void importMaps(Intent data) {
        ArrayList<Uri> uris = data.getParcelableArrayListExtra(StringConstant.SELECTED_FILE_URI);
        if (uris != null) {
            McMapModel.newInstance().importMaps(uris, new OnResponseListener<Map<McMap, Boolean>>() {
                @Override
                public void onSuccess(Map<McMap, Boolean> data) {
                    List<McMap> success = new ArrayList<>();
                    List<McMap> failed = new ArrayList<>();
                    Observable.from(data.keySet())
                            .subscribe(map -> {
                                if (data.get(map)) {
                                    success.add(map);
                                } else {
                                    failed.add(map);
                                }
                            });
                    if (success.size() > 0) {
                        Messenger.getDefault().send(InsertMsg.createEnd(success), MessageToken.IMPORT_MY_MAP);
                        ToastUtils.showShortToast(activity, activity.getResources().getString(R.string.my_map_export_success, success.size(), failed.size()));
                    } else {
                        ToastUtils.showShortToast(activity, activity.getResources().getString(R.string.my_map_export_failed));
                    }
                }

                @Override
                public void onError(int code, String msg) {

                }

                @Override
                public void onServerError(int error) {
                    ToastUtils.showShortToast(activity, activity.getResources().getString(R.string.my_map_export_failed));
                }
            });
        }
    }

}
