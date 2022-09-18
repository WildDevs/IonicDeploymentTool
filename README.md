Ionic Deployment Tool for Android Google Play with jarsigner and zipalign
Created by Eray Sönmez, www.ray-works.de, info@ray-works.de

This program is free software; you can redistribute it and/or modify it
under the terms of the GNU General Public License as published by the
Free Software Foundation; either version 3 of the License, or (at your option)
any later version.

This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY;
without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
See the GNU General Public License for more details.

You should have received a copy of the GNU General Public License along with this program;
if not, see <http://www.gnu.org/licenses/>.

Before using this tool, you need to create a keystore file
	keytool -genkey -v -keystore my-release-key.jks -keyalg RSA -keysize 2048 -validity 10000 -alias my-alias
You’ll first be prompted to create a password for the keystore.
Then, answer the rest of the nice tools’s questions and when it’s all done,
you should have a file called my-release-key.jks created in the current directory.

Also you need the Android & Java SDKs (especially build-tools) to use jarsigner and zipalign
Do not forget to set the sdk bin and build-tools directories in the Environment PATH Variable