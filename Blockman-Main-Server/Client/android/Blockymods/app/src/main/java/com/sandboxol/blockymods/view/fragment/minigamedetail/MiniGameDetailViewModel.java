package com.sandboxol.blockymods.view.fragment.minigamedetail;

import android.content.Context;
import android.databinding.ObservableField;

import com.sandboxol.blocky.entity.Game;
import com.sandboxol.blockymods.R;
import com.sandboxol.blockymods.config.EventConstant;
import com.sandboxol.blockymods.entity.AccountCenter;
import com.sandboxol.blockymods.entity.VisitorCenter;
import com.sandboxol.common.utils.HttpUtils;
import com.sandboxol.blockymods.utils.ViewModelUtils;
import com.sandboxol.blockymods.view.dialog.EnterMiniGameDialog;
import com.sandboxol.common.base.viewmodel.ViewModel;
import com.sandboxol.common.base.web.OnResponseListener;
import com.sandboxol.common.command.ReplyCommand;
import com.sandboxol.common.utils.ToastUtils;
import com.tendcloud.tenddata.TCAgent;

/**
 * Created by Bob on 2017/11/2.
 */
public class MiniGameDetailViewModel extends ViewModel {

    private Context context;
    private String gameId;
    private Game game;

    public ObservableField<String> coverPic = new ObservableField<>();
    public ObservableField<String> gameTitle = new ObservableField<>();
    public ObservableField<String> gameDetail = new ObservableField<>();
    public ObservableField<String> praiseNumber = new ObservableField<>();
    public ObservableField<String> gameType = new ObservableField<>();
    public ObservableField<Boolean> isPraise = new ObservableField<>(false);

    public ReplyCommand onClickAppreciationCommand = new ReplyCommand(this::appreciation);
    public ReplyCommand onEnterGameCommand = new ReplyCommand(this::enterGame);

    public MiniGameDetailViewModel(Context context, String gameId) {
        this.context = context;
        this.gameId = gameId;
        getGameDetail();
    }

    /**
     * 获取小游戏详情
     */
    private void getGameDetail() {
        new MiniGameDetailModel().miniGameDetail(context, gameId, new OnResponseListener<Game>() {
            @Override
            public void onSuccess(Game data) {
                game = data;
                coverPic.set(data.getGameCoverPic());
                gameTitle.set(data.getGameTitle());
                gameDetail.set(data.getGameDetail());
                praiseNumber.set(String.valueOf(data.getPraiseNumber()));
                gameType.set(ViewModelUtils.gameTypeManage(data.getGameTypes()));
                isPraise.set(data.isAppreciate());
            }

            @Override
            public void onError(int code, String msg) {
                ToastUtils.showShortToast(context, HttpUtils.getHttpErrorMsg(context, code));
            }

            @Override
            public void onServerError(int error) {
                ToastUtils.showShortToast(context, HttpUtils.getHttpErrorMsg(context, error));
            }
        });
    }

    /**
     * 点赞
     */
    private void appreciation() {
        new MiniGameDetailModel().appreciation(context, gameId, new OnResponseListener<Integer>() {
            @Override
            public void onSuccess(Integer data) {
                isPraise.set(true);
                praiseNumber.set(String.valueOf(Integer.valueOf(praiseNumber.get()) + 1));
                TCAgent.onEvent(context, EventConstant.CLICK_GOOD);
            }

            @Override
            public void onError(int code, String msg) {
                switch (code) {
                    case 7:
                        ToastUtils.showShortToast(context, R.string.game_detail_appreciation_not_login);
                        break;
                    case 2002:
                        ToastUtils.showShortToast(context, R.string.game_detail_appreciation_game_not_exist);
                        break;
                    case 2005:
                        ToastUtils.showShortToast(context, R.string.game_detail_appreciation_game_has_appreciation);
                        break;
                    case 2008:
                        ToastUtils.showShortToast(context, R.string.game_detail_appreciation_game_not_play);
                        break;
                    default:
                        ToastUtils.showShortToast(context, context.getString(R.string.connect_error_code, code));
                        break;
                }
            }

            @Override
            public void onServerError(int error) {
                ToastUtils.showShortToast(context, HttpUtils.getHttpErrorMsg(context, error));
            }
        });
    }

    /**
     * 进入游戏
     */
    private void enterGame() {
        if (AccountCenter.newInstance().userId.get() == 0 && VisitorCenter.newInstance().userId.get() == 0) {
            ToastUtils.showShortToast(context, "获取游客信息失败，请先登录");
            return;
        }
        if (game != null) {
            EnterMiniGameDialog dialog = new EnterMiniGameDialog(context, gameId, game);
            dialog.show();
            dialog.loadDispatch();
            TCAgent.onEvent(context, EventConstant.CLICK_QUICKACCESS);
        }
    }


}
