package com.sandboxol.common.binding.adapter;

import android.databinding.BindingAdapter;

import com.sandboxol.common.widget.rv.IListLayout;
import com.sandboxol.common.widget.rv.pagerv.PageListLayout;
import com.sandboxol.common.widget.rv.pagerv.PageListModel;
import com.sandboxol.common.widget.rv.pagerv.PageRecyclerView;

import me.tatarka.bindingcollectionadapter.LayoutManagers;

/**
 * Created by Jimmy on 2017/9/27 0027.
 */
public class PageRecyclerViewBindingAdapters {

    @BindingAdapter(value = {"listLayout", "model", "layoutFactory"}, requireAll = false)
    public static void setPageRecyclerView(PageRecyclerView pageRecyclerView, IListLayout listLayout, PageListModel model, LayoutManagers.LayoutManagerFactory layoutFactory) {
        if (listLayout == null) {
            pageRecyclerView.setListLayout(new PageListLayout());
        } else {
            pageRecyclerView.setListLayout(listLayout);
        }
        pageRecyclerView.setModel(model);
        if (layoutFactory == null) {
            pageRecyclerView.setLayoutFactory(LayoutManagers.linear());
        } else {
            pageRecyclerView.setLayoutFactory(layoutFactory);
        }
    }
}
