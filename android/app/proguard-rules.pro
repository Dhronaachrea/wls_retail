# Add project specific ProGuard rules here.

-keepclasseswithmembers class com.skilrock.wls_pos.** {
    public ** component1();
    <fields>;
}

-keep class com.skilrock.wls_pos.** {
public *;
}

-keep class android.support.**{*;}
-keep class org.jsoup.**{*;}
-keep class com.google.**{*;}

-keep class javax.* { *; }
-keep class org.* { *; }
-keep class com.afollestad.* {*;}

