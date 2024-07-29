package com.kqed.jwplayer.jwplayer

enum class CallbackMethod(val methodKey:String) {
    sdkLicenseKeySetSuccess("org.kqed.plugin.jwplayer_license_key_set_success"),
    sdkLicenseKeyNull("org.kqed.plugin.jwplayer_license_key_is_null"),
    sdkInitializeError("org.kqed.plugin.sdk_initialize_error"),
    sdkPlayMethodCalled("org.kqed.plugin.play_method_called"),
    sdkUnknownMethodError("org.kqed.plugin.unknown_method_error"),
    sdkUrlIsNull("org.kqed.plugin.video_url_is_null"),
    sdkArgumentsMapError("org.kqed.plugin.error_accessing_arguments_map"),
    sdkUnableToFindVC("org.kqed.plugin.unable_to_find_viewcontroller");
}