package com.sandboxol.blockymods.view.fragment.recommend;

import android.content.Context;
import android.databinding.ObservableField;

import com.sandboxol.blockymods.R;
import com.sandboxol.blockymods.config.EventConstant;
import com.sandboxol.blockymods.config.IntConstant;
import com.sandboxol.blockymods.config.MessageToken;
import com.sandboxol.common.base.viewmodel.ViewModel;
import com.sandboxol.common.command.ReplyCommand;
import com.sandboxol.common.messenger.Messenger;
import com.sandboxol.common.widget.rv.msg.RefreshMsg;
import com.tendcloud.tenddata.TCAgent;

/**
 * Created by Jimmy on 2017/10/25 0025.
 */
public class RecommendViewModel extends ViewModel {

    private Context context;

    public ObservableField<Boolean> isShowRecently = new ObservableField<>(false);
    public ObservableField<Boolean> isShowFriend = new ObservableField<>(false);

    public HotRecommendModel hotRecommendModel;
    public LatelyPlayModel latelyPlayModel;
    public FriendPlayModel friendPlayModel;
    public GameListLayout gameListLayout = new GameListLayout();

    public ReplyCommand onClickChangeCommand = new ReplyCommand(() -> {
        Messenger.getDefault().send(RefreshMsg.create(), hotRecommendModel.getRefreshToken());
        TCAgent.onEvent(context, EventConstant.HOME_CHANGE);
    });

    public RecommendViewModel(Context context) {
        this.context = context;
        hotRecommendModel = new HotRecommendModel(context, R.string.category_no_data);
        latelyPlayModel = new LatelyPlayModel(context, R.string.category_no_data);
        friendPlayModel = new FriendPlayModel(context, R.string.category_no_data);
        initMessenger();
    }

    /**
     * 显示或者隐藏“最近游玩”和“好友在玩”
     */
    private void initMessenger() {
        Messenger.getDefault().register(this, MessageToken.TOKEN_SHOW_LATELY_FRIEND_VIEW, Integer.class, type -> {
            if (type == IntConstant.RECOMMEND_SHOW_RECENTLY_VIEW)
                isShowRecently.set(true);
            else if (type == IntConstant.RECOMMEND_SHOW_FRIEND_VIEW)
                isShowFriend.set(true);
        });
        Messenger.getDefault().register(this, MessageToken.TOKEN_REFRESH_LATELY_TYPE, Integer.class, type -> {
            if (type == IntConstant.RECOMMEND_REFRESH_LATELY_TYPE)
                Messenger.getDefault().send(RefreshMsg.create(), latelyPlayModel.getRefreshToken());
        });
    }

    @Override
    public void onDestroy() {
        super.onDestroy();
        Messenger.getDefault().unregister(this);
    }
}
