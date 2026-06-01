package com.sandboxol.mapeditor.view.fragment.editormap;

import android.content.Context;

import com.sandboxol.common.base.viewmodel.ViewModel;
import com.sandboxol.mapeditor.R;

/**
 * Created by Jimmy on 2017/12/1 0001.
 */
public class EditorMapViewModel extends ViewModel {

    public EditorMapListModel editorMapListModel;

    public EditorMapViewModel(Context context) {
        editorMapListModel = new EditorMapListModel(context, R.string.my_map_no_map);
    }
}
