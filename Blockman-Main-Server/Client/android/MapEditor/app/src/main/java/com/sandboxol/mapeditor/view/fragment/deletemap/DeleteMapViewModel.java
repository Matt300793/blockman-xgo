package com.sandboxol.mapeditor.view.fragment.deletemap;

import android.content.Context;
import android.databinding.ObservableField;

import com.sandboxol.common.base.viewmodel.ViewModel;
import com.sandboxol.common.command.ReplyCommand;
import com.sandboxol.common.messenger.Messenger;
import com.sandboxol.mapeditor.R;
import com.sandboxol.mapeditor.config.MessageToken;
import com.sandboxol.mapeditor.view.dialog.YerOrNoDialog;

/**
 * Created by Jimmy on 2017/12/1 0001.
 */
public class DeleteMapViewModel extends ViewModel {

    private Context context;

    public DeleteMapListModel deleteMapListModel;

    public ReplyCommand<Boolean> onAllClickCommand = new ReplyCommand<>(this::onAllClick);
    public ReplyCommand onDeleteCommand = new ReplyCommand<>(this::onDeleteClick);

    public ObservableField<Boolean> isAllSelected = new ObservableField<>(false);
    public ObservableField<Boolean> isEnableDelete = new ObservableField<>(false);

    public DeleteMapViewModel(Context context) {
        this.context = context;
        deleteMapListModel = new DeleteMapListModel(context, R.string.my_map_no_map);
        initMessages();
    }

    private void initMessages() {
        Messenger.getDefault().register(this, MessageToken.CHANGE_REMOVE_SELECT_ALL, Boolean.class, isChecked -> {
            if (isAllSelected.get() != isChecked) {
                isAllSelected.set(isChecked);
                deleteMapListModel.setChecked(isChecked);
            }
        });
        Messenger.getDefault().register(this, MessageToken.ENABLED_REMOVE, Boolean.class, isEnableDelete::set);
    }

    private void onAllClick() {
        isAllSelected.set(!isAllSelected.get());
        deleteMapListModel.setChecked(isAllSelected.get());
        Messenger.getDefault().send(isAllSelected.get(), MessageToken.REMOVE_MY_MAP_SELECT_ALL);
    }

    private void onDeleteClick() {
        showDeleteDialog();
    }

    private void showDeleteDialog() {
        new YerOrNoDialog(context)
                .setContentText(R.string.delete_map_delete_hint)
                .setConfirmListener(() -> deleteMapListModel.deleteRemoveItems())
                .show();
    }

    @Override
    public void onDestroy() {
        super.onDestroy();
        Messenger.getDefault().unregister(this);
    }
}
