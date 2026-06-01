package com.sandboxol.blockymods.view.fragment.recommend;

import android.content.Context;
import android.databinding.DataBindingUtil;
import android.databinding.ViewDataBinding;
import android.view.LayoutInflater;
import android.view.ViewGroup;

import com.sandboxol.blockymods.R;
import com.sandboxol.common.widget.rv.IListLayout;

/**
 * Created by Jimmy on 2017/10/31 0031.
 */
public class GameListLayout implements IListLayout {

    @Override
    public ViewDataBinding bind(Context context, ViewGroup parent, boolean attachToParent) {
        return DataBindingUtil.inflate(LayoutInflater.from(context), R.layout.recommend_game_list_view, parent, attachToParent);
    }
}
