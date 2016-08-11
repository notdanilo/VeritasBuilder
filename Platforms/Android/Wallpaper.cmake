FUNCTION(VERITAS_ANDROID_ADD_WALLPAPER TARGET)
    GET_FILENAME_COMPONENT(ANDROID_SDK ${ANDROID_SDK} ABSOLUTE)
    SET(ANDROID_PROJECT_NAME "Android${TARGET}")
    SET(ANDROID_PROJECT_PATH "${CMAKE_BINARY_DIR}/${ANDROID_PROJECT_NAME}")
    SET(ANDROID_PACKAGE_NAME "com.silexars.${ANDROID_PROJECT_NAME}")
    SET(ANDROID_ACTIVITY_NAME "Main")

    EXECUTE_PROCESS(COMMAND ${ANDROID_SDK}/tools/android create project -n ${ANDROID_PROJECT_NAME} -t "android-${ANDROID_NATIVE_API_LEVEL}" -k ${ANDROID_PACKAGE_NAME} -a ${ANDROID_ACTIVITY_NAME} -p ${ANDROID_PROJECT_PATH} -g -v 0.11.+)
    FILE(WRITE "${ANDROID_PROJECT_PATH}/src/main/AndroidManifest.xml"
        "<?xml version=\"1.0\" encoding=\"utf-8\"?>\n\
        <manifest xmlns:android=\"http://schemas.android.com/apk/res/android\" package=\"${ANDROID_PACKAGE_NAME}\" android:versionCode=\"1\" android:versionName=\"1.0\">\n\
            <uses-feature android:name=\"android.software.live_wallpaper\"/>\n\
            <uses-sdk android:minSdkVersion=\"${ANDROID_NATIVE_API_LEVEL}\" android:targetSdkVersion=\"${ANDROID_NATIVE_API_LEVEL}\"/>\n\
            <application android:allowBackup=\"true\" android:icon=\"@drawable/ic_launcher\" android:label=\"${TARGET}\">\n\
                <service android:name=\".Wallpaper\" android:label=\"Live Wallpaper\" android:permission=\"android.permission.BIND_WALLPAPER\">\n\
                    <intent-filter>\n\
                        <action android:name=\"android.service.wallpaper.WallpaperService\"/>\n\
                    </intent-filter>\n\
                    <meta-data android:name=\"android.service.wallpaper\" android:resource=\"@xml/wallpaper\"/>\n\
                </service>\n\
            </application>\n\
        </manifest>"
    )

    FILE(WRITE "${ANDROID_PROJECT_PATH}/src/main/res/values/strings.xml"
        "<resources>\n\
            <string name=\"app_name\">Live Wallpaper</string>\n\
            <string name=\"wallpaper_description\">Wallpaper Description!</string>\n\
        </resources>"
    )

    FILE(WRITE "${ANDROID_PROJECT_PATH}/src/main/res/xml/wallpaper.xml"
        "<?xml version=\"1.0\" encoding=\"utf-8\"?>\n\
        <wallpaper xmlns:android=\"http://schemas.android.com/apk/res/android\" android:description=\"@string/wallpaper_description\"/>"
    )

    FILE(WRITE "${ANDROID_PROJECT_PATH}/src/main/java/com/silexars/${ANDROID_PROJECT_NAME}/Wallpaper.java"
        "package ${ANDROID_PACKAGE_NAME};\n\
        \
        import android.service.wallpaper.WallpaperService;\n\
        import android.util.Log;\n\
        import android.view.Surface;\n\
        import android.view.SurfaceHolder;\n\
        import android.content.res.AssetManager;\n\
        \
        public class Wallpaper extends WallpaperService {\n\
            static {\n\
                System.loadLibrary(\"native-activity\");\n\
            }\n\
            \
            public native void nativeOnCreate(AssetManager assetManager);\n\
            public native void nativeOnDestroy();\n\
            \
            public native void nativeOnSurfaceCreated(Surface surface);\n\
            public native void nativeOnSurfaceChanged(Surface surface);\n\
            public native void nativeOnSurfaceDestroyed();\n\
            \
            @Override\n\
            public Engine onCreateEngine() { return new WallpaperEngine(); }\n\
            \
            private class WallpaperEngine extends Engine {\n\
                private AssetManager assetManager;\n\
                \
                @Override\n\
                public void onCreate(SurfaceHolder surfaceHolder) {\n\
                    super.onCreate(surfaceHolder);\n\
                    Log.i(\"WP\", \"onCreate\");\n\
                    assetManager = getResources().getAssets();\n\
                    nativeOnCreate(assetManager);\n\
                }\n\
                @Override\n\
                public void onDestroy() {\n\
                    super.onDestroy();\n\
                    Log.i(\"WP\", \"onDestroy\");\n\
                    nativeOnDestroy();\n\
                }\n\
                \
                @Override\n\
                public void onSurfaceChanged(SurfaceHolder holder, int format, int width, int height) {\n\
                    super.onSurfaceChanged(holder, format, width, height);\n\
                    Log.i(\"WP\", \"onSurfaceChanged\");\n\
                    nativeOnSurfaceChanged(holder.getSurface());\n\
                }\n\
                \
                @Override\n\
                public void onSurfaceCreated(SurfaceHolder holder) {\n\
                    super.onSurfaceCreated(holder);\n\
                    Log.i(\"WP\", \"onSurfaceCreated\");\n\
                    nativeOnSurfaceCreated(holder.getSurface());\n\
                }\n\
                \
                @Override\n\
                public void onSurfaceDestroyed(SurfaceHolder holder) {\n\
                    super.onSurfaceDestroyed(holder);\n\
                    Log.i(\"WP\", \"onSurfaceDestroyed\");\n\
                    nativeOnSurfaceDestroyed();\n\
                }\n\
            }\n\
        }"
    )

    IF(${CMAKE_BUILD_TYPE} MATCHES "Debug")
        SET(ANDROID_BUILD_CMD "assembleDebug")
        SET(ANDROID_BUILD_TYPE "debug")
        SET(ANDROID_APK_NAME "${ANDROID_PROJECT_NAME}-${ANDROID_BUILD_TYPE}")
    ELSE()
        SET(ANDROID_BUILD_CMD "assembleRelease")
        SET(ANDROID_BUILD_TYPE "release")
        #Still need to setup key signing and stuff
    ENDIF()

    ADD_CUSTOM_COMMAND(TARGET ${TARGET} COMMAND ${CMAKE_COMMAND} -E copy $<TARGET_FILE:${TARGET}> "${ANDROID_PROJECT_PATH}/src/main/jniLibs/${ANDROID_ABI}/libnative-activity.so")
    ADD_CUSTOM_COMMAND(TARGET ${TARGET} COMMAND ${ANDROID_PROJECT_PATH}/gradlew -p ${ANDROID_PROJECT_PATH} ${ANDROID_BUILD_CMD})
    ADD_CUSTOM_COMMAND(TARGET ${TARGET} COMMAND ${ANDROID_SDK}/platform-tools/adb install -r ${ANDROID_PROJECT_PATH}/build/outputs/apk/${ANDROID_APK_NAME}.apk)
ENDFUNCTION()
