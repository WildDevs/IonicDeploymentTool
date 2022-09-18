#!/bin/sh

# Ionic Deployment Tool for Android Google Play with jarsigner and zipalign
# Created by Eray Sönmez, www.ray-works.de, info@ray-works.de

# This program is free software; you can redistribute it and/or modify it
# under the terms of the GNU General Public License as published by the
# Free Software Foundation; either version 3 of the License, or (at your option)
# any later version.

# This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY;
# without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
# See the GNU General Public License for more details.

# You should have received a copy of the GNU General Public License along with this program;
# if not, see <http://www.gnu.org/licenses/>.

# Before using this tool, you need to create a keystore file
# 	keytool -genkey -v -keystore my-release-key.jks -keyalg RSA -keysize 2048 -validity 10000 -alias my-alias
# You’ll first be prompted to create a password for the keystore.
# Then, answer the rest of the nice tools’s questions and when it’s all done,
# you should have a file called my-release-key.jks created in the current directory.

# Also you need the Android & Java SDKs (especially build-tools) to use jarsigner and zipalign
# Do not forget to set the sdk bin and build-tools directories in the Environment PATH Variable

# Settings
APPNAME="MyApp"
DATE=`date +%d-%m-%Y`
ALIAS="myapp"
KEYSTORE="myapp.jks"
KEYSTOREPASS="mypass"

# Do not change unless you know what you are doing
APKPATH="platforms/android/build/outputs/apk"
LOGDIR="${APKPATH}/DeployLogs"
LOGFILE=${LOGDIR}/$(date +%d-%m-%Y-%H-%M).log
OUTPUTFILENAME=${APPNAME}-${DATE}.apk
ANDROIDRELEASEFILE="android-release-unsigned.apk"

# Coloring
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
NC='\033[0m' # No Color

interrupthandler() {
    echo "[INTERRUPTED] Script got interrupted. You may run this script again."
    exit
}

trap -- interrupthandler INT

echo "-------------------------------------"
echo "Ionic Deployment Tool for Android"
echo "by Eray Sönmez, www.ray-works.de"
echo "-------------------------------------"

echo ""
if [ "$(id -u)" != "0" ]; then
	printf "${RED}You dont have enough permissions.\nPlease run this script with sudo or as root (not recommended)\n\n"
	exit 2
fi

if [ ! -d "${LOGDIR}" ]; then
  mkdir ${LOGDIR}
	if [ $? == 0 ]; then
		printf "${GREEN}[OK]${NC} Log directory created: $LOGDIR\n"
	else
		printf "${RED}[ERROR]${NC} Something went wrong while creating log directory\n"
		exit 1
	fi

fi

if [ -f  "${APKPATH}/${ANDROIDRELEASEFILE}" ]; then
    rm ${APKPATH}/${ANDROIDRELEASEFILE}
		if [ $? == 0 ]; then
			printf "${GREEN}[OK]${NC} Removed old unsigned android release apk file\n"
		else
			printf "${RED}[ERROR]${NC} Something went wrong while deleting old unsigned android apk file\n"
			exit 1
		fi
fi

if [ -f "${APKPATH}/${OUTPUTFILENAME}" ]; then
    rm ${APKPATH}/${OUTPUTFILENAME}
		if [ $? == 0 ]; then
			printf "${GREEN}[OK]${NC} Removed old signed app apk file which created today\n"
		else
			printf "${RED}[ERROR]${NC} Something went wrong while deleting old signed app apk file\n"
			exit 1
		fi
fi

echo ""

printf "${YELLOW}[!]${NC} Building android apk in production and release mode\n"
ionic cordova build android --prod --release >> ${LOGFILE} 2>&1
if [ $? == 0 ]; then
	printf "${GREEN}[OK]${NC} Android build done\n"
else
	printf "${RED}[ERROR]${NC} Something went wrong, please check the logfile ${LOGFILE}\n"
	exit 1
fi

echo ""

printf "${YELLOW}[!]${NC} Signing created apk file\n"
jarsigner -verbose -sigalg SHA1withRSA -digestalg SHA1 -keystore ${KEYSTORE} ${APKPATH}/${ANDROIDRELEASEFILE} ${ALIAS} -storepass ${KEYSTOREPASS} >> ${LOGFILE} 2>&1
if [ $? == 0 ]; then
	printf "${GREEN}[OK]${NC} apk file signed\n"
else
	printf "${RED}[ERROR]${NC} Something went wrong, please check the logfile ${LOGFILE}\n"
	exit 1
fi

echo ""

printf "${YELLOW}[!]${NC} Optimizing signed apk file\n"
zipalign -v 4 ${APKPATH}/${ANDROIDRELEASEFILE} ${APKPATH}/${OUTPUTFILENAME} >> ${LOGFILE} 2>&1
if [ $? == 0 ]; then
	printf "${GREEN}[OK]${NC} apk file optimized and is now ready to upload to the Google Play Store\n"
else
	printf "${RED}[ERROR]${NC} Something went wrong, please check the logfile ${LOGFILE}\n"
	exit 1
fi

echo ""

echo "Thank you for using my Ionic Deployment Tool for Android"
