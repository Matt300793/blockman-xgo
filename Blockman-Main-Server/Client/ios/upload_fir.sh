#!/bin/bash

#更新timeout
export FASTLANE_XCODEBUILD_SETTINGS_TIMEOUT=120

#计时
SECONDS=0

now=$(date +"%Y-%m-%d")
ipa_path="/Users/Shared/Jenkins/Home/workspace/BlockyMods/BlockyModsArchive/BlockyMods_${now}/BlockyMods.ipa"

#上传到fir
fir publish ${ipa_path} -T 7e63326b9ac1e5a38588831fce1b1a91 -Q true

#输出总用时
echo "-----Finished. Total time: ${SECONDS}s -----"
