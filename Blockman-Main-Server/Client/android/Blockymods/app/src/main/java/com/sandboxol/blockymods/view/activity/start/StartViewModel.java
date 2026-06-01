package com.sandboxol.blockymods.view.activity.start;

import android.databinding.ObservableField;

import com.sandboxol.blockmango.EchoesHandler;
import com.sandboxol.blockymods.R;
import com.sandboxol.blockymods.utils.IntentUtils;
import com.sandboxol.common.base.viewmodel.ViewModel;
import com.sandboxol.util.GameResCopy;
import com.trello.rxlifecycle.ActivityEvent;
import com.trello.rxlifecycle.ActivityLifecycleProvider;

import java.util.concurrent.TimeUnit;

import rx.Observable;

/**
 * Created by Bob on 2017/10/16.
 */
public class StartViewModel extends ViewModel implements GameResCopy.CopyListener{

    private StartActivity activity;

    public ObservableField<String> progress = new ObservableField<>();

    public StartViewModel(StartActivity activity) {
        this.activity = activity;
        new GameResCopy(activity, this);
    }

    private void jumpMainActivity(StartActivity activity) {
        Observable.just(true)
                .delay(2, TimeUnit.SECONDS)
                .doOnNext(b -> activity.finish())
                .compose(((ActivityLifecycleProvider) activity).bindUntilEvent(ActivityEvent.DESTROY))
                .subscribe(b -> IntentUtils.startMainActivity(activity));
    }

    @Override
    public void copyDone() {
        jumpMainActivity(activity);
    }

    @Override
    public void copyFailed() {
        jumpMainActivity(activity);
    }

    @Override
    public void copyProgress(int copyFileCount, int totalFileCount) {
        float fPercent = copyFileCount * 100.0f / totalFileCount;
        String strText = String.format("%s:%.2f%%", activity.getResources().getString(R.string.prepare_text), fPercent);
        progress.set(strText);
    }
}
