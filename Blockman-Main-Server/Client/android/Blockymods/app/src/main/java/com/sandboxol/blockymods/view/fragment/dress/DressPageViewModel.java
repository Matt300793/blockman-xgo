package com.sandboxol.blockymods.view.fragment.dress;

import android.content.Context;
import android.databinding.ObservableMap;

import com.sandboxol.blockymods.R;
import com.sandboxol.blockymods.config.MessageToken;
import com.sandboxol.common.base.viewmodel.ViewModel;
import com.sandboxol.common.messenger.Messenger;
import com.sandboxol.common.widget.rv.msg.RefreshMsg;

public class DressPageViewModel extends ViewModel {

    public DressPageListModel dressPageListModel;

    public DressPageViewModel(Context context, int type, ObservableMap<Long, String> ids, ObservableMap<Long, String> dressUrl) {
        dressPageListModel = new DressPageListModel(context, typeSelect(type), type, ids, dressUrl);
        initMessenger();
    }

    private void initMessenger() {
        Messenger.getDefault().register(this, MessageToken.TOKEN_REFRESH_DECORATION_TYPE, () ->
                Messenger.getDefault().send(RefreshMsg.create(), dressPageListModel.getRefreshToken())
        );
    }

    private int typeSelect(int type) {
        if (type == 0)
            return R.string.dress_me_no_dress;
        else if (type == 6 || type == 7) {
            return R.string.coming_soon;
        } else
            return R.string.dress_no_dress;
    }

    @Override
    public void onDestroy() {
        super.onDestroy();
        Messenger.getDefault().unregister(this);
    }
}
