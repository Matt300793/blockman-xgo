package com.sandboxol.mapeditor.view.fragment.deletemap;

import com.sandboxol.common.base.app.TemplateFragment;
import com.sandboxol.mapeditor.R;
import com.sandboxol.mapeditor.databinding.FragmentDeleteMapBinding;

/**
 * Created by Jimmy on 2017/12/1 0001.
 */
public class DeleteMapFragment extends TemplateFragment<DeleteMapViewModel, FragmentDeleteMapBinding> {

    @Override
    protected int getLayoutId() {
        return R.layout.fragment_delete_map;
    }

    @Override
    protected DeleteMapViewModel getViewModel() {
        return new DeleteMapViewModel(context);
    }

    @Override
    protected void bindViewModel(FragmentDeleteMapBinding binding, DeleteMapViewModel viewModel) {
        binding.setDeleteMapViewModel(viewModel);
    }
}
