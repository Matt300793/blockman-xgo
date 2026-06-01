package com.sandboxol.mapeditor.view.fragment.exportmap;

import android.app.Activity;
import android.content.Context;
import android.content.Intent;
import android.databinding.ObservableField;
import android.os.Environment;
import android.text.TextUtils;

import com.sandboxol.common.base.viewmodel.ViewModel;
import com.sandboxol.common.command.ReplyCommand;
import com.sandboxol.common.messenger.Messenger;
import com.sandboxol.common.utils.CommonHelper;
import com.sandboxol.mapeditor.R;
import com.sandboxol.mapeditor.config.FileConstant;
import com.sandboxol.mapeditor.config.MessageToken;
import com.sandboxol.mapeditor.config.StringConstant;
import com.sandboxol.mapeditor.utils.IntentUtils;
import com.sandboxol.mapeditor.utils.McUtils;
import com.sandboxol.mapeditor.view.activity.filechooser.FileChooserActivity;

import java.io.File;

/**
 * Created by Jimmy on 2017/12/1 0001.
 */
public class ExportMapViewModel extends ViewModel {

    private static final int REQUEST_CODE_EXPORT = 1001;

    private Context context;

    public ExportMapListModel exportMapListModel;
    public ObservableField<Boolean> isAllSelected = new ObservableField<>(false);
    public ObservableField<Boolean> isEnableExport = new ObservableField<>(false);

    public ReplyCommand<Boolean> onAllClickCommand = new ReplyCommand<>(this::onAllClick);
    public ReplyCommand onExportCommand = new ReplyCommand<>(this::onExportClick);

    public ExportMapViewModel(Context context) {
        this.context = context;
        exportMapListModel = new ExportMapListModel(context, R.string.my_map_no_map);
        initMessages();
    }

    private void initMessages() {
        Messenger.getDefault().register(this, MessageToken.CHANGE_EXPORT_SELECT_ALL, Boolean.class, isChecked -> {
            if (isAllSelected.get() != isChecked) {
                isAllSelected.set(isChecked);
                exportMapListModel.setChecked(isChecked);
            }
        });
        Messenger.getDefault().register(this, MessageToken.ENABLED_EXPORT, Boolean.class, isEnableExport::set);
    }

    private void onAllClick() {
        isAllSelected.set(!isAllSelected.get());
        exportMapListModel.setChecked(isAllSelected.get());
        Messenger.getDefault().send(isAllSelected.get(), MessageToken.EXPORT_MY_MAP_SELECT_ALL);
    }

    void onActivityResult(int requestCode, int resultCode, Intent data) {
        switch (requestCode) {
            case REQUEST_CODE_EXPORT:
                onExport(resultCode, data);
                break;
        }
    }

    private void onExport(int resultCode, Intent data) {
        if (resultCode == FileChooserActivity.RESULT_CODE_EXPORT && data.getData() != null) {
            exportMapListModel.exportItems(data.getData());
        }
    }

    private void onExportClick() {
        String path = McUtils.getMcMapPath(context);
        File dir = new File(path);
        if (!dir.exists()) {
            dir.mkdirs();
        }
        IntentUtils.startFileChooserActivity((Activity) context, FileConstant.TYPE_ZIP, path, REQUEST_CODE_EXPORT);
    }

    @Override
    public void onDestroy() {
        super.onDestroy();
        Messenger.getDefault().unregister(this);
    }
}
