package com.sandboxol.blockymods.web;

import android.content.Context;

import com.sandboxol.blockymods.BuildConfig;
import com.sandboxol.blockymods.config.StringConstant;
import com.sandboxol.blockymods.config.UrlConstant;
import com.sandboxol.blockymods.entity.AccountCenter;
import com.sandboxol.blockymods.entity.AppConfig;
import com.sandboxol.blockymods.entity.ChangePasswordForm;
import com.sandboxol.blockymods.entity.EmailBindForm;
import com.sandboxol.blockymods.entity.LatestVersion;
import com.sandboxol.blockymods.entity.LoginRegisterAccountForm;
import com.sandboxol.blockymods.entity.PhoneBindForm;
import com.sandboxol.blockymods.entity.User;
import com.sandboxol.blockymods.entity.Visitor;
import com.sandboxol.blockymods.view.fragment.login.LoginSubscriber;
import com.sandboxol.common.base.web.HttpSubscriber;
import com.sandboxol.common.base.web.OnResponseListener;
import com.sandboxol.common.config.HttpCode;
import com.sandboxol.common.retrofit.RetrofitFactory;
import com.trello.rxlifecycle.ActivityEvent;
import com.trello.rxlifecycle.ActivityLifecycleProvider;

import java.io.File;

import okhttp3.MediaType;
import okhttp3.MultipartBody;
import okhttp3.RequestBody;
import rx.android.schedulers.AndroidSchedulers;
import rx.exceptions.Exceptions;
import rx.schedulers.Schedulers;

/**
 * Created by Jimmy on 2017/9/27 0027.
 */
public class UserApi {

    private static final IUserApi api = RetrofitFactory.create(BuildConfig.BASE_URL, IUserApi.class);
    private static final IUserApi updateApi = RetrofitFactory.create(UrlConstant.UPDATE_VERSION, IUserApi.class);

    public static void visitor(Context context, LoginRegisterAccountForm form, OnResponseListener<Visitor> listener) {
        api.visitor(form).compose(((ActivityLifecycleProvider) context).bindUntilEvent(ActivityEvent.DESTROY))
                .subscribeOn(Schedulers.newThread())
                .observeOn(AndroidSchedulers.mainThread())
                .doOnNext(r -> {
                    if (r.getCode() != HttpCode.SUCCESS) {
                        throw Exceptions.propagate(new Exception("failed to load visitor data."));
                    }
                })
                .retry(2)
                .subscribe(new HttpSubscriber<>(listener));
    }

    /**
     * 账号注册
     *
     * @param context
     * @param form
     * @param listener
     */
    public static void register(Context context, LoginRegisterAccountForm form, OnResponseListener<User> listener) {
        api.register(form).compose(((ActivityLifecycleProvider) context).bindUntilEvent(ActivityEvent.DESTROY))
                .subscribeOn(Schedulers.newThread())
                .observeOn(AndroidSchedulers.mainThread())
                .subscribe(new HttpSubscriber<>(listener));
    }

    /**
     * 用户信息注册
     *
     * @param context
     * @param form
     * @param listener
     */
    public static void userRegister(Context context, User form, OnResponseListener<User> listener) {
        api.userRegister(form,
                AccountCenter.newInstance().userId.get(),
                AccountCenter.newInstance().token.get())
                .compose(((ActivityLifecycleProvider) context).bindUntilEvent(ActivityEvent.DESTROY))
                .subscribeOn(Schedulers.newThread())
                .observeOn(AndroidSchedulers.mainThread())
                .subscribe(new HttpSubscriber<>(listener));
    }

    /**
     * 登录
     *
     * @param context
     * @param form
     * @param listener
     */
    public static void login(Context context, LoginRegisterAccountForm form, OnResponseListener<User> listener) {
        api.login(form).compose(((ActivityLifecycleProvider) context).bindUntilEvent(ActivityEvent.DESTROY))
                .subscribeOn(Schedulers.newThread())
                .observeOn(AndroidSchedulers.mainThread())
                .subscribe(new LoginSubscriber<>(listener));
    }

