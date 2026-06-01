package com.sandboxol.common.base.app;

import android.content.pm.ActivityInfo;
import android.databinding.DataBindingUtil;
import android.databinding.ViewDataBinding;
import android.os.Bundle;
import android.support.annotation.LayoutRes;
import android.support.annotation.Nullable;

import com.sandboxol.common.base.rx.BaseRxAppCompatActivity;
import com.sandboxol.common.base.viewmodel.ViewModel;

/**
 * Created by Jimmy on 2017/9/28 0028.
 */
public abstract class BaseActivity<VM extends ViewModel, D extends ViewDataBinding> extends BaseRxAppCompatActivity {

    protected VM viewModel;
    protected D binding;

    @Override
    protected void onCreate(@Nullable Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        bindView();
        initData();
        setRequestedOrientation(ActivityInfo.SCREEN_ORIENTATION_PORTRAIT);
    }

    @Override
    protected void onResume() {
        super.onResume();
        bindData();
        if (viewModel != null) {
            viewModel.onResume();
        }
    }

    @Override
    protected void onPause() {
        super.onPause();
        if (viewModel != null) {
            viewModel.onPause();
        }
    }

    private void bindView() {
        binding = DataBindingUtil.setContentView(this, getLayoutId());
        viewModel = getViewModel();
        bindViewModel(binding, viewModel);
    }

    protected abstract
    @LayoutRes
    int getLayoutId();

    protected abstract VM getViewModel();

    protected abstract void bindViewModel(D binding, VM viewModel);

    /**
     * 请求动态数据
     */
    protected void initData() {

    }

    /**
     * 绑定静态数据
     */
    protected void bindData() {

    }

    @Override
    protected void onDestroy() {
        super.onDestroy();
        if (viewModel != null) {
            viewModel.onDestroy();
            viewModel = null;
        }
    }
}
