package com.sandboxol.blockymods.view.fragment.dress;

import android.content.Context;
import android.databinding.ObservableMap;

import com.sandboxol.blockymods.R;
import com.sandboxol.blockymods.config.IntConstant;
import com.sandboxol.blockymods.config.MessageToken;
import com.sandboxol.blockymods.config.StringConstant;
import com.sandboxol.blockymods.entity.AccountCenter;
import com.sandboxol.blockymods.entity.DressItem;
import com.sandboxol.blockymods.utils.AppSharedUtils;
import com.sandboxol.blockymods.view.dialog.NoLoginDialog;
import com.sandboxol.clothes.EchoesGLSurfaceView;
import com.sandboxol.common.base.viewmodel.ListItemViewModel;
import com.sandboxol.common.base.web.OnResponseListener;
import com.sandboxol.common.command.ReplyCommand;
import com.sandboxol.common.messenger.Messenger;
import com.sandboxol.common.utils.ToastUtils;

/**
 * Created by Bob on 2017/11/28
 */
public class DressItemViewModel extends ListItemViewModel<DressItem> {

    private int type;

    public ObservableMap<Long, String> ids;
    private ObservableMap<Long, String> dressUrl;

    public ReplyCommand onUseDressRecommend = new ReplyCommand(() -> {
        if (AccountCenter.newInstance().login.get()) {
            if (ids.values().contains(item.getResourceId())) {
                ids.remove(item.getTypeId());
                dressUrl.put(item.getTypeId(), "Empty");
                removeDecoration(item.getId());
            } else {
                ids.put(item.getTypeId(), item.getResourceId());
                dressUrl.put(item.getTypeId(), item.getIconUrl());
                useDecoration(item.getId());
            }
        } else {
            new NoLoginDialog(context, R.string.dress_change_no_login).show();
        }
    });

    public DressItemViewModel(Context context, DressItem item, ObservableMap<Long, String> ids, int type, ObservableMap<Long, String> dressUrl) {
        super(context, item);
        if (item.getStatus() == 1) {
            ids.put(item.getTypeId(), item.getResourceId());
            dressUrl.put(item.getTypeId(), item.getIconUrl());
        }
        this.ids = ids;
        this.type = type;
        this.dressUrl = dressUrl;
    }

    /**
     * 使用装扮
     */
    private void useDecoration(long id) {
        Messenger.getDefault().send(IntConstant.DECORATION_LOADING, MessageToken.TOKEN_DECORATION_LOADING_FINISH_TYPE);

        new DressItemModel().useDecoration(context, id, new OnResponseListener<DressItem>() {
            @Override
            public void onSuccess(DressItem data) {
                clothTypes(data.getResourceId());
                if (type != 0)
                    Messenger.getDefault().sendNoMsg(MessageToken.TOKEN_REFRESH_DECORATION_TYPE);
                Messenger.getDefault().send(IntConstant.DECORATION_FINISH, MessageToken.TOKEN_DECORATION_LOADING_FINISH_TYPE);
            }

            @Override
            public void onError(int code, String msg) {
                ToastUtils.showShortToast(context, R.string.dress_failed);
                Messenger.getDefault().send(IntConstant.DECORATION_FINISH, MessageToken.TOKEN_DECORATION_LOADING_FINISH_TYPE);
            }

            @Override
            public void onServerError(int error) {
                ToastUtils.showShortToast(context, R.string.dress_failed);
                Messenger.getDefault().send(IntConstant.DECORATION_FINISH, MessageToken.TOKEN_DECORATION_LOADING_FINISH_TYPE);
            }
        });
    }

    /**
     * 移除装扮
     */
    private void removeDecoration(long id) {
        Messenger.getDefault().send(IntConstant.DECORATION_LOADING, MessageToken.TOKEN_DECORATION_LOADING_FINISH_TYPE);

        new DressItemModel().removeDecoration(context, id, new OnResponseListener<DressItem>() {
            @Override
            public void onSuccess(DressItem data) {
                String resourceId = getDefaultResourceId();
                if (resourceId != null)
                    clothTypes(resourceId);
                else
                    clothTypes(null);
                if (type != 0)
                    Messenger.getDefault().sendNoMsg(MessageToken.TOKEN_REFRESH_DECORATION_TYPE);
                Messenger.getDefault().send(IntConstant.DECORATION_FINISH, MessageToken.TOKEN_DECORATION_LOADING_FINISH_TYPE);
            }

            @Override
            public void onError(int code, String msg) {
                ToastUtils.showShortToast(context, R.string.dress_failed);
                Messenger.getDefault().send(IntConstant.DECORATION_FINISH, MessageToken.TOKEN_DECORATION_LOADING_FINISH_TYPE);
            }

            @Override
            public void onServerError(int error) {
                ToastUtils.showShortToast(context, R.string.dress_failed);
                Messenger.getDefault().send(IntConstant.DECORATION_FINISH, MessageToken.TOKEN_DECORATION_LOADING_FINISH_TYPE);
            }
        });
    }

    /**
     * 根据不同的类型调起不同的换装接口
     */
    private void clothTypes(String resourceId) {
        try {
            if (resourceId == null) {
                String[] strings = item.getResourceId().split("\\.");
                EchoesGLSurfaceView.getInstance().changeParts(strings[0], "0");
            } else {
                String[] strings = resourceId.split("\\.");
                EchoesGLSurfaceView.getInstance().changeParts(strings[0], strings[1]);
            }
        } catch (Exception e) {

        }

    }

    private String getDefaultResourceId(){
        if (item.getResourceId().contains("tops"))
            return StringConstant.CLOTHES_TOPS_1;
        if (item.getResourceId().contains("pants"))
            return StringConstant.CLOTHES_PANTS_1;
        if (item.getResourceId().contains("shoes"))
            return StringConstant.CUSTOM_SHOES_1;
        if (item.getResourceId().contains("face"))
            return StringConstant.CUSTOM_FACE_1;
        if (item.getResourceId().contains("hair"))
            return StringConstant.CUSTOM_HAIR_1;
        return null;
    }

}
