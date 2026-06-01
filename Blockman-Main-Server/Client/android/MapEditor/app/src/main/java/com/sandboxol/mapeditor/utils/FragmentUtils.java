package com.sandboxol.mapeditor.utils;

import android.content.Context;
import android.os.Bundle;

import com.sandboxol.common.utils.TemplateUtils;
import com.sandboxol.mapeditor.R;
import com.sandboxol.mapeditor.config.StringConstant;
import com.sandboxol.mapeditor.entity.dao.McMap;
import com.sandboxol.mapeditor.view.fragment.backupmap.BackupMapFragment;

/**
 * Created by Jimmy on 2017/12/4 0004.
 */
public class FragmentUtils {

    public static void startBackupMapFragment(Context context, McMap map) {
        Bundle bundle = new Bundle();
        bundle.putLong(StringConstant.MC_MAP_ID, map.getId());
        TemplateUtils.startTemplate(context, BackupMapFragment.class, context.getResources().getString(R.string.backup_map_title, map.getName()), bundle);
    }

}
