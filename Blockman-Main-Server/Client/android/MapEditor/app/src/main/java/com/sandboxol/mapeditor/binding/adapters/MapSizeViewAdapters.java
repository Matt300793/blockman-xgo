package com.sandboxol.mapeditor.binding.adapters;

import android.databinding.BindingAdapter;

import com.sandboxol.common.command.ReplyCommand;
import com.sandboxol.mapeditor.view.widget.MapSizeView;

/**
 * Created by Jimmy on 2017/11/29 0029.
 */
public class MapSizeViewAdapters {

    @BindingAdapter(value = {"onSizeChangeCommand"}, requireAll = false)
    public static void setMapSizeView(MapSizeView mapSizeView, ReplyCommand<Integer> onSizeChangeCommand) {
        mapSizeView.setOnSizeChangeListener(size -> {
            if (onSizeChangeCommand != null) {
                onSizeChangeCommand.execute(size.getSize());
            }
        });
    }

}
