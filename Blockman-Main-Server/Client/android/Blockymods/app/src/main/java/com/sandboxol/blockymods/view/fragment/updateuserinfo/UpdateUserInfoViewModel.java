package com.sandboxol.blockymods.view.fragment.updateuserinfo;

import android.app.Activity;
import android.content.Context;
import android.databinding.ObservableField;
import android.support.v4.content.ContextCompat;
import android.text.TextUtils;

import com.sandboxol.blockymods.R;
import com.sandboxol.blockymods.config.EventConstant;
import com.sandboxol.blockymods.config.IntConstant;
import com.sandboxol.blockymods.config.MessageToken;
import com.sandboxol.blockymods.entity.AccountCenter;
import com.sandboxol.blockymods.entity.User;
import com.sandboxol.common.messenger.Messenger;
import com.sandboxol.common.utils.HttpUtils;
import com.sandboxol.blockymods.view.fragment.changedetail.ChangeDetailFragment;
import com.sandboxol.blockymods.view.fragment.registerdetail.RegisterDetailModel;
import com.sandboxol.common.base.viewmodel.ViewModel;
import com.sandboxol.common.base.web.OnResponseListener;
import com.sandboxol.common.command.ReplyCommand;
import com.sandboxol.common.utils.TemplateUtils;
import com.sandboxol.common.utils.ToastUtils;
import com.tendcloud.tenddata.TCAgent;

import java.util.ArrayList;
import java.util.Calendar;
import java.util.List;

import cn.qqtheme.framework.picker.DatePicker;
import cn.qqtheme.framework.picker.OptionPicker;
import cn.qqtheme.framework.picker.WheelPicker;

/**
 * Created by Bob on 2017/10/17.
 */
public class UpdateUserInfoViewModel extends ViewModel {

    private Context context;
    private UpdateUserInfoFragment fragment;

    private User user;
    private List<String> list;

    public ObservableField<String> sex = new ObservableField<>("");
    public ReplyCommand onNickNameClickCommand = new ReplyCommand(this::onClickNickName);
    public ReplyCommand onDetailClickCommand = new ReplyCommand(this::onClickDetail);
    public ReplyCommand onBirthdayClickCommand = new ReplyCommand(this::onClickBirthday);
    public ReplyCommand onSexClickCommand = new ReplyCommand(this::onClickSex);
    public ReplyCommand onIconClickCommand = new ReplyCommand(() -> fragment.uploadIconClick());

    public UpdateUserInfoViewModel(Context context, UpdateUserInfoFragment fragment) {
        this.context = context;
        this.fragment = fragment;
        user = new User();
        sex.set(context.getString(AccountCenter.newInstance().sex.get() == 1 ? R.string.account_male : R.string.account_female));
    }

    private void onClickNickName() {
//        DialogUtils.showTitleAndYesOrNoDialog(context, null, view -> );
//        TemplateUtils.startTemplate(context, ChangeNameFragment.class, context.getString(R.string.item_view_change_nick_name), context.getString(R.string.finish));
        ToastUtils.showShortToast(context, R.string.change_name_no_support);
    }

    private void onClickDetail() {
        TemplateUtils.startTemplate(context, ChangeDetailFragment.class, context.getString(R.string.item_view_details), context.getString(R.string.finish));
    }

    private void onClickSex() {
//        list = new ArrayList<>();
//        list.add(context.getString(R.string.account_male));
//        list.add(context.getString(R.string.account_female));
//        OptionPicker picker = new OptionPicker((Activity) context, list); //list为选择器中的选项
//        pickerManage(picker);
//        picker.setSelectedIndex(0); //默认选中项
//        picker.setOnOptionPickListener(new OptionPicker.OnOptionPickListener() {
//            @Override
//            public void onOptionPicked(int position, String option) {
//                sex.set(list.get(position)); //在文本框中显示选择的选项
//                user.setSex(position + 1);
//                changeInfo(1);
//                AccountCenter.newInstance().sex.set(position+1);
//                    Messenger.getDefault().sendNoMsg(MessageToken.TOKEN_CHANGE_SEX);
//
//                TCAgent.onEvent(context, EventConstant.MORE_GENDER_SUC);
//            }
//        });
//        picker.show();
        ToastUtils.showShortToast(context, R.string.change_sex_no_support);
    }

