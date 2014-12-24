#!/usr/bin/env ruby
require 'json'
require 'fileutils'
require 'shellwords'
$version = "1.0.3"
$appName = 'CoolOffice.app'#it's a folder
$releaseIPAPath = "/Users/redhatimac/Documents/github\ clone/egeio\ project/ios/iOS\ projects/CoolOffice/Cooloffice/build/Products/InHouseRelease-iphoneos"
$uploadFolderPath = "/Users/redhatimac/Desktop/uploadIpa"
$uploadIPAPlistPath = "/Users/redhatimac/Desktop/uploadIpa/CoolOffice.plist"
puts '输入你的版本号：'
$buildVersion = gets.chomp

def coverJsonFile(buildVersion)
  
  jsonPath = "#{$uploadFolderPath}/ios.json"
  file = File.read(jsonPath)
  data_hash = JSON.parse(file)
  ipaList = data_hash["data"]
  currentTime = Time.now.strftime("%d/%m/%Y %H:%M")
  ipaList.delete_if{|x| x["build"].eql?("#{buildVersion}")}
  ipaList.insert(0, {"version" => "#{$version}.#{buildVersion}","build"=>"#{buildVersion}","date"=>"#{currentTime}"}) 
  data_hash["data"] = ipaList
  # puts data_hash
  File.open(jsonPath, "w") do  |f|
    f.write(data_hash.to_json)
  end
end


# puts $iTunesIPAPath+"\n" + $uploadFilePath
if File.exist?($releaseIPAPath)
  if !File.exist?("#{$releaseIPAPath}/Payload")
    FileUtils.mkdir("#{$releaseIPAPath}/Payload")
  end

  FileUtils.copy_entry("#{$releaseIPAPath}/#{$appName}", "#{$releaseIPAPath}/Payload/#{$appName}")
  system "zip -r #{$releaseIPAPath.shellescape}/CoolOffice.ipa #{$releaseIPAPath.shellescape}/Payload/"

  uploadFolderWithVersion = "#{$uploadFolderPath}/ios-build-#{$buildVersion}"
  if !File.exists?(uploadFolderWithVersion)
    puts "#{$buildVersion} director not exists, create new one!"
    FileUtils.mkdir(uploadFolderWithVersion)
  end
  puts "start package!"
  FileUtils.copy_file("#{$releaseIPAPath}/CoolOffice.ipa", "#{uploadFolderWithVersion}/CoolOffice.ipa")
  
  coverJsonFile($buildVersion)
  system "plistbuddy -c \"Set :items:0:assets:0:url https://app.fangcloud.com/ios/ios-build-#{$buildVersion}/CoolOffice.ipa\" \"#{$uploadFolderPath}/CoolOffice.plist\""
  
  FileUtils.copy_file($uploadIPAPlistPath, "#{uploadFolderWithVersion}/CoolOffice.plist")
  
  system "cd #{$uploadFolderPath}; tar -czf ios_build.tar.gz ios-build-#{$buildVersion} ios.json"
  exec "scp ios_build.tar.gz root@112.124.70.25:/usr/local/ios"
else
  puts "ipa not exits in ReleaseFolder!"
end




