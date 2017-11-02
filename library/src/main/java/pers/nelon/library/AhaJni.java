package pers.nelon.library;

/**
 * Created by nelon on 17-10-31.
 */

public class AhaJni {
    static {
        System.loadLibrary("avutil");
        System.loadLibrary("swresample");
        System.loadLibrary("avcodec");
        System.loadLibrary("avformat");
        System.loadLibrary("swscale");
        System.loadLibrary("avfilter");
        System.loadLibrary("avdevice");
        System.loadLibrary("aha-jni");
    }


    public native String stringFromAha();
}
