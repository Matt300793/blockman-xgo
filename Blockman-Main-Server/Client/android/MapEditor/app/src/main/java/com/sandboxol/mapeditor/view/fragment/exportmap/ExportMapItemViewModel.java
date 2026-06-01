package com.sandboxol.mapeditor.view.fragment.exportmap;

import android.content.Context;
import android.databinding.ObservableField;

import com.sandboxol.common.base.viewmodel.ListItemViewModel;
import com.sandboxol.common.command.ReplyCommand;
import com.sandboxol.common.messenger.Messenger;
import com.sandboxol.mapeditor.R;
import com.sandboxol.mapeditor.config.MessageToken;
import com.sandboxol.mapeditor.entity.dao.McMap;
import com.sandboxol.mapeditor.utils.FileUtils;

import java.util.List;

/**
 * Created by Jimmy on 2017/11/29 0029.
 */
public class ExportMapItemViewModel extends ListItemViewModel<McMap> {

    public ObservableField<String> image = new ObservableField<>();
    public ObservableField<String> name = new ObservableField<>();
    public ObservableField<String> size = new ObservableField<>();
    public ObservableField<Boolean> isChecked = new ObservableField<>();

    public ReplyCommand onItemClickCommand = new ReplyCommand(this::onItemClick);
    private List<McMap> data;
    private List<Object> exportItems;

    public ExportMapItemViewModel(Context context, McMap item, List<McMap> data, List<Object> exportItems, boolean isChecked) {
        super(context, item);
        this.data = data;
        this.exportItems = exportItems;
        initUI(isChecked);
        initMessages();
    }

    private void initMessages() {
        Messenger.getDefault().register(this, MessageToken.EXPORT_MY_MAP_SELECT_ALL, Boolean.class, isSelectAll -> {
            isChecked.set(isSelectAll);
            notifyRemoveItem();
        });
    }

    private void initUI(boolean isChecked) {
        this.image.set(item.getImage());
        this.name.set(item.getName());
        this.size.set(context.getResources().getString(R.string.my_map_size, FileUtils.getFileSizeWithByte(context, item.getSize())));
        this.isChecked.set(isChecked);
        notifyRemoveItem();
    }

    private void onItemClick() {
        isChecked.set(!isChecked.get());
        notifyRemoveItem();
    }

    private void notifyRemoveItem() {
        if (isChecked.get()) {
            if (exportItems.contains(item))
                return;
            exportItems.add(item);
            if (data.size() == exportItems.size()) {
                Messenger.getDefault().send(true, MessageToken.CHANGE_EXPORT_SELECT_ALL);
            }
            if (exportItems.size() == 1) {
                Messenger.getDefault().send(true, MessageToken.ENABLED_EXPORT);
            }
        } else {
            if (exportItems.contains(item)) {
                exportItems.remove(item);
                Messenger.getDefault().send(false, MessageToken.CHANGE_EXPORT_SELECT_ALL);
            }
            if (exportItems.size() == 0) {
                Messenger.getDefault().send(false, MessageToken.ENABLED_EXPORT);
            }
        }
    }

    @Override
    public void onDestroy() {
        super.onDestroy();
        Messenger.getDefault().unregister(this, MessageToken.EXPORT_MY_MAP_SELECT_ALL);
    }
}
