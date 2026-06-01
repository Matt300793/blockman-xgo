//
//  AppUpdateModel.swift
//  BlockyModes
//
//  Created by KiBen on 2017/12/28.
//  Copyright © 2017年 SandboxOL. All rights reserved.
//

import Foundation

/*
"isForceUpdate": true,
"version": "2.0.0",
"thumbnailURL": "http://static.sandboxol.cn/games/images/g1002.空岛战争.1511409259996.png",
"downloadURL": "itms-apps://itunes.apple.com/cn/app/blockman-multiplayer-for-mcpe/id1124794039?mt=8&uo=4",
"forcibleUpdateMsg": {
    "en_US": "Dear Blockman player:\nIn order to improve the game experience and the compatibility between different versions, we decided to update the v2.2.0 version and verdion below v2.2.0, please go to AppStore to download the updated version. Sorry for the inconvenience.",
    "zh_CN": "Dear Blockman player:\nIn order to improve the game experience and the compatibility between different versions, we decided to update the v2.2.0 version and verdion below v2.2.0, please go to AppStore to download the updated version. Sorry for the inconvenience.",
    "zh_TW": "Dear Blockman player:\nIn order to improve the game experience and the compatibility between different versions, we decided to update the v2.2.0 version and verdion below v2.2.0, please go to AppStore to download the updated version. Sorry for the inconvenience.",
    "ja_JP": "Dear Blockman player:\nIn order to improve the game experience and the compatibility between different versions, we decided to update the v2.2.0 version and verdion below v2.2.0, please go to AppStore to download the updated version. Sorry for the inconvenience.",
    "ru_RU": "Dear Blockman player:\nIn order to improve the game experience and the compatibility between different versions, we decided to update the v2.2.0 version and verdion below v2.2.0, please go to AppStore to download the updated version. Sorry for the inconvenience.",
    "ko_KR": "Dear Blockman player:\nIn order to improve the game experience and the compatibility between different versions, we decided to update the v2.2.0 version and verdion below v2.2.0, please go to AppStore to download the updated version. Sorry for the inconvenience."
},
"updateContent": {
    "en_US": "2.0.0更新内容\n1.Add mailbox.\n2.Support visitors check profile.\n3.Snowball Battle support Team Mode.\n4.Fix bugs.",
    "zh_CN": "2.0.0更新内容\n1.增加收件箱.\n2.支持游客查看个人详情.\n3.雪球大战支持组队模式.\n4.修复bugs.",
    "zh_TW": "2.0.0更新内容\n1.增加收件箱.\n2.支持遊客查看個人詳情.\n3.雪球大戰支持組隊模式.\n4.修復bugs.",
    "ja_JP": "2.0.0更新内容\n1.増加受信箱.\n2.サポート観光客の個人の詳しい詳しいことを支持します.\n3.の雪の大戦はPTのモードを支持する.\n4.修復bugs.",
    "ru_RU": "2.0.0更新内容\n1.Add mailbox.\n2.Support visitors check profile.\n3.Snowball Battle support Team Mode.\n4.Fix bugs.",
    "ko_KR": "2.0.0更新内容\n1.증가 받은 편지함.\n2.지원 관광객 개인 정보 보기.\n3.눈덩이 대전 지원 팀 모드.\n4.복구 bugs."
},
"minAvailableVersion": "1.0.2"
"needToForceUpdateVersions":["1.0.6", "1.1.1"]
*/

class AppUpdateModel: BaseModel {
    var isForceUpdate: Bool?
    var version: String?
    var thumbnailURL: String?
    var downloadURL: String?
    var updateContent: [String : String]?
    var minAvailableVersion: String?
    var needToForceUpdateVersions: [String]?
}
