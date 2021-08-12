#!/usr/bin/env bash
if [ -z "$APP_CENTER_CURRENT_PLATFORM" ]
then
    echo "You need define the APP_CENTER_CURRENT_PLATFORM variable in App Center with values android or ios"
    exit
fi

set -Ee
function _catch {
    USER=asozcan2
    APP=Detox-Test-Android
    # This is to get the Build Details so we could pass it as part of the Email Body
    build_url=https://appcenter.ms/users/$USER/apps/$APP/build/branches/$APPCENTER_BRANCH/builds/$APPCENTER_BUILD_ID
    # Address to send email
    TO_ADDRESS="asozcan@yandex.com"
    # A sample Subject Title 
    SUBJECT="AppCenter Build"
    # Content of the Email on Build-Success.
    SUCCESS_BODY="Success! Your build completed successfully!\n\n"
    # Content of the Email on Build-Failure.
    FAILURE_BODY="Sorry! Your AppCenter Build failed. Please review the logs and try again.\n\n"
    #If Agent Job Build Status is successful, Send the email, if not send a failure email.
    if [ "$AGENT_JOBSTATUS" == "Succeeded" ];
    then
        echo "e2e Tests Success!"
        echo -e ${SUCCESS_BODY} ${build_url} | mailx -a /reports/html/results.html -s "${SUBJECT} - Success!" ${TO_ADDRESS}
        echo "success mail sent"
    else
        echo "e2e Tests Failed!"
        echo -e ${FAILURE_BODY} ${build_url} | mailx -a /reports/html/results.html -s "${SUBJECT} - Failed!" ${TO_ADDRESS}
        echo "failure mail sent"
    fi
}

function _finally {
  echo "Block C runs"
}
trap _catch ERR
trap _finally EXIT

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
