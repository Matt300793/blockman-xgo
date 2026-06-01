package com.sandboxol.common.binding.adapter;

import android.databinding.BindingAdapter;

import com.sandboxol.common.widget.rv.IListLayout;
import com.sandboxol.common.widget.rv.datarv.DataListLayout;
import com.sandboxol.common.widget.rv.datarv.DataListModel;
import com.sandboxol.common.widget.rv.datarv.DataRecyclerView;

import me.tatarka.bindingcollectionadapter.LayoutManagers;

/**
 * Created by Jimmy on 2017/9/27 0027.
 */
public class DataRecyclerViewBindingAdapters {

    @BindingAdapter(value = {"listLayout", "model", "layoutFactory"}, requireAll = false)
    public static void setDataRecyclerView(DataRecyclerView dataRecyclerView, IListLayout listLayout, DataListModel model, LayoutManagers.LayoutManagerFactory layoutFactory) {
        if (listLayout == null) {
            dataRecyclerView.setListLayout(new DataListLayout());
        } else {
            dataRecyclerView.setListLayout(listLayout);
        }
        dataRecyclerView.setModel(model);
        if (layoutFactory == null) {
            dataRecyclerView.setLayoutFactory(LayoutManagers.linear());
        } else {
            dataRecyclerView.setLayoutFactory(layoutFactory);
        }
    }

}
