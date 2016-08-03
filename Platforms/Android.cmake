FUNCTION(VERITAS_ANDROID_ADD_EXECUTABLE TARGET)
    GET_FILENAME_COMPONENT(ANDROID_SDK ${ANDROID_SDK} ABSOLUTE)
    SET(ANDROID_PROJECT_NAME "Android${TARGET}")
    SET(ANDROID_PROJECT_PATH "${CMAKE_BINARY_DIR}/${ANDROID_PROJECT_NAME}")
    SET(ANDROID_PACKAGE_NAME "com.silexars.${ANDROID_PROJECT_NAME}")
    SET(ANDROID_ACTIVITY_NAME "Main")

    EXECUTE_PROCESS(COMMAND ${ANDROID_SDK}/tools/android create project -n ${ANDROID_PROJECT_NAME} -t "android-${ANDROID_NATIVE_API_LEVEL}" -k ${ANDROID_PACKAGE_NAME} -a ${ANDROID_ACTIVITY_NAME} -p ${ANDROID_PROJECT_PATH} -g -v 0.11.+)
    FILE(WRITE "${ANDROID_PROJECT_PATH}/src/main/AndroidManifest.xml"
        "<?xml version=\"1.0\"?>\n\
        <manifest xmlns:android=\"http://schemas.android.com/apk/res/android\" package=\"${ANDROID_PACKAGE_NAME}\" android:versionCode=\"1\" android:versionName=\"1.0\">\n\
            <uses-sdk android:minSdkVersion=\"${ANDROID_NATIVE_API_LEVEL}\" android:targetSdkVersion=\"${ANDROID_NATIVE_API_LEVEL}\"/>\n\
            <uses-feature android:glEsVersion=\"0x00020000\"/>\n\
            <application android:label=\"${TARGET}\" android:hasCode=\"false\">\n\
                <activity android:name=\"android.app.NativeActivity\" android:label=\"${TARGET}\">\n\
                    <meta-data android:name=\"android.app.lib_name\" android:value=\"native-activity\"/>\n\
                    <intent-filter>\n\
                        <action android:name=\"android.intent.action.MAIN\"/>\n\
                        <category android:name=\"android.intent.category.LAUNCHER\"/>\n\
                    </intent-filter>\n\
                </activity>\n\
            </application>\n\
        </manifest>"
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
    ADD_CUSTOM_COMMAND(TARGET ${TARGET} COMMAND ${ANDROID_SDK}/platform-tools/adb shell monkey -p ${ANDROID_PACKAGE_NAME} 1)
ENDFUNCTION()
