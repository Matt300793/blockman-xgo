package com.sandboxol.blockymods.view.dialog;

import android.content.Context;
import android.databinding.DataBindingUtil;
import android.databinding.ObservableField;
import android.graphics.drawable.AnimationDrawable;
import android.support.annotation.NonNull;
import android.util.Log;
import android.view.LayoutInflater;

import com.sandboxol.blocky.entity.EnterRealmsResult;
import com.sandboxol.blocky.entity.Game;
import com.sandboxol.blocky.router.StartMc;
import com.sandboxol.blockymods.R;
import com.sandboxol.blockymods.config.IntConstant;
import com.sandboxol.blockymods.config.MessageToken;
import com.sandboxol.blockymods.databinding.DialogAppEnterGameBinding;
import com.sandboxol.blockymods.entity.AccountCenter;
import com.sandboxol.blockymods.entity.Dispatch;
import com.sandboxol.blockymods.entity.VisitorCenter;
import com.sandboxol.blockymods.utils.EventLogicUtils;
import com.sandboxol.common.dialog.FullScreenDialog;
import com.sandboxol.common.messenger.Messenger;
import com.sandboxol.common.utils.HttpUtils;
import com.sandboxol.blockymods.web.GameApi;
import com.sandboxol.common.base.rx.BaseRxAppCompatActivity;
import com.sandboxol.common.base.viewmodel.ViewModel;
import com.sandboxol.common.base.web.OnResponseListener;
import com.sandboxol.common.command.ReplyCommand;
import com.sandboxol.common.utils.ToastUtils;
import com.trello.rxlifecycle.ActivityEvent;

import java.util.Timer;
import java.util.TimerTask;

/**
 * Created by Bob on 2017/11/16.
 */
public class EnterMiniGameDialog extends FullScreenDialog {

    private Context context;
    private String gameId;
    private Game game;
    private AnimationDrawable loadingAnim;
    private EnterMiniGameViewModel viewModel;

    public EnterMiniGameDialog(@NonNull Context context, String gameId, Game game) {
        super(context);
        this.context = context;
        this.gameId = gameId;
        this.game = game;
    }

    @Override
    protected void init(Context context) {
        super.init(context);
        DialogAppEnterGameBinding binding = DataBindingUtil.inflate(LayoutInflater.from(context), R.layout.dialog_app_enter_game, null, false);
        setContentView(binding.getRoot());
        viewModel = new EnterMiniGameViewModel();
        binding.setEnterMiniGameViewModel(viewModel);
        loadingAnim = (AnimationDrawable) binding.ivLoading.getBackground();
    }

    public void loadDispatch() {
        viewModel.loadDispatch();
    }

    public class EnterMiniGameViewModel extends ViewModel {

        public ObservableField<String> timerHint = new ObservableField<>();
        public ObservableField<Boolean> isLoading = new ObservableField<>(true);
        public ReplyCommand onCancelCommand = new ReplyCommand(this::cancel);
        private long ticks = 0;
        private Timer timer;

        private void cancel() {
            if (context instanceof BaseRxAppCompatActivity)
                ((BaseRxAppCompatActivity) context).sendLifecycleEvent(ActivityEvent.DESTROY);
            dismiss();
        }

        private void loadDispatch() {
            getMiniGameDispatch(context);
            if (!loadingAnim.isRunning())
                loadingAnim.start();
        }

        /**
         * dispatcher
         */
        private void getMiniGameDispatch(Context context) {

            if (context instanceof BaseRxAppCompatActivity)
                ((BaseRxAppCompatActivity) context).sendLifecycleEvent(ActivityEvent.RESUME);

            new EnterMiniGameModel().getMiniGameDispatch(context, gameId, new OnResponseListener<Dispatch>() {
                @Override
                public void onSuccess(Dispatch data) {
                    dismiss();
                    onComplete(data);
                }

                @Override
                public void onError(int code, String msg) {
                    dismissAndStopAnim();
                    if (code == 2 && timer == null)
                        startTimer();
                    else if (code != 2)
                        ToastUtils.showShortToast(context, HttpUtils.getHttpErrorMsg(context, code));
                }

                @Override
                public void onServerError(int error) {
                    dismissAndStopAnim();
                    ToastUtils.showShortToast(context, HttpUtils.getHttpErrorMsg(context, error));
                }
            });
        }

        private void onComplete(Dispatch dispatch) {
            stopTimer();
            long userId;
            String nickName;
            if (AccountCenter.newInstance().login.get()) {
                userId = AccountCenter.newInstance().userId.get();
                nickName = AccountCenter.newInstance().nickName.get();
            } else {
                userId = VisitorCenter.newInstance().userId.get();
                nickName = VisitorCenter.newInstance().nickName.get();
            }
            EnterRealmsResult realmsResult = new EnterRealmsResult();
            realmsResult.setGameAddr(dispatch.gAddr);
            realmsResult.setUserName(nickName);
            realmsResult.setUserId(userId);
            realmsResult.setUserToken(dispatch.signature);
            realmsResult.setGame(game);
            realmsResult.setTimestamp(dispatch.timestamp);
            realmsResult.setGameMode(game.getGameMode());
            realmsResult.setChatRoomId(dispatch.chatRoomId);
            realmsResult.setMapName(dispatch.mapName);
            realmsResult.setMapUrl(dispatch.mapUrl);
            StartMc.newInstance().startGame(context,realmsResult);
            Messenger.getDefault().send(IntConstant.RECOMMEND_REFRESH_LATELY_TYPE, MessageToken.TOKEN_REFRESH_LATELY_TYPE);
            //统计
            EventLogicUtils.enterGameLogic(context, gameId);
        }

        private void stopTimer() {
            if (timer != null) {
                timer.cancel();
                timer = null;
            }
        }

        /**
         * 开始计时器
         */
        private void startTimer() {
            timer = new Timer();
            timer.schedule(new TimerTask() {
                @Override
                public void run() {
                    timerHint.set(context.getString(R.string.dialog_enter_game_timer, formatTick()));
                    ticks++;
                }
            }, 0, 1000);
        }

        private String formatTick() {
            long min = ticks / 60;
            long sec = ticks % 60;
            return String.format("%s:%s", formatTen(min), formatTen(sec));
        }

        private String formatTen(long num) {
            if (num < 10)
                return "0" + String.valueOf(num);
            else
                return String.valueOf(num);
        }

        /**
         * 停止动画并隐藏loading anim
         */
        private void dismissAndStopAnim() {
            if (loadingAnim.isRunning())
                loadingAnim.stop();
            isLoading.set(false);
        }
    }

    private class EnterMiniGameModel {

        void getMiniGameDispatch(Context context, String typeId, OnResponseListener<Dispatch> listener) {
            GameApi.getMiniGameDispatch(context, typeId, listener);
        }
    }

}
