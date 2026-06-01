package com.sandboxol.mapeditor.view.fragment.editormap;

import com.sandboxol.common.base.app.TemplateFragment;
import com.sandboxol.mapeditor.R;
import com.sandboxol.mapeditor.databinding.FragmentEditorMapBinding;

/**
 * Created by Jimmy on 2017/12/1 0001.
 */
public class EditorMapFragment extends TemplateFragment<EditorMapViewModel, FragmentEditorMapBinding>{

    @Override
    protected int getLayoutId() {
        return R.layout.fragment_editor_map;
    }

    @Override
    protected EditorMapViewModel getViewModel() {
        return new EditorMapViewModel(context);
    }

    @Override
    protected void bindViewModel(FragmentEditorMapBinding binding, EditorMapViewModel viewModel) {
        binding.setEditorMapViewModel(viewModel);
    }
}
