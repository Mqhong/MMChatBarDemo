//
//  MMFaceManager.swift
//  Swift表情输入框
//
//  Created by mm on 16/3/9.
//  Copyright © 2016年 mm. All rights reserved.
//

import UIKit

class MMFaceManager: NSObject {
    
    var emojiFaceArrays:NSMutableArray = NSMutableArray()
    var recentFaceArrays:NSMutableArray = NSMutableArray()
    
    
    override init() {
        super.init()
        
        let faceArray = NSArray(contentsOfFile: NSBundle.mainBundle().pathForResource("face", ofType: "plist")!)
        
//        print("faceArray:\(faceArray)")
        
        self.emojiFaceArrays.addObjectsFromArray(faceArray! as [AnyObject])
        
//        print("self.emojiFaceArrays:\(self.emojiFaceArrays)")
        
    }
    
    
    
    func emotionStrWithString(text:String)->NSMutableAttributedString{
        
        print("进入表情判断方法")
        
        //1.创建一个可变的属性字符串
        var  attributeString:NSMutableAttributedString = NSMutableAttributedString(string: text)
        
        
        
        do{
            //2.通过正则表达式来匹配字符串
            let regex_emoji = "\\[[a-zA-Z0-9\\/\\u4e00-\\u9fa5]+\\]"//匹配表情
            let re =  try!NSRegularExpression(pattern: regex_emoji, options: .CaseInsensitive)
            
            let resultArray = re.matchesInString(text, options: NSMatchingOptions(rawValue: 0), range: NSMakeRange(0, text.characters.count))
            
            print("resultArray:\(resultArray)")
            
            for match in resultArray{
                //获取数组元素中得到range
                let range:NSRange = match.range
                
                //获取元字符串中对应的值
                var subStr:String = (text as NSString).substringWithRange(range)
                
                print("subStr:\(subStr)")
                for dict in self.emojiFaceArrays{
//                    print("subStr:\(subStr) dict：\(dict)")
                }
                
            }
            
            
            
        }catch{
            print(error)
        }
        
        return attributeString
        
    }
}
