package com.sandboxol.blockymods.view.fragment.accountsafe;

import com.sandboxol.blockymods.R;
import com.sandboxol.blockymods.databinding.FragmentAccountSafeBinding;
import com.sandboxol.common.base.app.TemplateFragment;

/**
 * Created by Bob on 2017/10/23.
 */
public class AccountSafeFragment extends TemplateFragment<AccountSafeViewModel, FragmentAccountSafeBinding> {

    @Override
    protected int getLayoutId() {
        return R.layout.fragment_account_safe;
    }

    @Override
    protected AccountSafeViewModel getViewModel() {
        return new AccountSafeViewModel(context);
    }

    @Override
    protected void bindViewModel(FragmentAccountSafeBinding binding, AccountSafeViewModel viewModel) {
        binding.setAccountSafeViewModel(viewModel);
    }

}
