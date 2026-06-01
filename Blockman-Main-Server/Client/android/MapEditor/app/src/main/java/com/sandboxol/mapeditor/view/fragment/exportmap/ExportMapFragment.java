package com.sandboxol.mapeditor.view.fragment.exportmap;

import android.content.Intent;

import com.sandboxol.common.base.app.TemplateFragment;
import com.sandboxol.mapeditor.R;
import com.sandboxol.mapeditor.databinding.FragmentExportMapBinding;

/**
 * Created by Jimmy on 2017/12/1 0001.
 */
public class ExportMapFragment extends TemplateFragment<ExportMapViewModel, FragmentExportMapBinding> {

    @Override
    protected int getLayoutId() {
        return R.layout.fragment_export_map;
    }

    @Override
    protected ExportMapViewModel getViewModel() {
        return new ExportMapViewModel(context);
    }

    @Override
    protected void bindViewModel(FragmentExportMapBinding binding, ExportMapViewModel viewModel) {
        binding.setExportMapViewModel(viewModel);
    }

    @Override
    public void onActivityResult(int requestCode, int resultCode, Intent data) {
        super.onActivityResult(requestCode, resultCode, data);
        viewModel.onActivityResult(requestCode, resultCode, data);
    }
}
