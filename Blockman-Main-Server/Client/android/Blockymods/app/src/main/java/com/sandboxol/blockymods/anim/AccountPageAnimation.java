package com.sandboxol.blockymods.anim;

import com.sandboxol.blockymods.view.activity.account.AccountViewModel;
import com.sandboxol.common.anim.HorizontalMoveAnimation;

/**
 * Created by Bob on 2017/10/13.
 */
public class AccountPageAnimation extends HorizontalMoveAnimation {

    public AccountPageAnimation(boolean enter, int index) {
        super(AccountViewModel.nextPageIndex > AccountViewModel.currPageIndex ? LEFT : RIGHT, enter, 100);
        if (enter)
            AccountViewModel.currPageIndex = index;
    }

}