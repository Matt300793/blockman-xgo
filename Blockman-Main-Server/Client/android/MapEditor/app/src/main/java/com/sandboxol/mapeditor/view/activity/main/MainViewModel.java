package com.sandboxol.mapeditor.view.activity.main;

import com.sandboxol.common.base.viewmodel.ViewModel;
import com.sandboxol.common.command.ReplyCommand;
import com.sandboxol.common.utils.TemplateUtils;
import com.sandboxol.mapeditor.R;
import com.sandboxol.mapeditor.view.fragment.createmap.CreateMapFragment;
import com.sandboxol.mapeditor.view.fragment.mymap.MyMapFragment;

/**
 * Created by Jimmy on 2017/11/28 0028.
 */
public class MainViewModel extends ViewModel {

    private MainActivity activity;

    public ReplyCommand onStartEditorClick = new ReplyCommand(this::onStartEditorClick);
    public ReplyCommand onMyMapClick = new ReplyCommand(this::onMyMapClick);

    public MainViewModel(MainActivity activity) {
        this.activity = activity;
        checkAppVersion();
    }

    private void onStartEditorClick() {
        TemplateUtils.startTemplate(activity, CreateMapFragment.class, activity.getResources().getString(R.string.main_new_map));
    }

    private void onMyMapClick() {
        TemplateUtils.startTemplate(activity, MyMapFragment.class, activity.getResources().getString(R.string.main_my_map), R.mipmap.ic_more);
    }

    /**
     * 检测更新
     */
    private void checkAppVersion() {
        new MainModel().checkAppVersion(activity, false);
    }

}
