# Add project specific ProGuard rules here.
# By default, the flags in this file are appended to flags specified
# in D:\Android\SDK/tools/proguard/proguard-android.txt
# You can edit the include path and order by changing the proguardFiles
# directive in build.gradle.
#
# For more details, see
#   http://developer.android.com/guide/developing/tools/proguard.html

# Add any project specific keep options here:

# If your project uses WebView with JS, uncomment the following
# and specify the fully qualified class name to the JavaScript interface
# class:
#-keepclassmembers class fqcn.of.javascript.interface.for.webview {
#   public *;
#}

# Uncomment this to preserve the line number information for
# debugging stack traces.
#-keepattributes SourceFile,LineNumberTable

# If you keep the line number information, uncomment this to
# hide the original source file name.
#-renamesourcefileattribute SourceFile

# 声明第三方jar包 。
# 这里自己看项目有什么包就加什么包，不要照搬。

# 这里是混淆后还能保留的属性。
# 保留异常，内部类，注解，泛型，保留行号的属性。
-ignorewarnings
-keepattributes Signature
-keepattributes Exceptions
-keepattributes *Annotation*
-keepattributes InnerClasses
# 还有其它属性，如：LocalVariableTable 局部变量、SourceFile 源文件、Deprecated 废弃、Synthetic 合成。

# 保留序列化。
# 比如我们要向activity传递对象使用了Serializable接口的时候，这时候这个类及类里面#的所有内容都不能混淆。
# 这里如果项目有用到序列化和反序列化要加上这句。
-keepnames class * implements java.io.Serializable
-keepclassmembers class * implements java.io.Serializable { *; }

# 保留适配器
-keep public class * extends android.widget.BaseAdapter {*;}
# 如果你使用了CusorAdapter,添加下面这行
-keep public class * extends android.widget.CusorAdapter{*;}

-keep public class * extends android.app.Activity
-keepclassmembers class * extends android.app.Activity {
   public void *(android.view.View);
}
-keep public class * extends android.app.Application
-keep public class * extends android.app.Service
-keep public class * extends android.content.BroadcastReceiver
-keep public class * extends android.content.ContentProvider
-keep public class * extends android.app.backup.BackupAgentHelper
-keep public class * extends android.preference.Preference
-keep public class * extends android.view.View {*;}
-keep public class * extends android.widget.PopupWindow {*;}
-keep public class * extends android.app.Fragment
-keep public class * extends android.support.v4.**
-keep public class * extends android.support.v7.**
-keep public class com.android.vending.licensing.ILicensingService
-keepclasseswithmembers class * {
    public <init>(android.content.Context, android.util.AttributeSet);
}
-keepclasseswithmembers class * {
    public <init>(android.content.Context, android.util.AttributeSet, int);
}

# 保留点击和回调函数
-keepclasseswithmembers class * {
    void onClick*(...);
}
-keepclasseswithmembers class * {
    *** *Callback(...);
}

##-----------------Bolckymods--------------------
-keep class **.entity.** {*;}
-keep class com.sandboxol.blocky.** {*;}
-keep class com.sandboxol.common.** {*;}
-keep public class * extends com.sandboxol.common.base.viewmodel.**
-keep public class * implements com.sandboxol.common.base.viewmodel.IListViewModel
-keep public class * extends com.sandboxol.common.base.model.DefaultListModel
-keep public class * implements com.sandboxol.common.base.model.IDefaultModel
-keep public class * implements com.sandboxol.common.base.model.IListModel
-keep public class * implements com.sandboxol.common.base.model.IModel

##-------------------BlockmanGo----------------------
-keep class com.sandboxol.blockmango.** {*;}
-keep class com.mcpeonline.multiplayer.router.** {*;}

##-----------------第三方jar包配置（选择性添加）-------------------------
# Talking Data
-dontwarn com.tendcloud.tenddata.**
-keep class com.tendcloud.** {*;}
-keep public class com.tendcloud.tenddata.** { public protected *;}
-keepclassmembers class com.tendcloud.tenddata.**{
public void *(***);
}
-keep class com.talkingdata.sdk.TalkingDataSDK {public *;}
-keep class com.apptalkingdata.** {*;}
-keep class dice.** {*; }
-dontwarn dice.**

# android support
-dontwarn android.support.**
-keep class android.support.** { *; }

-keep class **.R$* {*;}

#greendao
-keep class org.greenrobot.greendao.**{*;}
-keep class de.greenrobot.dao.** {*;}
-keep class de.greenrobot.event.** {*;}
-keep class de.greenrobot.de.keyboardsurfer.android.widget.crouton.** {*;}

#facebook
-keep class com.facebook.** {*;}
-keep interface com.facebook.** {*;}
-keep enum com.facebook.** {*;}

#WheelPicker(选取框组件 eg.修改性别、出生年月)
-keep class cn.qqtheme.** {*;}

# RxJava RxAndroid
-dontwarn sun.misc.**
-keep class sun.misc.Unsafe {*;}
-keep class rx.** { * ; }
-keep class rx.subjects.SubjectSubscriptionManager
-keepclassmembers class rx.internal.util.unsafe.*ArrayQueue*Field* {
    long producerIndex;
    long consumerIndex;
}
-keepclassmembers class rx.internal.util.unsafe.BaseLinkedQueueProducerNodeRef {
    rx.internal.util.atomic.LinkedQueueNode producerNode;
}
-keepclassmembers class rx.internal.util.unsafe.BaseLinkedQueueConsumerNodeRef {
    rx.internal.util.atomic.LinkedQueueNode consumerNode;
}

-keep class sun.misc.Unsafe { *; }
-keep class com.google.gson.stream.** { *; }

-keep public class * implements com.bumptech.glide.module.GlideModule
-keep public enum com.bumptech.glide.load.resource.bitmap.ImageHeaderParser$** {
  **[] $VALUES;
  public *;
}

#retrofit2
-dontwarn retrofit2.**
-keep class retrofit2.** { *; }
-keepattributes Signature
-keepattributes Exceptions

# okhttp
-dontwarn com.squareup.okhttp3.**
-keep class com.squareup.okhttp3.** { *;}
-dontwarn okio.**

# Retrolambda
-dontwarn java.lang.invoke.*

#grpc
-keep class io.grpc.** { *;}
-keep class io.grpc.stub.** { *;}
-keep class io.grpc.okhttp.** { *;}
-keep class com.google.protobuf.lite.** { *;}


