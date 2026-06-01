package com.sandboxol.common.binding.adapter;

import android.databinding.BindingAdapter;
import android.widget.RadioButton;
import android.widget.RadioGroup;

import com.sandboxol.common.command.ReplyCommand;

/**
 * Created by Jimmy on 2017/10/13 0013.
 */
public class RadioGroupBindingAdapters {

    @BindingAdapter(value = {"onCheckCommand", "checkId"}, requireAll = false)
    public static void onCheckedChangeListener(RadioGroup radioGroup, ReplyCommand<CheckedDataWrapper> onCheckCommand, int checkId) {
        radioGroup.setOnCheckedChangeListener((group, checkedId) -> {
            if (onCheckCommand != null) {
                onCheckCommand.execute(new CheckedDataWrapper(group.findViewById(checkedId), checkedId));
            }
        });
        if (checkId != 0) {
            radioGroup.check(checkId);
        }
    }

    public static class CheckedDataWrapper {

        private RadioButton checkButton;
        private int checkedId;

        public CheckedDataWrapper(RadioButton checkButton, int checkedId) {
            this.checkButton = checkButton;
            this.checkedId = checkedId;
        }

        public int getCheckedId() {
            return checkedId;
        }

        public RadioButton getCheckButton() {
            return checkButton;
        }
    }

}
