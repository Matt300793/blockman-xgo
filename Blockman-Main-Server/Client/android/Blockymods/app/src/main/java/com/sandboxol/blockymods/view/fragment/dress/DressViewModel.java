package com.sandboxol.blockymods.view.fragment.dress;

import android.content.Context;
import android.databinding.ObservableArrayList;
import android.databinding.ObservableArrayMap;
import android.databinding.ObservableField;
import android.databinding.ObservableList;
import android.databinding.ObservableMap;

import com.sandboxol.blockymods.BR;
import com.sandboxol.blockymods.R;
import com.sandboxol.blockymods.config.IntConstant;
import com.sandboxol.blockymods.config.MessageToken;
import com.sandboxol.blockymods.config.SharedConstant;
import com.sandboxol.blockymods.config.StringConstant;
import com.sandboxol.blockymods.entity.AccountCenter;
import com.sandboxol.blockymods.entity.DressItem;
import com.sandboxol.blockymods.utils.AppSharedUtils;
import com.sandboxol.blockymods.view.widget.DressRadioGroup;
import com.sandboxol.blockymods.web.DecorationApi;
import com.sandboxol.clothes.EchoesGLSurfaceView;
import com.sandboxol.clothes.EchoesHandler;
import com.sandboxol.clothes.EchoesRenderer;
import com.sandboxol.common.base.viewmodel.ViewModel;
import com.sandboxol.common.base.web.HttpResponse;
import com.sandboxol.common.base.web.HttpSubscriber;
import com.sandboxol.common.base.web.OnResponseListener;
import com.sandboxol.common.command.ReplyCommand;
import com.sandboxol.common.config.CommonMessageToken;
import com.sandboxol.common.config.HttpCode;
import com.sandboxol.common.messenger.Messenger;
import com.sandboxol.common.utils.SharedUtils;

import java.util.List;
import java.util.concurrent.TimeUnit;

import me.tatarka.bindingcollectionadapter.BaseItemViewSelector;
import me.tatarka.bindingcollectionadapter.ItemView;
import me.tatarka.bindingcollectionadapter.ItemViewSelector;
import rx.Observable;
import rx.android.schedulers.AndroidSchedulers;

/**
 * Created by Jimmy on 2017/10/25 0025
 */
public class DressViewModel extends ViewModel {

    public final ObservableList<DressPageViewModel> pageItems = new ObservableArrayList<>();
    public final ItemViewSelector<DressPageViewModel> pageView = new BaseItemViewSelector<DressPageViewModel>() {
        @Override
        public void select(ItemView itemView, int position, DressPageViewModel item) {
            itemView.set(BR.DressPageViewModel, R.layout.content_dress_page);
        }

        @Override
        public int viewTypeCount() {
            return 1;
        }
    };

    public EchoesGLSurfaceView mGLSurfaceView;
    public ObservableField<Boolean> isLoading = new ObservableField<>(false);//装扮过程中不可点击其他装扮
    public ObservableField<Boolean> isRenderingFinish = new ObservableField<>(false);//渲染未完成时显示默认背景图
    public ObservableField<DressRadioGroup.Tab> selectTab = new ObservableField<>();//选择的tab
    public ObservableField<Integer> selectPos = new ObservableField<>();
    public ObservableField<Integer> showDetails = new ObservableField<>();//装扮细分展示
    public ReplyCommand<Integer> onPageSelectedCommand = new ReplyCommand<>(this::onPageChange);
    public ReplyCommand<DressRadioGroup.Tab> onTabChangeCommand = new ReplyCommand<>(this::onTabChange);
    public ObservableMap<Long, String> dressUrl = new ObservableArrayMap<>();//所有已装扮的装饰URL
    private Context context;
    private ObservableMap<Long, String> ids = new ObservableArrayMap<>();//所有已装扮的装饰ResourceId
    private boolean isDressFinish = false;

    public DressViewModel(Context context) {
        this.context = context;
        initDefaultClothes(ids);
        for (int i = 0; i < 8; i++) {
            pageItems.add(new DressPageViewModel(context, i, ids, dressUrl));
        }
        onTabChange(DressRadioGroup.Tab.CURRENT);
        mGLSurfaceView = new EchoesGLSurfaceView(context);
        mGLSurfaceView.setEchoesRenderer(new EchoesRenderer());
        if (AccountCenter.newInstance().login.get())
            mGLSurfaceView.setMainHandler(new EchoesHandler(context, AccountCenter.newInstance().sex.get()));
        else
            mGLSurfaceView.setMainHandler(new EchoesHandler(context, IntConstant.SEX_BOY));
        initMessenger();
    }

    private void initMessenger() {
        Messenger.getDefault().register(this, MessageToken.TOKEN_CHANGE_SEX, () ->
                EchoesGLSurfaceView.getInstance().changeSex(AccountCenter.newInstance().sex.get())
        );
        //登录、注册、退出登录后切换装扮的性别
        Messenger.getDefault().register(this, MessageToken.TOKEN_ACCOUNT, Integer.class, type -> {
            if (type == IntConstant.ACCOUNT_LOGOUT) {
                initDefaultDetails(dressUrl);
            }
            isDressFinish = false;
        });
        //装扮使用过程中不让使用其他装扮
        Messenger.getDefault().register(this, MessageToken.TOKEN_DECORATION_LOADING_FINISH_TYPE, Integer.class, type -> {
            if (type == IntConstant.DECORATION_LOADING) {
                isLoading.set(true);
            } else if (type == IntConstant.DECORATION_FINISH) {
                isLoading.set(false);
            }
        });
        //装扮渲染完成后使用当前装扮
        Messenger.getDefault().register(this, CommonMessageToken.TOKEN_DECORATION_INIT_FINISH, () -> {
            useClothes();
            isRenderingFinish.set(true);
        });
    }

