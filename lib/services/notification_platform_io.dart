import 'dart:io';

bool get notificationPlatformSupported =>
    Platform.isAndroid || Platform.isIOS || Platform.isMacOS;

bool get notificationIsAndroid => Platform.isAndroid;
bool get notificationIsIOS => Platform.isIOS;
bool get notificationIsMacOS => Platform.isMacOS;
