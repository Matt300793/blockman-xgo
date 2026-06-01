package com.sandboxol.common.base.viewmodel;

import android.content.Context;

/**
 * Created by Jimmy on 2017/9/27 0027.
 */
public abstract class ListItemViewModel<T> extends ViewModel {

    protected Context context;
    protected T item;

    public ListItemViewModel(Context context, T item) {
        this.context = context;
        this.item = item;
    }

    public T getItem() {
        return item;
    }

}
