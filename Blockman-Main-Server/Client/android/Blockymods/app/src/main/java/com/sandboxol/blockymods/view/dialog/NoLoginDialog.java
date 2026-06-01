package com.sandboxol.blockymods.view.dialog;

import android.content.Context;
import android.content.Intent;
import android.databinding.DataBindingUtil;
import android.databinding.ObservableField;
import android.net.Uri;
import android.support.annotation.NonNull;
import android.view.LayoutInflater;
import android.view.View;
import android.widget.Button;
import android.widget.TextView;

import com.sandboxol.blockymods.R;
import com.sandboxol.blockymods.config.EventConstant;
import com.sandboxol.blockymods.config.SharedConstant;
import com.sandboxol.blockymods.config.UrlConstant;
import com.sandboxol.blockymods.databinding.DialogAppCheckAppVersionBinding;
import com.sandboxol.blockymods.entity.LatestVersion;
import com.sandboxol.blockymods.view.activity.account.AccountActivity;
import com.sandboxol.common.base.viewmodel.ViewModel;
import com.sandboxol.common.command.ReplyCommand;
import com.sandboxol.common.dialog.FullScreenDialog;
import com.sandboxol.common.utils.SharedUtils;
import com.tendcloud.tenddata.TCAgent;

/**
 * Created by Bob on 2017/11/21
 */
public class NoLoginDialog extends FullScreenDialog implements View.OnClickListener {

    private Context context;
    private int resourceId;

    public NoLoginDialog(@NonNull Context context, int resourceId) {
        super(context);
        this.context = context;
        this.resourceId = resourceId;
        initView();
    }

    private void initView() {
        super.init(context);
        setContentView(R.layout.dialog_app_no_login);
        TextView tvDetails = findViewById(R.id.tvDetails);

        tvDetails.setText(context.getString(resourceId));
        findViewById(R.id.btnCancel).setOnClickListener(this);
        findViewById(R.id.btnSure).setOnClickListener(this);
    }


    @Override
    public void onClick(View v) {
        switch (v.getId()) {
            case  R.id.btnCancel:
                dismiss();
                break;
            case  R.id.btnSure:
                dismiss();
                context.startActivity(new Intent(context, AccountActivity.class));
                break;
        }
    }
}
