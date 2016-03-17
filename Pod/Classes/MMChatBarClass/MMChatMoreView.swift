//
//  MMChatMoreView.swift
//  Swift表情输入框
//
//  Created by mm on 16/3/11.
//  Copyright © 2016年 mm. All rights reserved.
//

import UIKit

class MMChatMoreView: UIView {

    /*
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect) {
        // Drawing code
    }
    */
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.frame = CGRectMake(0, 0, UIScreen.mainScreen().bounds.size.width, UIScreen.mainScreen().bounds.size.height*0.4)
        self.backgroundColor = UIColor.blackColor()
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }


}
