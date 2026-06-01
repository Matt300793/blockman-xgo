package com.sandboxol.common.widget.rv.datarv;

import android.content.Context;
import android.databinding.ViewDataBinding;
import android.support.annotation.AttrRes;
import android.support.annotation.NonNull;
import android.support.annotation.Nullable;
import android.support.v7.widget.RecyclerView;
import android.util.AttributeSet;
import android.widget.FrameLayout;

import com.sandboxol.common.BR;
import com.sandboxol.common.R;
import com.sandboxol.common.widget.rv.IListLayout;

import me.tatarka.bindingcollectionadapter.LayoutManagers;

/**
 * Created by Jimmy on 2017/9/27 0027.
 */
public class DataRecyclerView extends FrameLayout {

    private Context context;
    private ViewDataBinding binding;
    private DataListViewModel viewModel;

    public DataRecyclerView(@NonNull Context context) {
        this(context, null);
    }

    public DataRecyclerView(@NonNull Context context, @Nullable AttributeSet attrs) {
        this(context, attrs, 0);
    }

    public DataRecyclerView(@NonNull Context context, @Nullable AttributeSet attrs, @AttrRes int defStyleAttr) {
        super(context, attrs, defStyleAttr);
        this.context = context;
    }

    public void setListLayout(IListLayout listLayout) {
        binding = listLayout.bind(context, this, true);
    }

    public void setModel(DataListModel model) {
        if (viewModel == null) {
            viewModel = new DataListViewModel(context, model);
            binding.setVariable(BR.ViewModel, viewModel);
        }
    }

    public void setLayoutFactory(LayoutManagers.LayoutManagerFactory layoutFactory) {
        RecyclerView rvData = binding.getRoot().findViewById(R.id.rvData);
        if (rvData != null) {
            rvData.setLayoutManager(layoutFactory.create(rvData));
        }
    }

    @Override
    protected void onDetachedFromWindow() {
        super.onDetachedFromWindow();
        if (viewModel != null) {
            viewModel.onDestroy();
            viewModel = null;
        }
    }
}
