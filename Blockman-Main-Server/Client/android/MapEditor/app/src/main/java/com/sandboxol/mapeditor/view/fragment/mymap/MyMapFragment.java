package com.sandboxol.mapeditor.view.fragment.mymap;

import android.content.Intent;
import android.view.View;

import com.sandboxol.common.base.app.TemplateFragment;
import com.sandboxol.mapeditor.R;
import com.sandboxol.mapeditor.databinding.FragmentMyMapBinding;

/**
 * Created by Jimmy on 2017/11/29 0029.
 */
public class MyMapFragment extends TemplateFragment<MyMapViewModel, FragmentMyMapBinding> {

    @Override
    protected int getLayoutId() {
        return R.layout.fragment_my_map;
    }

    @Override
    protected MyMapViewModel getViewModel() {
        return new MyMapViewModel(context);
    }

    @Override
    protected void bindViewModel(FragmentMyMapBinding binding, MyMapViewModel viewModel) {
        binding.setMyMapViewModel(viewModel);
    }

    @Override
    public void onRightButtonClick(View v) {
        viewModel.onMoreClick(v);
    }

    @Override
    public void onActivityResult(int requestCode, int resultCode, Intent data) {
        super.onActivityResult(requestCode, resultCode, data);
        viewModel.onActivityResult(requestCode, resultCode, data);
    }
}
