#include "pers_nelon_library_AhaJni.h"

extern "C" {
#include <libavutil/imgutils.h>
#include <libavcodec/avcodec.h>
#include <libswscale/swscale.h>
}

JNIEXPORT jstring JNICALL Java_pers_nelon_library_AhaJni_stringFromAha
        (JNIEnv *env, jobject thiz) {

    char info[10000] = {0};
    avcodec_register_all();
//    sprintf(info, "avcodec_version: %s\n", avcodec_configuration());
    sprintf(info, "avcodec_license: %s\n", avcodec_license());

    return env->NewStringUTF(info);
}