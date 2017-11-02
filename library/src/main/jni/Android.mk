LOCAL_PATH := $(call my-dir)

FFMPEG_LIB := $(LOCAL_PATH)/ffmpeg/armeabi-v7a/lib
FFMPEG_INCLUDE := $(LOCAL_PATH)/ffmpeg/armeabi-v7a/include

include $(CLEAR_VARS)
LOCAL_MODULE := avcodec
LOCAL_SRC_FILES := $(FFMPEG_LIB)/libavcodec.so
include $(PREBUILT_SHARED_LIBRARY)

include $(CLEAR_VARS)
LOCAL_MODULE := avdevice
LOCAL_SRC_FILES := $(FFMPEG_LIB)/libavdevice.so
include $(PREBUILT_SHARED_LIBRARY)

include $(CLEAR_VARS)
LOCAL_MODULE := avfilter
LOCAL_SRC_FILES := $(FFMPEG_LIB)/libavfilter.so
include $(PREBUILT_SHARED_LIBRARY)

include $(CLEAR_VARS)
LOCAL_MODULE := avformat
LOCAL_SRC_FILES := $(FFMPEG_LIB)/libavformat.so
include $(PREBUILT_SHARED_LIBRARY)

include $(CLEAR_VARS)
LOCAL_MODULE := avutil
LOCAL_SRC_FILES := $(FFMPEG_LIB)/libavutil.so
include $(PREBUILT_SHARED_LIBRARY)

include $(CLEAR_VARS)
LOCAL_MODULE := swresample
LOCAL_SRC_FILES := $(FFMPEG_LIB)/libswresample.so
include $(PREBUILT_SHARED_LIBRARY)

include $(CLEAR_VARS)
LOCAL_MODULE := swscale
LOCAL_SRC_FILES := $(FFMPEG_LIB)/libswscale.so
include $(PREBUILT_SHARED_LIBRARY)

include $(CLEAR_VARS)
LOCAL_MODULE    := aha-jni
LOCAL_SRC_FILES := pers_nelon_library_AhaJni.cpp
LOCAL_C_INCLUDES += $(FFMPEG_INCLUDE)
LOCAL_LDLIBS := -llog -lz
LOCAL_CXXFLAGS += -D__STDC_CONSTANT_MACROS
LOCAL_SHARED_LIBRARIES := avcodec avdevice avfilter avformat avutil swresample swscale
include $(BUILD_SHARED_LIBRARY)