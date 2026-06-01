package com.sandboxol.mapeditor.view.fragment.createmap;

import android.content.Intent;

import com.sandboxol.common.base.app.TemplateFragment;
import com.sandboxol.mapeditor.R;
import com.sandboxol.mapeditor.databinding.FragmentCreateMapBinding;

/**
 * Created by Jimmy on 2017/11/28 0028.
 */
public class CreateMapFragment extends TemplateFragment<CreateMapViewModel, FragmentCreateMapBinding> {

    @Override
    protected int getLayoutId() {
        return R.layout.fragment_create_map;
    }

    @Override
    protected CreateMapViewModel getViewModel() {
        return new CreateMapViewModel(context);
    }

    @Override
    protected void bindViewModel(FragmentCreateMapBinding binding, CreateMapViewModel viewModel) {
        binding.setCreateMapViewModel(viewModel);
    }

    @Override
    public void onActivityResult(int requestCode, int resultCode, Intent data) {
        super.onActivityResult(requestCode, resultCode, data);
        viewModel.onActivityResult(requestCode, resultCode, data);
    }
}
