//
//  DecorationEntityProtocol.swift
//  BlockyModes
//
//  Created by KiBen Hung on 2018/1/14.
//  Copyright © 2018年 SandboxOL. All rights reserved.
//

import Foundation

protocol DecorationEntityProtocol {
    var typeID: Int {get}
    var resourceID: String {get}
    var thumbnailURLString: String {get}
}


struct DecorationEntityHelper {
    
    private enum ClothesSubCategroy: Int {
        case jacket = 8 // 上衣
        case pants = 9 // 裤子
        case shoes = 10 // 鞋子
    }
    
    private enum AccessorySubCategory: Int {
        case hairAccessory = 11 // 发饰
        case faceAccessory = 12 // 面饰
        case shoulderAccessory = 13 // 肩饰
        case backAccessory = 14 // 背饰
    }
    
    private let clothesImages = [R.image.decoration_jacket()!, R.image.decoration_pants()!, R.image.decoration_shoes()!]
    private let accessoryImages = [R.image.decoration_headwear()!, R.image.decoration_facing()!, R.image.decoration_epaulet()!, R.image.decoration_bags()!]
    
//    // 根据装饰图片URL，找到对应的装饰
    public func fetchDecoration<T: DecorationEntityProtocol>(ofThumbnailURLString URLString: String, inSubcategoryDecorationDict dict: [Int : T]) -> T? {
        for (_, decoration) in dict {
            if URLString == decoration.thumbnailURLString {
                return decoration
            }
        }
        return nil
    }
    
    // 获取当前装饰的图片URL链接
    // 返回 相应的内容 跟 悬浮view 对应位置的索引
    public func decorationThumbnailURLStringContent<T: DecorationEntityProtocol>(_ decoration: T, completion: @escaping ((Any, Int)) -> Void) {
        decorationThumbnailContent(decoration, isDefault: false, completion: completion)
    }
    
    // 获取当前装饰的默认占位图片
    // 返回 相应的内容 跟 悬浮view 对应位置的索引
    public func decorationThumbnailDefaultContent<T: DecorationEntityProtocol>(_ decoration: T, completion: @escaping ((Any, Int)) -> Void) {
        decorationThumbnailContent(decoration, isDefault: true, completion: completion)
    }
    
    // 获取在装饰分类页切换时，左上角悬浮view的数据
    public func decorationThumbnailContents<T: DecorationEntityProtocol>(inCategory category: Int, forSubcategoryDecorationDict decorationDict: [Int : T], completion: @escaping ([Any]) -> Void) {
        switch category {
        case 1:
            clothesSubcategoryThumbnailContents(subcategoryDecorationDict: decorationDict, completion: completion)
        case 3:
            accessorySubcategoryThumbnailContents(subcategoryDecorationDict: decorationDict, completion: completion)
        default:
            completion([])
        }
    }
    
    private func clothesSubcategoryThumbnailContents<T: DecorationEntityProtocol>(subcategoryDecorationDict decorationDict: [Int : T], completion: @escaping ([Any]) -> Void) {
        
        var contents: [Any] = []
        let subcategories = [ClothesSubCategroy.jacket, ClothesSubCategroy.pants, ClothesSubCategroy.shoes]
        for (index,subcategory) in subcategories.enumerated() {
            if let decoration = decorationDict[subcategory.rawValue] {
                contents.append(decoration.thumbnailURLString)
            }else {
                contents.append(clothesImages[index])
            }
        }
        completion(contents)
    }
    
    private func accessorySubcategoryThumbnailContents<T: DecorationEntityProtocol>(subcategoryDecorationDict decorationDict: [Int : T], completion: @escaping ([Any]) -> Void) {
        var contents: [Any] = []
        let subcategories = [AccessorySubCategory.hairAccessory, AccessorySubCategory.faceAccessory, AccessorySubCategory.shoulderAccessory, AccessorySubCategory.backAccessory]
        
        for (index,subcategory) in subcategories.enumerated() {
            if let decoration = decorationDict[subcategory.rawValue] {
                contents.append(decoration.thumbnailURLString)
            }else {
                contents.append(accessoryImages[index])
            }
        }
        completion(contents)
    }
    
    private func decorationThumbnailContent<T: DecorationEntityProtocol>(_ decoration: T, isDefault: Bool, completion: @escaping ((Any, Int)) -> Void) {
        switch decoration.typeID {
        case ClothesSubCategroy.jacket.rawValue:
            return isDefault ? completion((clothesImages[0], 0)) : completion((decoration.thumbnailURLString, 0))
        case ClothesSubCategroy.pants.rawValue:
            return isDefault ? completion((clothesImages[1], 1)) : completion((decoration.thumbnailURLString, 1))
        case ClothesSubCategroy.shoes.rawValue:
            return isDefault ? completion((clothesImages[2], 2)) : completion((decoration.thumbnailURLString, 2))
        case AccessorySubCategory.hairAccessory.rawValue:
            return isDefault ? completion((accessoryImages[0], 0)) : completion((decoration.thumbnailURLString, 0))
        case AccessorySubCategory.faceAccessory.rawValue:
            return isDefault ? completion((accessoryImages[1], 1)) : completion((decoration.thumbnailURLString, 1))
        case AccessorySubCategory.shoulderAccessory.rawValue:
            return isDefault ? completion((accessoryImages[2], 2)) : completion((decoration.thumbnailURLString, 2))
        case AccessorySubCategory.backAccessory.rawValue:
            return isDefault ? completion((accessoryImages[3], 3)) : completion((decoration.thumbnailURLString, 3))
        default:
            break
        }
    }
}