    private void onClickBirthday() {
        DatePicker picker = new DatePicker((Activity) context);
        Calendar c = Calendar.getInstance();
        picker.setRangeStart(1980, 1, 1);
        picker.setRangeEnd(c.get(Calendar.YEAR), c.get(Calendar.MONTH) + 1, c.get(Calendar.DAY_OF_MONTH));
        picker.setLabel(context.getString(R.string.account_year), context.getString(R.string.account_month), context.getString(R.string.account_day));
        if (TextUtils.isEmpty(AccountCenter.newInstance().birthday.get())) {
            picker.setSelectedItem(c.get(Calendar.YEAR), c.get(Calendar.MONTH) + 1, c.get(Calendar.DAY_OF_MONTH));
        } else {
            String birth = AccountCenter.newInstance().birthday.get();
            String[] date = birth.split("-");
            if (date.length == 3) {
                picker.setSelectedItem(Integer.valueOf(date[0]), Integer.valueOf(date[1]), Integer.valueOf(date[2]));
            } else {
                picker.setSelectedItem(c.get(Calendar.YEAR), c.get(Calendar.MONTH) + 1, c.get(Calendar.DAY_OF_MONTH));
            }
        }
        pickerManage(picker);
        picker.setOnDatePickListener((DatePicker.OnYearMonthDayPickListener) (year, month, day) -> {
            String date = year + "-" + month + "-" + day;
            AccountCenter.newInstance().setBirthday(date); //在文本框中显示选择的选项
            user.setBirthday(date);
            changeInfo();
            TCAgent.onEvent(context, EventConstant.MORE_BIR_SUC);
        });
        picker.show();
    }

    void updateUserIcon() {
        if (fragment.tmpKey == null)
            return;

        new RegisterDetailModel().uploadIcon(context, fragment.getTmpDir(), fragment.getTmpKey(), new OnResponseListener<String>() {
            @Override
            public void onSuccess(String data) {
                user.setPicUrl(data);
                changeInfo();
                TCAgent.onEvent(context, EventConstant.MORE_HEAD_SUC);
            }

            @Override
            public void onError(int code, String msg) {
                ToastUtils.showShortToast(context, context.getString(R.string.connect_error_code, code));
            }

            @Override
            public void onServerError(int error) {
                ToastUtils.showShortToast(context, HttpUtils.getHttpErrorMsg(context, error));
            }
        });
    }

    private void changeInfo() {
        new UpdateUserInfoModel(user).loadData(context, new OnResponseListener<User>() {
            @Override
            public void onSuccess(User data) {
                AccountCenter.newInstance().sex.set(data.getSex());
                AccountCenter.newInstance().birthday.set(data.getBirthday());
                AccountCenter.newInstance().picUrl.set(data.getPicUrl());
                AccountCenter.putAccountInfo();
                ToastUtils.showShortToast(context, context.getString(R.string.modify_success));
//                    Messenger.getDefault().sendNoMsg(MessageToken.TOKEN_CHANGE_SEX);
            }

            @Override
            public void onError(int code, String msg) {
                ToastUtils.showShortToast(context, context.getString(R.string.connect_error_code, code));
            }

            @Override
            public void onServerError(int error) {
                ToastUtils.showShortToast(context, HttpUtils.getHttpErrorMsg(context, error));
            }
        });
    }

    /**
     * 设置picker默认属性
     *
     * @param picker
     */
    private void pickerManage(WheelPicker picker) {
        picker.setOffset(2);
        picker.setTextSize(20);
        picker.setLineSpaceMultiplier(3f);
        picker.setCancelTextColor(context.getResources().getColor(R.color.colorPrimary));
        picker.setSubmitTextColor(context.getResources().getColor(R.color.colorPrimary));
        picker.setTextColor(ContextCompat.getColor(context, R.color.colorPrimary));
        picker.setDividerVisible(false);
        picker.setCycleDisable(true); //选项不循环滚动
    }
}
