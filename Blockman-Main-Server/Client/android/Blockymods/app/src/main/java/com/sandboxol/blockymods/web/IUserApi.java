package com.sandboxol.blockymods.web;

import com.sandboxol.blockymods.entity.AppConfig;
import com.sandboxol.blockymods.entity.ChangePasswordForm;
import com.sandboxol.blockymods.entity.EmailBindForm;
import com.sandboxol.blockymods.entity.LatestVersion;
import com.sandboxol.blockymods.entity.LoginRegisterAccountForm;
import com.sandboxol.blockymods.entity.PhoneBindForm;
import com.sandboxol.blockymods.entity.User;
import com.sandboxol.blockymods.entity.Visitor;
import com.sandboxol.common.base.web.HttpResponse;

import okhttp3.MultipartBody;
import retrofit2.http.Body;
import retrofit2.http.DELETE;
import retrofit2.http.GET;
import retrofit2.http.Header;
import retrofit2.http.Multipart;
import retrofit2.http.POST;
import retrofit2.http.PUT;
import retrofit2.http.Part;
import retrofit2.http.Path;
import retrofit2.http.Query;
import rx.Observable;

/**
 * Created by Jimmy on 2017/9/27 0027.
 */
public interface IUserApi {

    @POST("/user/api/v1/visitor")
    Observable<HttpResponse<Visitor>> visitor(@Body LoginRegisterAccountForm loginRegisterAccountForm);

    @POST("/user/api/v1/register")
    Observable<HttpResponse<User>> register(@Body LoginRegisterAccountForm loginRegisterAccountForm);

    @POST("/user/api/v1/user/register")
    Observable<HttpResponse<User>> userRegister(@Body User registerUserForm,
                                                @Header("userId") Long userId,
                                                @Header("Access-Token") String accessToken);

    @POST("/user/api/v1/login")
    Observable<HttpResponse<User>> login(@Body LoginRegisterAccountForm loginRegisterAccountForm);

    @PUT("/user/api/v1/user/login-out")
    Observable<HttpResponse> logout(@Header("userId") Long userId,
                                    @Header("Access-Token") String accessToken);

    @POST("/user/api/v1/user/password/modify")
    Observable<HttpResponse> modifyPassword(@Body ChangePasswordForm passwordModifyRequest,
                                            @Header("userId") Long userId,
                                            @Header("Access-Token") String accessToken);

    @POST("/user/api/v1/user/password")
    Observable<HttpResponse> retrievePassword(@Body PhoneBindForm phoneBindForm);

    @POST("/user/api/v1/sms/send/{phone}")
    Observable<HttpResponse> sendCode(@Path("phone") String phone,
                                      @Query("type") String type,
                                      @Header("userId") Long userId,
                                      @Header("Access-Token") String accessToken);

    @POST("/user/api/v1/emails/{email}")
    Observable<HttpResponse> sendEmailCode(@Query("email") String email,
                                           @Header("userId") Long userId,
                                           @Header("Access-Token") String accessToken);

    @POST("/user/api/v1/sms/send/refound")
    Observable<HttpResponse> retrieve(@Query("phone") String phone,
                                      @Query("type") String type);

    @POST("/user/api/v1/user/bind/phone")
    Observable<HttpResponse> bindPhone(@Body PhoneBindForm form,
                                       @Header("userId") Long userId,
                                       @Header("Access-Token") String accessToken);

    @POST("/user/api/v1/user/unbind/phone")
    Observable<HttpResponse> unbindPhone(@Body PhoneBindForm form,
                                         @Header("userId") Long userId,
                                         @Header("Access-Token") String accessToken);

    @POST("/user/api/v1/users/bind/email")
    Observable<HttpResponse> bindEmail(@Body EmailBindForm form,
                                       @Header("userId") Long userId,
                                       @Header("Access-Token") String accessToken);

    @DELETE("/user/api/v1/users/{userId}/emails")
    Observable<HttpResponse> unbindEmail(@Path("userId") Long userId,
                                         @Header("userId") Long user,
                                         @Header("Access-Token") String accessToken);

    @PUT("/user/api/v1/user/nickName")
    Observable<HttpResponse<User>> changeNickName(@Query("nickName") String nickName,
                                                  @Header("userId") Long userId,
                                                  @Header("Access-Token") String accessToken);

    @PUT("/user/api/v1/user/info")
    Observable<HttpResponse<User>> changeInfo(@Body User updateUserForm,
                                              @Header("userId") Long userId,
                                              @Header("Access-Token") String accessToken);

    @Multipart
    @POST("/user/api/v1/file")
    Observable<HttpResponse<String>> uploadIcon(@Query("fileName") String fileName,
                                                @Query("fileType") String fileType,
                                                @Part MultipartBody.Part file,
                                                @Header("userId") Long userId,
                                                @Header("Access-Token") String accessToken);

    @POST("/user/api/v1/emails/password/reset")
    Observable<HttpResponse> resetPassword(@Query("email") String email);

    @GET("/api/v1/config/blockymods-check-version")
    Observable<HttpResponse<LatestVersion>> checkAppVersion();

    @GET("/api/v1/config/blockmods-config")
    Observable<HttpResponse<AppConfig>> loadAppConfig();


}
