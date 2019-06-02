
# ==============一、编译Flutter工程==============================
echo "Clean old build"
find . -d -name "build" | xargs rm -rf
flutter clean

echo "Get package"
flutter packages get

echo "Build release AOT"
# flutter build aot --release --preview-dart-2 --output-dir=build/flutteroutput/aot
flutter build aot --release --output-dir=build/flutteroutput/aot

echo "Build release Bundle"
flutter build bundle --precompiled --asset-dir=build/flutteroutput/flutter_assets

# ============================================



# ================三. 同时将这个aar和Flutter Plugin编译出来的aar一起发布到maven仓库。=========
# ===1、从build中copy到packflutter资源等 =======

echo "Clean packflutter input(flutter build)"
rm -rf android/packflutter/flutter/

# copy flutter.jar
echo "Copy flutter jar"
if [ "$1" == "dev" ]; then
    mkdir -p android/packflutter/flutter/flutter/android-arm-release && cp $FLUTTER_HOME/bin/cache/artifacts/engine/android-arm/flutter.jar "$_"
else
    mkdir -p android/packflutter/flutter/flutter/android-arm-release && cp $FLUTTER_HOME/bin/cache/artifacts/engine/android-arm-release/flutter.jar "$_"
fi

# copy assets
echo "Copy flutter asset"
mkdir -p android/packflutter/flutter/assets/release && cp -r build/flutteroutput/* "$_"
# mkdir -p android/packflutter/flutter/assets/release/flutter_assets && cp -r build/flutteroutput/flutter_assets/* "$_"


#====== 2 flutter库和flutter_app打成aar 同时publish到Ali-maven
echo "Build flutter to aar"
cd android

#  只build 不上传
#./gradlew :app:clean :packflutter:build

if [ -n "$1"]; then
    ./gradlew :packflutter:clean :packflutter:uploadArchives -PAAR_VERSION=$1
else
    ./gradlew :packflutter:clean :packflutter:uploadArchives
fi


#======发布Flutter Plugin的aar ====
echo "Start publish flutter-plugins"
for line in $(cat .flutter-plugins)
do
    plugin_name=${line%%=*}
    echo "Build and push plugin:" ${plugin_name}

    cd android
    if [ -n "$1"]
    then
        ./gradlew :${plugin_name}:clean :${plugin_name}:uploadArchives -PAAR_VERSION=$1
    else
        ./gradlew :${plugin_name}:clean :${plugin_name}:uploadArchives
    fi
    cd ../
    echo 'end.....'
done
















