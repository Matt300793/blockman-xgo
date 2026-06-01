package com.sandboxol.mapeditor.view.fragment.backupmap;

import com.sandboxol.common.base.app.TemplateFragment;
import com.sandboxol.mapeditor.R;
import com.sandboxol.mapeditor.config.StringConstant;
import com.sandboxol.mapeditor.databinding.FragmentBackupMapBinding;

/**
 * Created by Jimmy on 2017/12/4 0004.
 */
public class BackupMapFragment extends TemplateFragment<BackupMapViewModel, FragmentBackupMapBinding> {

    @Override
    protected int getLayoutId() {
        return R.layout.fragment_backup_map;
    }

    @Override
    protected BackupMapViewModel getViewModel() {
        long mapId = 1;
        if (getArguments() != null)
            mapId = getArguments().getLong(StringConstant.MC_MAP_ID, 1);
        return new BackupMapViewModel(context, mapId);
    }

    @Override
    protected void bindViewModel(FragmentBackupMapBinding binding, BackupMapViewModel viewModel) {
        binding.setBackupMapViewModel(viewModel);
    }
}
