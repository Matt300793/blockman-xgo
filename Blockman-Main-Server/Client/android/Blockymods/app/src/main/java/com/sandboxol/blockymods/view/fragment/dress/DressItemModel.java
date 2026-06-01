package com.sandboxol.blockymods.view.fragment.dress;

import android.content.Context;

import com.sandboxol.blockymods.entity.DressItem;
import com.sandboxol.blockymods.web.DecorationApi;
import com.sandboxol.common.base.web.OnResponseListener;

/**
 * Created by Bob on 2017/12/7
 */
public class DressItemModel {

    public void useDecoration(Context context, long decorationId, OnResponseListener<DressItem> listener) {
        DecorationApi.useDecoration(context, decorationId, listener);
    }

    public void removeDecoration(Context context, long decorationId, OnResponseListener<DressItem> listener) {
        DecorationApi.removeDecoration(context, decorationId, listener);
    }

}
