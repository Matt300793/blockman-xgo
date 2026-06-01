package com.sandboxol.mapeditor.view.fragment.createmap;

import android.app.Activity;
import android.content.Context;
import android.content.Intent;
import android.databinding.ObservableField;
import android.net.Uri;
import android.os.Environment;

import com.sandboxol.common.base.viewmodel.ViewModel;
import com.sandboxol.common.base.web.OnResponseListener;
import com.sandboxol.common.binding.adapter.RadioGroupBindingAdapters;
import com.sandboxol.common.command.ReplyCommand;
import com.sandboxol.mapeditor.R;
import com.sandboxol.mapeditor.config.FileConstant;
import com.sandboxol.mapeditor.dao.model.McMapModel;
import com.sandboxol.mapeditor.entity.CreateMap;
import com.sandboxol.mapeditor.entity.dao.McMap;
import com.sandboxol.mapeditor.utils.IntentUtils;
import com.sandboxol.mapeditor.view.activity.filechooser.FileChooserActivity;

/**
 * Created by Jimmy on 2017/11/28 0028.
 */
public class CreateMapViewModel extends ViewModel {

    private final int REQUEST_CODE_IMPORT = 1001;

    private Context context;
    private boolean isChooserFile = false;

    private CreateMap map = new CreateMap();

    public ObservableField<Boolean> isShowMapSize = new ObservableField<>(true);
    public ObservableField<Integer> mapLandCheck = new ObservableField<>(R.id.rbSuperFlat);
    public ObservableField<String> importMapName = new ObservableField<>();
    public ObservableField<String> mapName = new ObservableField<>();

    public ReplyCommand<String> onNameChangeAfterCommand = new ReplyCommand<>(name -> map.setName(name));
    public ReplyCommand<RadioGroupBindingAdapters.CheckedDataWrapper> onMapLandChangeCommand = new ReplyCommand<>(data -> onMapLandChange(data.getCheckedId()));
    public ReplyCommand<Integer> onSizeChangeCommand = new ReplyCommand<>(size -> map.setSize(size));

    public CreateMapViewModel(Context context) {
        this.context = context;
        onMapLandChange(R.id.rbSuperFlat);
    }

    private void onMapLandChange(int checkId) {
        switch (checkId) {
            case R.id.rbSuperFlat:
                map.setLand(1);
                isShowMapSize.set(true);
                importMapName.set(context.getResources().getString(R.string.new_map_import_local_map));
                break;
            case R.id.rbSkyLand:
                map.setLand(2);
                isShowMapSize.set(true);
                importMapName.set(context.getResources().getString(R.string.new_map_import_local_map));
                break;
            case R.id.rbImportLocal:
                if (!isChooserFile) {
                    map.setLand(3);
                    isShowMapSize.set(false);
                    IntentUtils.startFileChooserActivity((Activity) context, FileConstant.TYPE_ZIP,
                            Environment.getExternalStorageDirectory().getPath(),
                            FileChooserActivity.TYPE_FILE, REQUEST_CODE_IMPORT);
                }
                isChooserFile = !isChooserFile;
                break;
        }
    }

    void onActivityResult(int requestCode, int resultCode, Intent data) {
        switch (requestCode) {
            case REQUEST_CODE_IMPORT:
                if (resultCode == FileChooserActivity.RESULT_CODE_IMPORT_FIlE) {
                    importMap(data.getData());
                } else {
                    mapLandCheck.set(R.id.rbSuperFlat);
                }
                break;
        }
    }

    private void importMap(Uri uri) {
        if (uri != null) {
            McMapModel.newInstance().importMap(uri, new OnResponseListener<McMap>() {
                @Override
                public void onSuccess(McMap data) {
                    if (data != null) {
                        importMapName.set(data.getName());
                        mapName.set(data.getName());
                        isChooserFile = false;
                    } else {
                        mapLandCheck.set(R.id.rbSuperFlat);
                    }
                }

                @Override
                public void onError(int code, String msg) {

                }

                @Override
                public void onServerError(int error) {

                }
            });
        }
    }

}
