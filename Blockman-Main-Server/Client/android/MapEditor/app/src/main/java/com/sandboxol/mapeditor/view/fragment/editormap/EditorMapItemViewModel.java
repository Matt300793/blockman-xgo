package com.sandboxol.mapeditor.view.fragment.editormap;

import android.content.Context;
import android.databinding.ObservableField;
import android.text.TextUtils;

import com.sandboxol.common.base.viewmodel.ListItemViewModel;
import com.sandboxol.common.base.web.OnResponseListener;
import com.sandboxol.common.command.ReplyCommand;
import com.sandboxol.common.messenger.Messenger;
import com.sandboxol.common.utils.ToastUtils;
import com.sandboxol.common.widget.rv.msg.InsertMsg;
import com.sandboxol.mapeditor.R;
import com.sandboxol.mapeditor.config.FileConstant;
import com.sandboxol.mapeditor.config.MessageToken;
import com.sandboxol.mapeditor.dao.helper.McMapHelper;
import com.sandboxol.mapeditor.dao.model.McMapModel;
import com.sandboxol.mapeditor.entity.dao.McMap;
import com.sandboxol.mapeditor.utils.FileUtils;
import com.sandboxol.mapeditor.view.dialog.EditorMapDialog;
import com.sandboxol.mapeditor.view.dialog.MapRenameDialog;

import java.io.File;

/**
 * Created by Jimmy on 2017/11/29 0029.
 */
public class EditorMapItemViewModel extends ListItemViewModel<McMap> {

    public ObservableField<String> image = new ObservableField<>();
    public ObservableField<String> name = new ObservableField<>();
    public ObservableField<String> size = new ObservableField<>();
    public ReplyCommand onEditorCommand = new ReplyCommand(this::onEditorClick);

    public EditorMapItemViewModel(Context context, McMap item) {
        super(context, item);
        initUI();
    }

    private void initUI() {
        image.set(item.getImage());
        name.set(item.getName());
        size.set(context.getResources().getString(R.string.my_map_size, FileUtils.getFileSizeWithByte(context, item.getSize())));
    }

    private void onEditorClick() {
        new EditorMapDialog(context)
                .setMapName(name.get())
                .setOnItemClickListener(this::onEditorItemClick)
                .show();
    }

    private void onEditorItemClick(EditorMapDialog.EditorType type) {
        switch (type) {
            case RENAME:
                showRenameDialog();
                break;
            case COPY:
                copyMap();
                break;
            case MODEL:

                break;
        }
    }

    private void copyMap() {
        String name = getCopyName();
        McMapModel.newInstance().copyMcMap(item, name, new OnResponseListener<McMap>() {
            @Override
            public void onSuccess(McMap data) {
                Messenger.getDefault().send(InsertMsg.createEnd(data), MessageToken.IMPORT_MY_MAP);
                ToastUtils.showShortToast(context, R.string.editor_map_copy_success);
            }

            @Override
            public void onError(int code, String msg) {
                
            }

            @Override
            public void onServerError(int error) {
                ToastUtils.showShortToast(context, R.string.editor_map_copy_failed);
            }
        });
    }

    private String getCopyName() {
        String pre = item.getName() + context.getResources().getString(R.string.map_copy);
        int index = 1;
        while (new File(FileConstant.MY_MAP_DIR, pre + index).exists()) {
            index++;
        }
        return pre + index;
    }

    private void showRenameDialog() {
        new MapRenameDialog(context)
                .setMapName(name.get())
                .setOnButtonClickListener(this::rename).show();
    }

    private void rename(String rename) {
        McMapModel.newInstance().renameMap(item, rename, new OnResponseListener<McMap>() {
            @Override
            public void onSuccess(McMap data) {
                name.set(rename);
                Messenger.getDefault().sendNoMsg(String.format(MessageToken.CHANGE_MY_MAP, data.getId()));
                ToastUtils.showShortToast(context, R.string.editor_map_editor_success);
            }

            @Override
            public void onError(int code, String msg) {
                if (code == 1001) {
                    ToastUtils.showShortToast(context, R.string.editor_map_editor_failed_name);
                }
            }

            @Override
            public void onServerError(int error) {
                ToastUtils.showShortToast(context, R.string.editor_map_editor_failed);
            }
        });
    }

}
