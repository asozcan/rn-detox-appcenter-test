#!/usr/bin/env bash

#export JAVA_HOME=/Library/Java/JavaVirtualMachines/jdk1.8.0_152.jdk/Contents/Home
#export ANDROID_SDK_ROOT=~/Library/Android/sdk
#
#ANDROID_HOME=~/Library/Android/sdk
#ANDROID_SDK_ROOT=~/Library/Android/sdk
#ANDROID_AVD_HOME=~/.android/avd
#PATH="$ANDROID_HOME/tools:$ANDROID_HOME/tools/bin:$ANDROID_HOME/platform-tools:$PATH"
#
#echo "Android: Downloading android image..."
#/Users/andacozcan/Library/Android/sdk/tools/bin/sdkmanager "system-images;android-27;default;x86_64"
#
#echo "Android: Accepting licenses for android images.."
#echo N | $ANDROID_HOME/tools/bin/sdkmanager --licenses --sdk_root=${ANDROID_SDK_ROOT}
#echo $ANDROID_HOME/tools/bin/sdkmanager --update
#touch /Users/andacozcan/.android/repositories.cfg
#
#echo "Android: Creating AVD.."
#echo no | /Users/andacozcan/Library/Android/sdk/tools/bin/avdmanager create avd -n Pixel_API_27_AOSP -d pixel --package "system-images;android-27;default;x86_64"
#cp app-center/config.ini /Users/andacozcan/.android/avd/Pixel_API_27_AOSP.avd/config.ini
#
#DETOX_CONFIG=android.emu.release
#
#echo "Building the project for Detox tests..."
#npx detox build --configuration "$DETOX_CONFIG"
#
#echo "Executing Detox tests..."
#npx detox test --configuration "$DETOX_CONFIG" --cleanup
