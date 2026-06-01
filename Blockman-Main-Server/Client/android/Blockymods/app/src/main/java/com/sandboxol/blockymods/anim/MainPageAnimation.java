package com.sandboxol.blockymods.anim;

import com.sandboxol.blockymods.view.activity.main.MainViewModel;
import com.sandboxol.common.anim.HorizontalMoveAnimation;

/**
 * Created by Bob on 2017/10/13.
 */
public class MainPageAnimation extends HorizontalMoveAnimation {

    public MainPageAnimation(boolean enter, int index) {
        super(MainViewModel.nextPageIndex > MainViewModel.currPageIndex ? LEFT : RIGHT, enter, 100);
        if (enter)
            MainViewModel.currPageIndex = index;
    }



}