    /**
     * 修改密码
     *
     * @param context
     * @param form
     * @param listener
     */
    public static void modifyPassword(Context context, ChangePasswordForm form, OnResponseListener listener) {
        api.modifyPassword(form,
                AccountCenter.newInstance().userId.get(),
                AccountCenter.newInstance().token.get())
                .compose(((ActivityLifecycleProvider) context).bindUntilEvent(ActivityEvent.DESTROY))
                .subscribeOn(Schedulers.newThread())
                .observeOn(AndroidSchedulers.mainThread())
                .subscribe(new HttpSubscriber(listener));
    }

    /**
     * 找回密码
     *
     * @param context
     * @param form
     * @param listener
     */
    public static void retrievePassword(Context context, PhoneBindForm form, OnResponseListener listener) {
        api.retrievePassword(form)
                .compose(((ActivityLifecycleProvider) context).bindUntilEvent(ActivityEvent.DESTROY))
                .subscribeOn(Schedulers.newThread())
                .observeOn(AndroidSchedulers.mainThread())
                .subscribe(new HttpSubscriber(listener));
    }

    /**
     * 绑定和解绑手机
     *
     * @param context
     * @param form
     * @param listener
     */
    public static void bindPhone(Context context, String type, PhoneBindForm form, OnResponseListener listener) {
        if (type.equals(StringConstant.BIND_PHONE)) {
            api.bindPhone(form, AccountCenter.newInstance().userId.get(),
                    AccountCenter.newInstance().token.get())
                    .compose(((ActivityLifecycleProvider) context).bindUntilEvent(ActivityEvent.DESTROY))
                    .subscribeOn(Schedulers.newThread())
                    .observeOn(AndroidSchedulers.mainThread())
                    .subscribe(new HttpSubscriber(listener));
        } else {
            api.unbindPhone(form, AccountCenter.newInstance().userId.get(),
                    AccountCenter.newInstance().token.get())
                    .compose(((ActivityLifecycleProvider) context).bindUntilEvent(ActivityEvent.DESTROY))
                    .subscribeOn(Schedulers.newThread())
                    .observeOn(AndroidSchedulers.mainThread())
                    .subscribe(new HttpSubscriber(listener));
        }
    }

    /**
     * 绑定和解绑邮箱
     *
     * @param context
     * @param form
     * @param listener
     */
    public static void bindEmail(Context context, String type, EmailBindForm form, OnResponseListener listener) {
        if (type.equals(StringConstant.EMAIL_BIND)) {
            api.bindEmail(form, AccountCenter.newInstance().userId.get(),
                    AccountCenter.newInstance().token.get())
                    .compose(((ActivityLifecycleProvider) context).bindUntilEvent(ActivityEvent.DESTROY))
                    .subscribeOn(Schedulers.newThread())
                    .observeOn(AndroidSchedulers.mainThread())
                    .subscribe(new HttpSubscriber(listener));
        } else {
            api.unbindEmail(AccountCenter.newInstance().userId.get(),
                    AccountCenter.newInstance().userId.get(),
                    AccountCenter.newInstance().token.get())
                    .compose(((ActivityLifecycleProvider) context).bindUntilEvent(ActivityEvent.DESTROY))
                    .subscribeOn(Schedulers.newThread())
                    .observeOn(AndroidSchedulers.mainThread())
                    .subscribe(new HttpSubscriber(listener));
        }
    }

    /**
     * 发送手机验证码
     *
     * @param context
     * @param phoneNum
     * @param listener
     */
    public static void sendCode(Context context, String phoneNum, String type, OnResponseListener listener) {
        api.sendCode(phoneNum, type,
                AccountCenter.newInstance().userId.get(),
                AccountCenter.newInstance().token.get())
                .compose(((ActivityLifecycleProvider) context).bindUntilEvent(ActivityEvent.DESTROY))
                .subscribeOn(Schedulers.newThread())
                .observeOn(AndroidSchedulers.mainThread())
                .subscribe(new HttpSubscriber(listener));
    }

    /**
     * 发送邮箱验证码
     *
     * @param context
     * @param email
     * @param listener
     */
    public static void sendEmailCode(Context context, String email, OnResponseListener listener) {
        api.sendEmailCode(email,
                AccountCenter.newInstance().userId.get(),
                AccountCenter.newInstance().token.get())
                .compose(((ActivityLifecycleProvider) context).bindUntilEvent(ActivityEvent.DESTROY))
                .subscribeOn(Schedulers.newThread())
                .observeOn(AndroidSchedulers.mainThread())
                .subscribe(new HttpSubscriber(listener));
    }

