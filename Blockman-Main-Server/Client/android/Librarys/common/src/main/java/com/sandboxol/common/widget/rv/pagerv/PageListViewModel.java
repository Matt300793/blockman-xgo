package com.sandboxol.common.widget.rv.pagerv;

import android.content.Context;

import com.sandboxol.common.R;
import com.sandboxol.common.base.viewmodel.ListViewModel;
import com.sandboxol.common.base.web.HttpResponse;
import com.sandboxol.common.base.web.OnResponseListener;
import com.sandboxol.common.command.ReplyCommand;
import com.sandboxol.common.config.HttpCode;
import com.sandboxol.common.config.PageConfig;
import com.sandboxol.common.utils.HttpUtils;

import rx.Observable;

/**
 * Created by Jimmy on 2017/9/27 0027.
 */
public class PageListViewModel<T> extends ListViewModel<T> {

    private int page = PageConfig.DEFAULT_PAGE;
    private int size = PageConfig.DEFAULT_SIZE;
    private int defaultPage = 0;
    private boolean isMore;
    public ReplyCommand<Integer> onLoadMoreCommand = new ReplyCommand<>(count -> onLoadMore());

    public PageListViewModel(Context context, PageListModel model, int defaultPage, int pageSize) {
        super(context, model);
        this.defaultPage = defaultPage;
        this.size = pageSize;
        onRefresh();
    }

    @Override
    public void onRefresh() {
        isMore = true;
        page = defaultPage;
        setRefreshing(true);
        loadData(page, true);
    }

    private void onLoadMore() {
        if (isMore) {
            page++;
            loadData(page, false);
        }
    }

    protected void loadData(int page, boolean isRefresh) {
        if (model != null) {
            showEmptyView(context.getResources().getString(R.string.loading));
            ((PageListModel) model).onLoad(page, size, new OnResponseListener<PageData<T>>() {
                @Override
                public void onSuccess(PageData<T> data) {
                    if (isRefresh)
                        clearItems();
                    Observable.just(data)
                            .filter(d -> d.getData() != null)
                            .doOnNext(d -> isMore = d.getPageNo() < d.getTotalPage() - 1)
                            .subscribe(d -> addItems(d.getData()));
                    PageListViewModel.this.onSuccess();
                }

                @Override
                public void onError(int code, String msg) {
                    PageListViewModel.this.onError(null);
                }

                @Override
                public void onServerError(int error) {
                    PageListViewModel.this.onError(HttpUtils.getHttpErrorMsg(context, error));
                }
            });
        }
    }

}