    /**
     * 重载数据
     */
    private void reload() {
        if (isDressFinish) return;
        isDressFinish = true;
        int sex;
        if (AccountCenter.newInstance().login.get()) {
            sex = AccountCenter.newInstance().sex.get();
        } else {
            sex = IntConstant.SEX_BOY;
        }
        DecorationApi.getUsingDress(context)
                .doOnNext(response -> ids.clear())
                .doOnNext(response -> initDefaultClothes(ids))
                .doOnNext(response -> {
                    if (response.getCode() == HttpCode.SUCCESS && response.getData() != null) {
                        Observable.from(response.getData())
                                .doOnNext(item -> ids.put(item.getTypeId(), item.getResourceId()))
                                .subscribe();
                    }
                })
                .delay(1, TimeUnit.SECONDS)
                .observeOn(AndroidSchedulers.mainThread())
                .doOnNext(response -> EchoesGLSurfaceView.getInstance().changeSex(sex))
                .doOnNext(response -> useClothes())
                .doOnNext(response -> pageItems.clear())
                .subscribe(new HttpSubscriber<>(new OnResponseListener<List<DressItem>>() {
                    @Override
                    public void onSuccess(List<DressItem> data) {
                        for (int i = 0; i < 8; i++) {
                            pageItems.add(new DressPageViewModel(context, i, ids, dressUrl));
                        }
                    }

                    @Override
                    public void onError(int code, String msg) {
                        for (int i = 0; i < 8; i++) {
                            pageItems.add(new DressPageViewModel(context, i, ids, dressUrl));
                        }
                    }

                    @Override
                    public void onServerError(int error) {
                        for (int i = 0; i < 8; i++) {
                            pageItems.add(new DressPageViewModel(context, i, ids, dressUrl));
                        }
                    }
                }));
    }

    /**
     * 使用当前装扮
     */
    private void useClothes() {
        Observable.from(ids.values()).subscribe(this::clothTypes);
    }

    /**
     * 原始套装初始化
     *
     * @param ids
     */
    private void initDefaultClothes(ObservableMap<Long, String> ids) {
        ids.put(IntConstant.DECORATION_TYPE_TOPS, StringConstant.CLOTHES_TOPS_1);
        ids.put(IntConstant.DECORATION_TYPE_PANTS, StringConstant.CLOTHES_PANTS_1);
        ids.put(IntConstant.DECORATION_TYPE_SHOES, StringConstant.CUSTOM_SHOES_1);
        ids.put(IntConstant.DECORATION_TYPE_EMOTION, StringConstant.CUSTOM_FACE_1);
        ids.put(IntConstant.DECORATION_TYPE_HAIR, StringConstant.CUSTOM_HAIR_1);
    }

    /**
     * 细节装饰初始化
     *
     * @param dressUrl
     */
    private void initDefaultDetails(ObservableMap<Long, String> dressUrl) {
        dressUrl.put(IntConstant.DECORATION_TYPE_TOPS, "empty");
        dressUrl.put(IntConstant.DECORATION_TYPE_PANTS, "empty");
        dressUrl.put(IntConstant.DECORATION_TYPE_SHOES, "empty");
        dressUrl.put(IntConstant.DECORATION_TYPE_HAT, "empty");
        dressUrl.put(IntConstant.DECORATION_TYPE_FACE, "empty");
        dressUrl.put(IntConstant.DECORATION_TYPE_SHOULDER, "empty");
        dressUrl.put(IntConstant.DECORATION_TYPE_BACK, "empty");
    }

    /**
     * 是否显示细节装饰
     */
    private void isShowDetails() {
        if (selectTab.get() == DressRadioGroup.Tab.CLOTH && AccountCenter.newInstance().login.get()) {
            showDetails.set(IntConstant.DRESS_TYPE_CLOTH);
        } else if (selectTab.get() == DressRadioGroup.Tab.ORNAMENTS && AccountCenter.newInstance().login.get()) {
            showDetails.set(IntConstant.DRESS_TYPE_ORNAMENTS);
        } else
            showDetails.set(IntConstant.DRESS_TYPE_NORMAL);
    }

    private void onPageChange(int position) {
        selectPos.set(position);
        selectTab.set(DressRadioGroup.Tab.getTabByPosition(position));
        isShowDetails();
    }

    private void onTabChange(DressRadioGroup.Tab tab) {
        selectTab.set(tab);
        selectPos.set(tab.position);
        isShowDetails();
    }

    /**
     * 换装接口
     */
    private void clothTypes(String resourceId) {
        try {
            String[] strings = resourceId.split("\\.");
            EchoesGLSurfaceView.getInstance().changeParts(strings[0], strings[1]);
        } catch (Exception e) {

        }
    }

    @Override
    public void onPause() {
        if (mGLSurfaceView != null)
            mGLSurfaceView.onPause();
    }

    @Override
    public void onResume() {
        if (mGLSurfaceView != null)
            mGLSurfaceView.onResume();
        if (SharedUtils.getBoolean(context, SharedConstant.FIRST_ENTER_APP))
            reload();
        else
            SharedUtils.putBoolean(context, SharedConstant.FIRST_ENTER_APP, true);
    }

    @Override
    public void onDestroy() {
        if (mGLSurfaceView != null)
            mGLSurfaceView.onDestroy();
        Messenger.getDefault().unregister(this);
    }

}
