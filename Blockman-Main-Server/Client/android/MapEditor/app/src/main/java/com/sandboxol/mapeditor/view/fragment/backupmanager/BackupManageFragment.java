package com.sandboxol.mapeditor.view.fragment.backupmanager;

import com.sandboxol.common.base.app.TemplateFragment;
import com.sandboxol.mapeditor.R;
import com.sandboxol.mapeditor.databinding.FragmentBackupManagerBinding;

/**
 * Created by Jimmy on 2017/12/2 0002.
 */
public class BackupManageFragment extends TemplateFragment<BackupManageViewModel, FragmentBackupManagerBinding> {
    @Override
    protected int getLayoutId() {
        return R.layout.fragment_backup_manager;
    }

    @Override
    protected BackupManageViewModel getViewModel() {
        return new BackupManageViewModel(context);
    }

    @Override
    protected void bindViewModel(FragmentBackupManagerBinding binding, BackupManageViewModel viewModel) {
        binding.setBackupManageViewModel(viewModel);
    }
}
