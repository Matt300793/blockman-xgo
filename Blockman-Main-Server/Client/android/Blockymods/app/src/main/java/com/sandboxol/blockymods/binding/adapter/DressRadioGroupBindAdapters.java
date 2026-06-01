package com.sandboxol.blockymods.binding.adapter;

import android.databinding.BindingAdapter;

import com.sandboxol.blockymods.view.widget.DressRadioGroup;
import com.sandboxol.common.command.ReplyCommand;

/**
 * Created by Bob on 2017/10/26.
 */
public class DressRadioGroupBindAdapters {

    @BindingAdapter(value = {"onTabChangeCommand"}, requireAll = false)
    public static void onTabChangeListener(DressRadioGroup dressRadioGroup, ReplyCommand<DressRadioGroup.Tab> onTabChangeCommand) {
        dressRadioGroup.setTabChangeListener(tab -> {
            if (onTabChangeCommand != null)
                onTabChangeCommand.execute(tab);
        });
    }

    @BindingAdapter("selectTab")
    public static void selectTab(DressRadioGroup dressRadioGroup, DressRadioGroup.Tab tab) {
        dressRadioGroup.selectTab(tab);
    }

}
