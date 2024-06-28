 -keep class org.pytorch.** {*;} 
 -keep class com.facebook.** {*;}
 -keep class io.grpc.** {*;}
 -keepclassmembers enum * {
    public static **[] values();
    public static ** valueOf(java.lang.String);
}