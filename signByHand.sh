
#!/bin/sh

if ! ([ -f "$1" ]); then
echo \"${1}\"文件不存在
exit
fi
ipaName=${1%.ipa}
if [ "$ipaName" = "$1" ]; then
echo \"${1}\"不是ipa文件
exit
fi

## step 1, unzip ipa file
unzip ${ipaName}.ipa

## step 2, remove old codesign
rm -rf Payload/*.app/_CodeSignature/

## step 3, copy new provision profile
cp 123.mobileprovision Payload/*.app/embedded.mobileprovision

## step 4, codesign with new certificate and provision
(/usr/bin/codesign -f -s "iPhone Developer: XXXXX (XXX)" --resource-rules Payload/*.app/ResourceRules.plist Payload/*.app/) || {
## if code sign error, will to here
echo failed
rm -rf Payload/
exit
}

## step 5, zip it
zip -r ${ipaName}abc.ipa Payload/
rm -rf Payload/