    /**
     * 发送验证码 找回密码
     *
     * @param context
     * @param phoneNum
     * @param listener
     */
    public static void retrieve(Context context, String phoneNum, OnResponseListener listener) {
        api.retrieve(phoneNum, "passwordReFound")
                .compose(((ActivityLifecycleProvider) context).bindUntilEvent(ActivityEvent.DESTROY))
                .subscribeOn(Schedulers.newThread())
                .observeOn(AndroidSchedulers.mainThread())
                .subscribe(new HttpSubscriber(listener));
    }

    /**
     * 修改昵称
     *
     * @param context
     * @param nickName
     * @param listener
     */
    public static void changeNickName(Context context, String nickName, OnResponseListener<User> listener) {
        api.changeNickName(nickName, AccountCenter.newInstance().userId.get(),
                AccountCenter.newInstance().token.get())
                .compose(((ActivityLifecycleProvider) context).bindUntilEvent(ActivityEvent.DESTROY))
                .subscribeOn(Schedulers.newThread())
                .observeOn(AndroidSchedulers.mainThread())
                .subscribe(new HttpSubscriber<>(listener));
    }

    /**
     * 修改用户信息
     *
     * @param context
     * @param user
     * @param listener
     */
    public static void changeInfo(Context context, User user, OnResponseListener<User> listener) {
        api.changeInfo(user, AccountCenter.newInstance().userId.get(),
                AccountCenter.newInstance().token.get())
                .compose(((ActivityLifecycleProvider) context).bindUntilEvent(ActivityEvent.DESTROY))
                .subscribeOn(Schedulers.newThread())
                .observeOn(AndroidSchedulers.mainThread())
                .subscribe(new HttpSubscriber<>(listener));
    }

    /**
     * 上传头像
     *
     * @param context
     * @param file
     * @param fileName
     * @param listener
     */
    public static void uploadIcon(Context context, File file, String fileName, OnResponseListener<String> listener) {
        RequestBody requestFile = RequestBody.create(MediaType.parse("multipart/form-data"), file);
        MultipartBody.Part body = MultipartBody.Part.createFormData("file", fileName, requestFile);

        api.uploadIcon(fileName, "jpg", body,
                AccountCenter.newInstance().userId.get(),
                AccountCenter.newInstance().token.get())
                .compose(((ActivityLifecycleProvider) context).bindUntilEvent(ActivityEvent.DESTROY))
                .subscribeOn(Schedulers.newThread())
                .observeOn(AndroidSchedulers.mainThread())
                .subscribe(new HttpSubscriber<>(listener));
    }

    /**
     * 检测更新
     *
     * @param listener
     */
    public static void checkAppVersion(OnResponseListener<LatestVersion> listener) {
        updateApi.checkAppVersion()
                .subscribeOn(Schedulers.newThread())
                .observeOn(AndroidSchedulers.mainThread())
                .subscribe(new HttpSubscriber<>(listener));
    }

    /**
     * 拉取App初始化数据
     *
     * @param context
     * @param listener
     */
    public static void loadAppConfig(Context context, OnResponseListener<AppConfig> listener) {
        updateApi.loadAppConfig()
                .compose(((ActivityLifecycleProvider) context).bindUntilEvent(ActivityEvent.DESTROY))
                .subscribeOn(Schedulers.newThread())
                .observeOn(AndroidSchedulers.mainThread())
                .subscribe(new HttpSubscriber<>(listener));
    }

    /**
     * 邮箱重置密码
     *
     * @param context
     * @param email
     * @param listener
     */
    public static void resetPassword(Context context, String email, OnResponseListener listener) {
        api.resetPassword(email)
                .compose(((ActivityLifecycleProvider) context).bindUntilEvent(ActivityEvent.DESTROY))
                .subscribeOn(Schedulers.newThread())
                .observeOn(AndroidSchedulers.mainThread())
                .subscribe(new HttpSubscriber(listener));
    }

    public static void logout(Context context, OnResponseListener listener) {
        api.logout(AccountCenter.newInstance().userId.get(),
                AccountCenter.newInstance().token.get())
                .compose(((ActivityLifecycleProvider) context).bindUntilEvent(ActivityEvent.DESTROY))
                .subscribeOn(Schedulers.newThread())
                .observeOn(AndroidSchedulers.mainThread())
                .subscribe(new HttpSubscriber(listener));

    }

}
