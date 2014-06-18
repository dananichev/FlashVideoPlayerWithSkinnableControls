#!/bin/bash
FLEXPATH=/Applications/FLEX_SDK
#FLEXPATH=../../flex_sdk_4.6
#FLEXPATH=../../../apache_flex_sdk
#FLEXPATH=../../../AIRSDK_Compiler

echo "Compiling videoplayer.swf"
$FLEXPATH/bin/mxmlc ../src/net/dananichev/FisheyePlayer.as \
	-source-path ../src \
	-o ../bin/videoplayer.swf \
	$COMMON_OPT \
	-library-path+=../lib/swc/away3d-core-fp11_4_1_6.swc \
	-target-player="13" \
	-swf-version=13 \
	-default-background-color=0x000000

#	-library-path+=../lib/away3d-core-fp11_4_1_6.swc \
#	-default-size 480 270 \
