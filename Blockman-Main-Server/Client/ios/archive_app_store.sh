#!/bin/bash

#更新timeout
export FASTLANE_XCODEBUILD_SETTINGS_TIMEOUT=120

#计时
SECONDS=0

#脚本在项目文件的路径下
project_path="$(dirname "$(pwd)")"
#取当前时间字符串添加到文件结尾
now=$(date +"%Y-%m-%d")

#指定项目scheme名称
scheme="BlockyModes_Oversea"
#指定打包的配置名
configuration="Release"
#指定打包所使用的输出方式，目前支持app-store, package, ad-hoc, enterprise, development, 和developer-id，即xcodebuild的method参数
export_method="app-store"

#上述scheme/target/configuration若不清楚值可以用`xcodebuild -list`查看

#指定项目地址
workspace_path="$project_path/ios/BlockyModes/BlockyModes.xcworkspace"
#指定输出路径
output_path="/Users/Shared/Jenkins/Home/workspace/BlockyMods/BlockyModsArchive/BlockyMods_${now}"
#指定输出归档文件地址
archive_path="$output_path/BlockyMods.xcarchive"
#指定输出ipa名称
ipa_name="BlockyMods.ipa"
#指定输出ipa地址
ipa_path="$output_path/${ipa_name}"
#获取执行命令时的commit message
commit_msg="$1"

#输出设定的变量值
echo "---workspace path: ${workspace_path}---"
echo "---archive path: ${archive_path}---"
echo "---ipa path: ${ipa_path}---"
echo "---export method: ${export_method}---"
echo "---commit message: $1---"

#build之前先clean
echo "fastlane gym --workspace ${workspace_path} --scheme ${scheme} --clean --configuration ${configuration} --archive_path ${archive_path} --include_bitcode false --export_method ${export_method} --output_directory ${output_path} --output_name ${ipa_name}"
fastlane gym --workspace ${workspace_path} --scheme ${scheme} --clean --configuration ${configuration} --archive_path ${archive_path} --include_bitcode false --export_method ${export_method} --output_directory ${output_path} --output_name ${ipa_name}

#输出总用时
echo "-----Finished. Total time: ${SECONDS}s -----"


