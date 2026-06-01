package com.sandboxol.mapeditor.view.fragment.mymap;

import android.content.Context;
import android.databinding.ObservableField;

import com.sandboxol.common.base.viewmodel.ListItemViewModel;
import com.sandboxol.common.messenger.Messenger;
import com.sandboxol.mapeditor.R;
import com.sandboxol.mapeditor.config.MessageToken;
import com.sandboxol.mapeditor.entity.dao.McMap;
import com.sandboxol.mapeditor.utils.FileUtils;

/**
 * Created by Jimmy on 2017/11/29 0029.
 */
public class MyMapItemViewModel extends ListItemViewModel<McMap> {

    public ObservableField<String> image = new ObservableField<>();
    public ObservableField<String> name = new ObservableField<>();
    public ObservableField<String> size = new ObservableField<>();

    public MyMapItemViewModel(Context context, McMap item) {
        super(context, item);
        refreshUI();
        initMessages();
    }

    private void initMessages() {
        Messenger.getDefault().register(this, String.format(MessageToken.CHANGE_MY_MAP, item.getId()), this::refreshUI);
    }

    private void refreshUI() {
        image.set(item.getImage());
        name.set(item.getName());
        size.set(context.getResources().getString(R.string.my_map_size, FileUtils.getFileSizeWithByte(context, item.getSize())));
    }

    @Override
    public void onDestroy() {
        super.onDestroy();
        Messenger.getDefault().unregister(this, String.format(MessageToken.CHANGE_MY_MAP, item.getId()));
    }
}
