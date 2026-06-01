package com.sandboxol.blockymods.view.dialog;

import android.databinding.DataBindingUtil;
import android.os.Bundle;
import android.support.annotation.Nullable;
import android.support.v7.app.AppCompatActivity;
import android.view.View;

import com.sandboxol.blockymods.R;
import com.sandboxol.blockymods.databinding.DialogAppRepeatLoginBinding;
import com.sandboxol.blockymods.utils.IntentUtils;

/**
 * Created by Bob on 2017/11/21
 */
public class RepeatLoginDialog extends AppCompatActivity implements View.OnClickListener {

    @Override
    protected void onCreate(@Nullable Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        DialogAppRepeatLoginBinding binding = DataBindingUtil.setContentView(this, R.layout.dialog_app_repeat_login);
        binding.btnSure.setOnClickListener(this);
    }

    @Override
    public void onBackPressed() {

    }

    @Override
    public void onClick(View v) {
        switch (v.getId()) {
            case R.id.btnSure:
                IntentUtils.startAccountActivity(this);
                finish();
                break;
        }
    }

}
