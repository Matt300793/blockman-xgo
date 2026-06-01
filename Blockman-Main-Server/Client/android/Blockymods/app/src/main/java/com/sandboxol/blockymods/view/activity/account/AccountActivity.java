package com.sandboxol.blockymods.view.activity.account;

import com.sandboxol.blockymods.R;
import com.sandboxol.blockymods.config.EventConstant;
import com.sandboxol.blockymods.config.StringConstant;
import com.sandboxol.blockymods.databinding.ActivityAccountBinding;
import com.sandboxol.common.base.app.BaseActivity;
import com.tendcloud.tenddata.TCAgent;

/**
 * Created by Bob on 2017/10/17.
 */
public class AccountActivity extends BaseActivity<AccountViewModel, ActivityAccountBinding> {

    @Override
    protected int getLayoutId() {
        return R.layout.activity_account;
    }

    @Override
    protected AccountViewModel getViewModel() {
        return new AccountViewModel(this, getIntent().getStringExtra(StringConstant.MORE_LOGIN_TYPE));
    }

    @Override
    protected void bindViewModel(ActivityAccountBinding binding, AccountViewModel viewModel) {
        binding.setAccountViewModel(viewModel);
    }

    @Override
    protected void onResume() {
        super.onResume();
        TCAgent.onEvent(this, EventConstant.ENTER_LOGINPAGE);
    }
}
