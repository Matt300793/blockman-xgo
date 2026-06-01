#!/bin/bash

now=$(date +"%Y-%m-%d")
ipa_path="/Users/Shared/Jenkins/Home/workspace/BlockyMods/BlockyModsArchive/BlockyMods_${now}/BlockyMods.ipa"

fastlane deliver --ipa ${ipa_path} --submit_for_review

