package com.sandboxol.blockymods.view.fragment.registerdetail;

import android.content.Intent;
import android.net.Uri;
import android.os.Build;
import android.view.animation.Animation;

import com.sandboxol.blockymods.R;
import com.sandboxol.blockymods.anim.AccountPageAnimation;
import com.sandboxol.blockymods.config.IntConstant;
import com.sandboxol.blockymods.databinding.FragmentRegisterDetailBinding;
import com.sandboxol.blockymods.utils.IconCrop;
import com.sandboxol.common.base.app.TemplateFragment;

import java.io.File;

/**
 * Created by Bob on 2017/10/17.
 */
public class RegisterDetailFragment extends TemplateFragment<RegisterDetailViewModel, FragmentRegisterDetailBinding> {

    public String tmpKey;//图片名称
    public File tmpDir;//文件名称

    @Override
    protected int getLayoutId() {
        return R.layout.fragment_register_detail;
    }

    @Override
    protected RegisterDetailViewModel getViewModel() {
        return new RegisterDetailViewModel(context, this);
    }

    @Override
    protected void bindViewModel(FragmentRegisterDetailBinding binding, RegisterDetailViewModel viewModel) {
        binding.setRegisterDetailViewModel(viewModel);
    }

    @Override
    public Animation onCreateAnimation(int transit, boolean enter, int nextAnim) {
        return new AccountPageAnimation(enter, IntConstant.CHANGE_ACCOUNT_REGISTER_DETAIL);
    }

    /**
     * 上传头像
     */
    public void uploadIconClick() {
        IconCrop.newInstance().uploadIcon(context, this);
    }

    @Override
    public void onActivityResult(int requestCode, int resultCode, Intent data) {
        super.onActivityResult(requestCode, resultCode, data);
        if (requestCode == IntConstant.UPLOAD_ICON_SELECT_ICON) {
            if (data == null) {
                return;
            }
            Uri uri = data.getData();
            if (uri == null) {
                return;
            }

            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.N) {
                IconCrop.newInstance().cutIcon(uri, this);
            } else {
                Uri fileUri = IconCrop.newInstance().getRealPathFromURI(context, uri);
                IconCrop.newInstance().cutIcon(fileUri, this);
            }
        } else if (requestCode == IntConstant.UPLOAD_ICON_CROP_ICON) {
            tmpKey = IconCrop.newInstance().cutIconResult(context, binding.ivIcon);
            tmpDir = IconCrop.newInstance().cutIconReturnFile();
        }
    }

    public String getTmpKey() {
        return tmpKey;
    }

    public File getTmpDir() {
        return tmpDir;
    }
}
