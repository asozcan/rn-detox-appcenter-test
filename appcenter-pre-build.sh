#!/usr/bin/env bash

if [ -z "$PLATFORM" ]; then
  echo "You need define the PLATFORM variable in App Center with values android or ios"
  exit
fi

if [ -z "$SMTP_PASSWORD" ]; then
  echo "You need define the SMTP_PASSWORD variable in App Center for 'influenster.appcenter@gmail.com'"
  exit
fi

if [ -z "$FAIL_WITH_E2E" ]; then
  FAIL_WITH_E2E=true
fi

if [ -z "$E2E_MAIL_TO" ]; then
  E2E_MAIL_TO="asozcan@yandex.com"
fi

set -Ee
function _catch() {
  # Subject Title
  SUBJECT="Influenster e2e Test have failed step(s)!"

  muttrcFile='~/.muttrc'
  muttdir='~/.mutt'
  # /Config

  echo "This script installs mutt and configures it to be used with Gmail or Google Apps"

  muttrcFileExpanded=$(eval echo $muttrcFile)
  muttdirExpanded=$(eval echo $muttdir)

  echo
  echo '... Attempting mutt install'
  brew install mutt
  if [ $? -ne 0 ]; then
    echo -e 'brew mutt install: failed'
    echo 'Exiting'
    exit
  else
    echo 'mutt install: done'
  fi

  echo
  echo "... Setting $muttrcFile"
  {
    echo "set imap_user = \"influenster.appcenter@gmail.com\""
    echo "set imap_pass = \"$SMTP_PASSWORD\""
    echo "set smtp_url = \"smtps://influenster.appcenter@gmail.com@smtp.gmail.com:465/\""
    echo "set smtp_pass = \"$SMTP_PASSWORD\""
    echo "set smtp_authenticators = \"login\""
    echo "set from = \"influenster.appcenter@gmail.com\""
    echo "set realname = \"Andac Ozcan\""
    echo "set folder = \"imaps://imap.gmail.com\""
    echo "set spoolfile = \"+INBOX\""
    echo "set postponed = \"+[Gmail]/Drafts\""
    echo "set move = no"
    echo "set smtp_authenticators = 'gssapi:login'"
  } >$muttrcFileExpanded

  ORG=asozcan2
  APP=Detox-Test-iOS
  if [ "$PLATFORM" == "android" ]; then
    APP=Detox-Test-Android
  fi
  # This is to get the Build Details so we could pass it as part of the Email Body
  build_url=https://appcenter.ms/users/$ORG/apps/$APP/build/branches/$APPCENTER_BRANCH/builds/$APPCENTER_BUILD_ID
  echo $build_url >>./reports/html/results.html
  mutt -e "set content_type=text/html" -s "${SUBJECT}" -a ./reports/html/results.html -- ${E2E_MAIL_TO} < ./reports/html/results.html
  echo "e2e test log mail sent"
  if [ "$FAIL_WITH_E2E" == "false" ]; then
    exit 0
  else
    exit 1
  fi
}

trap _catch ERR

if [ "$PLATFORM" == "android" ]
then
    export ANDROID_SDK_ROOT=~/Library/Android/sdk

    ANDROID_HOME=~/Library/Android/sdk
    ANDROID_SDK_ROOT=~/Library/Android/sdk
    ANDROID_AVD_HOME=~/.android/avd
    PATH="$ANDROID_HOME/tools:$ANDROID_HOME/tools/bin:$ANDROID_HOME/platform-tools:$PATH"

    echo "Android: Downloading android image..."
    /Users/runner/Library/Android/sdk/tools/bin/sdkmanager "system-images;android-27;default;x86_64"

    echo "Android: Accepting licenses for android images.."
    echo N | $ANDROID_HOME/tools/bin/sdkmanager --licenses --sdk_root=${ANDROID_SDK_ROOT}
    echo $ANDROID_HOME/tools/bin/sdkmanager --update

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
