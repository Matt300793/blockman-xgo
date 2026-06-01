package com.sandboxol.blockymods.binding.adapter;

import android.databinding.BindingAdapter;

import com.sandboxol.blockymods.view.widget.ItemView;

/**
 * Created by Bob on 2017/10/26.
 */

public class ItemViewBindAdapters {

    @BindingAdapter("rightText")
    public static void setText(ItemView itemView, String text) {
        itemView.setText(text);
    }

}
