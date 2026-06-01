package com.sandboxol.mapeditor.view.activity.start;

import android.content.Intent;

import com.sandboxol.common.base.viewmodel.ViewModel;
import com.sandboxol.mapeditor.view.activity.main.MainActivity;
import com.trello.rxlifecycle.ActivityEvent;
import com.trello.rxlifecycle.ActivityLifecycleProvider;

import java.util.concurrent.TimeUnit;

import rx.Observable;

/**
 * Created by Bob on 2017/10/16.
 */
public class StartViewModel extends ViewModel {

    public StartViewModel(StartActivity activity) {
        jumpMainActivity(activity);
    }

    private void jumpMainActivity(StartActivity activity) {
        Observable.just(true)
                .delay(2, TimeUnit.SECONDS)
                .doOnNext(b -> activity.finish())
                .compose(((ActivityLifecycleProvider) activity).bindUntilEvent(ActivityEvent.DESTROY))
                .subscribe(b -> activity.startActivity(new Intent(activity, MainActivity.class)));
    }
}
