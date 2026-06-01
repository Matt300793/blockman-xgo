//
//  GamesNetServer.swift
//  BlockyModes
//
//  Created by KiBen on 2017/11/3.
//  Copyright © 2017年 SandboxOL. All rights reserved.
//

import Foundation
import RxSwift
import Moya

class GamesNetServer {
    class func getRecommnedList() -> Single<[String : Any]> {
        return NetServer.requestWithTarget(Games.recommendationList, showToast: false)
    }
    
    class func getRecentlyPlayList() -> Single<[String : Any]> {
        return NetServer.requestWithTarget(Games.recentlyPlayingList, showToast: false)
    }
    
    class func getFriendsPlayList() -> Single<[String : Any]> {
        return NetServer.requestWithTarget(Games.friendsPlayingList, showToast: false)
    }
    
    class func getGameDetailInfo(gameId: String) -> Single<[String : Any]> {
        return NetServer.requestWithTarget(Games.gameDetailInfo(gameId), showToast: false)
    }
    
    class func appreciateGame(gameId: String) -> Single<[String : Any]> {
        return NetServer.requestWithTarget(Games.appreciate(gameId))
    }
    
    class func getCategoryList(category: Int, sortType: String, page: Int) -> Single<[String : Any]> {
        return NetServer.requestWithTarget(Games.categoryList(category, sortType, page), showToast: false)
    }
    
    
    class func fetchGameToken(gameType: String) -> Single<[String : Any]> {
        return NetServer.requestWithTarget(Games.fetchEnterGameToken(gameType), showToast: false).retry(3)
    }
    
    class func enterGame(token: String) -> Single<[String : Any]> {
        return NetServer.requestWithTarget(Games.enterGame(token), showToast: false).do(onNext: { (response) in
            let code = response["code"] as! Int
            if code == 2 {
                throw BlockyError.unKnown
            }
        }).retryWhen({ (error: Observable<BlockyError>) -> Observable<Int> in
            return error.flatMapWithIndex({ (error, index) -> Observable<Int> in
                guard index < 3 else {
                    return Observable.error(error)
                }
                return Observable<Int>.timer(3, scheduler: MainScheduler.instance)
            })
        })
    }
}
