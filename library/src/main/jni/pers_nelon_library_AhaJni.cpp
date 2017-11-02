#include <stdio.h>
#include "libavformat/avformat.h"
#include "libavcodec/avcodec.h"
#include "pers_nelon_library_AhaJni.h"

#if defined(__arm__)
#if defined(__ARM_ARCH_7A__)
#if defined(__ARM_NEON__)
#define ABI "armeabi-v7a/NEON"
#else
#define ABI "armeabi-v7a"
#endif
#else
#define ABI "armeabi"
#endif
#elif defined(__i386__)
#define ABI "x86"
#elif defined(__mips__)
#define ABI "mips"
#else
#define ABI "unknown"
#endif

JNIEXPORT jstring JNICALL Java_pers_nelon_library_AhaJni_stringFromAha
        (JNIEnv *env, jobject thiz) {

    char *info = new char[40000];
    av_register_all();
    sprintf(info, "%s\n", avcodec_configuration());

    return env->NewStringUTF(info);
}