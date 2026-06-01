package com.sandboxol.blockymods.view.fragment.recommend;

import android.content.Context;
import android.os.Bundle;

import com.sandboxol.blocky.entity.Game;
import com.sandboxol.blockymods.R;
import com.sandboxol.blockymods.config.StringConstant;
import com.sandboxol.blockymods.view.fragment.minigamedetail.MiniGameDetailFragment;
import com.sandboxol.common.base.viewmodel.ListItemViewModel;
import com.sandboxol.common.command.ReplyCommand;
import com.sandboxol.common.utils.TemplateUtils;
import com.tendcloud.tenddata.TCAgent;

/**
 * Created by Bob on 2017/10/31.
 */
public class ReGameItemViewModel extends ListItemViewModel<Game> {

    private String type;

    public ReplyCommand onClickGameCommand = new ReplyCommand(() -> {
        Bundle bundle = new Bundle();
        bundle.putString(StringConstant.MINI_GAME_ID, getItem().getGameId());
        TemplateUtils.startTemplate(context, MiniGameDetailFragment.class, getItem().getGameTitle(), bundle);
        TCAgent.onEvent(context, type, getItem().getGameId());
    });

    /**
     * @param type 用于统计
     */
    public ReGameItemViewModel(Context context, Game item, String type) {
        super(context, item);
        this.type = type;
    }

    @Override
    public Game getItem() {
        return super.getItem();
    }
}
