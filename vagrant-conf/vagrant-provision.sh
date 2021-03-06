#!/usr/bin/env bash

echo "Provisioning android-dev VM"


# create environment variables from name/value pair arguments
while test $# -gt 0
do
  NAME=$1
  shift
  if [ $# -gt 0 ]
  then
    echo "export $NAME=$1" | tee -a /home/vagrant/.bash_profile
  fi
  shift
done


source /home/vagrant/.bash_profile
#add keystore
echo "Installing keystore"
mkdir -p /home/vagrant/.android
keytool -genkey -v -keystore /home/vagrant/.android/debug.keystore -alias androiddebugkey -storepass android -keypass android -keyalg RSA -keysize 2048 -validity 10000 -dname "CN=Android Debug,O=Android,C=US"
echo "Installed keystore"
# install requried SDK components
( sleep 5 && while [ 1 ]; do sleep 1; echo y; done ) | sudo $ANDROID_HOME/tools/android update sdk --all --filter android-19,extra-android-support,extra-android-m2repository,extra-google-m2repository,sys-img-x86-android-19,build-tools-20.0.0 --no-ui
#echo yes | sudo $ANDROID_HOME/tools/android update sdk --all --filter build-tools-20.0.0 --no-ui
#echo yes | sudo $ANDROID_HOME/tools/android update sdk --all --filter sys-img-x86-android-19 --no-ui
#( sleep 5 && while [ 1 ]; do sleep 1; echo y; done ) | sudo $ANDROID_HOME/tools/android update sdk --all --filter android-19,extra-android-support,extra-android-m2repository,extra-google-m2repository,sys-img-x86-android-19,build-tools-20.0.0 --no-ui
# Create the emulator
echo no | android create avd -n EMULATOR -t 1 -b x86
sudo echo "hw.gpu.enabled=yes" >> /root/.android/avd/EMULATOR.avd/config.ini
sudo perl -pi -e 's/hw.ramSize=512/hw.ramSize=1024/g' /root/.android/avd/EMULATOR.avd/config.ini
# Start emulator
emulator -avd EMULATOR -no-skin -no-audio -no-window &

OUT=`adb shell getprop init.svc.bootanim`
RES="stopped"

while [[ ${OUT:0:7}  != 'stopped' ]]; do
  OUT=`adb shell getprop init.svc.bootanim`
  echo 'Waiting for emulator to fully boot...'
  sleep 1
done

echo "Emulator booted!"
