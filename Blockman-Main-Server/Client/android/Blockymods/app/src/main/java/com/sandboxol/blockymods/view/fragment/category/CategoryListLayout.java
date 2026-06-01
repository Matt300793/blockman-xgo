package com.sandboxol.blockymods.view.fragment.category;

import android.content.Context;
import android.databinding.DataBindingUtil;
import android.databinding.ViewDataBinding;
import android.view.LayoutInflater;
import android.view.ViewGroup;

import com.sandboxol.blockymods.R;
import com.sandboxol.common.widget.rv.IListLayout;

/**
 * Created by Bob on 2017/11/07.
 */
public class CategoryListLayout implements IListLayout {

    @Override
    public ViewDataBinding bind(Context context, ViewGroup parent, boolean attachToParent) {
        return DataBindingUtil.inflate(LayoutInflater.from(context), R.layout.page_list_view, parent, attachToParent);
    }
}
