#!/usr/bin/env bash
if [ -z "$APP_CENTER_CURRENT_PLATFORM" ]
then
    echo "You need define the APP_CENTER_CURRENT_PLATFORM variable in App Center with values android or ios"
    exit
fi

if [ "$APP_CENTER_CURRENT_PLATFORM" == "android" ]
then
    export ANDROID_SDK_ROOT=~/Library/Android/sdk

    ANDROID_HOME=~/Library/Android/sdk
    ANDROID_SDK_ROOT=~/Library/Android/sdk
    ANDROID_AVD_HOME=~/.android/avd
    PATH="$ANDROID_HOME/tools:$ANDROID_HOME/tools/bin:$ANDROID_HOME/platform-tools:$PATH"

    echo "Android: Downloading android image..."
    /Users/runner/Library/Android/sdk/tools/bin/sdkmanager "system-images;android-27;default;x86_64"

    echo "Android: Accepting licenses for android images.."
    echo N | /Users/runner/Library/Android/sdk/tools/bin/sdkmanager --licenses
    touch /Users/runner/.android/repositories.cfg

    echo "Android: Creating AVD.."
    echo no | /Users/runner/Library/Android/sdk/tools/bin/avdmanager create avd -n Pixel_API_27_AOSP -d pixel --package "system-images;android-27;default;x86_64"
    cp app-center/config.ini /Users/runner/.android/avd/Pixel_API_27_AOSP.avd/config.ini

    DETOX_CONFIG=android.emu.release
else
    echo "Install AppleSimUtils"

    brew tap wix/brew
    brew update
    brew install applesimutils

    echo "Install pods "
    cd ios; pod install; cd ..

    DETOX_CONFIG=ios.sim.release
fi

echo "Building the project for Detox tests..."
npx detox build --configuration "$DETOX_CONFIG"

echo "Executing Detox tests..."
npx detox test --configuration "$DETOX_CONFIG" --cleanup
