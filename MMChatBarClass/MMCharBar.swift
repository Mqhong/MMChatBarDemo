//
//  MMCharBar.swift
//  Swift表情输入框
//
//  Created by mm on 16/3/11.
//  Copyright © 2016年 mm. All rights reserved.
//

import UIKit
import MapKit

public enum MMFunctionViewShowType:Int{
    case MMFunctionViewShowNothing = 0 //不显示functionView
    case MMFunctionViewShowFace = 1//显示表情
    case MMFunctionViewShowVoice = 2//显示录音
    case MMFunctionViewShowMore = 3//显示更多
    case MMFunctionViewShowKeyboard = 4 //显示键盘
}

let kFunctionViewHeight:CGFloat = 210.0
let kMaxHeight:CGFloat = 60.0
let kMinHeight:CGFloat = 45.0


/**
 *  MMChatBar代理事件，发送图片，地理位置，文字，语音信息等
 */
@objc protocol MMChatBarDelegate:NSObjectProtocol{
    /**
     charbarFrame 改变回调
     
     :param: chatBar
     :param: frame
     */
    optional func chatBar_Frame_DidChange(chatBar:MMCharBar, frame:CGRect)
    
    /**
     发送图片信息，支持多张图片
     
     :param: charBar
     :param: pictures 需要发送的图片信息
     */
    optional func chatBar_Send_Pictures(charBar:MMCharBar,PictureArr pictures:NSArray)
    
    /**
     发送地理位置信息
     
     :param: locationCoordinate 需要发送的地址位置经纬度
     :param: locationtext       需要发送的地址位置对应信息
     */
    optional func chatBar_Send_Location(charBar:MMCharBar,locationCoordinate:CLLocationCoordinate2D,locationText locationtext:String)
    
    
    /**
     发送普通的文字信息，可能带有表情
     
     :param: message 需要发送的文字信息
     */
    optional func charBar_Send_Message(charBar:MMCharBar,Message message:String)
    
    
    /**
     发送语音信息
     
     :param: voiceFileName 语音data数据
     :param: seconds       语音时长
     */
    optional func charBar_SendVoice(charBar:MMCharBar,VoiceFileName voiceFileName:String,Seconds seconds:NSTimeInterval)
    
}


public class MMCharBar: UIView,UITextViewDelegate{
//    UITextViewDelegate,UINavigationControllerDelegate,UIImagePickerControllerDelegate,Mp3RecorderDelegate,XMChatMoreViewDelegate,XMChatMoreViewDataSource,XMChatFaceViewDelegate,XMLocationControllerDelegat
    
    var superViewHeight:CGFloat = 0.0
    weak var delegate : MMChatBarDelegate?
    
//    var MP3:Mp3Recorder
    let voiceButton = UIButton()//切换录音模式按钮
    let voiceRecordButton = UIButton() //录音按钮
    
    let faceButton = UIButton()//表情按钮
    let moreButton = UIButton()//更多按钮
    let faceView = MMChatFaceView()//当前活跃的底部view，用来指向faceView
    let moreView = MMChatMoreView()//用来指向moreView
    let textView = UITextView()
    var bottomHeight:CGFloat = 0.0
    var rootViewController = UIViewController()
    var keyboardFrame:CGRect = CGRect()
    var inputText = String()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self._init()
        self.setup()
    }

    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK:_initChatBar
    
    func _init(){
        
        let topLine = UIImageView()
        topLine.backgroundColor = UIColor(red: 235/255.0, green: 236/255.0, blue: 238/255.0, alpha: 1.0)
//        topLine.backgroundColor = UIColor.lightGrayColor()
        topLine.frame =  CGRectMake(0, 0 , self.frame.size.width, self.frame.size.height)
        self.addSubview(topLine)
        
        
        
        //_faceview
//        faceView = MMChatFaceView()
        faceView.frame = CGRectMake(0, self.superViewHeight, self.frame.size.width, kFunctionViewHeight)
//        faceView.delegate = self
//        faceView.backgroundColor = self.backgroundColor
        
        //moreView
        moreView.frame = CGRectMake(0, self.superViewHeight, self.frame.size.width, kFunctionViewHeight)
//        moreView.delegate = self
//        moreView.dataSource = self
//        moreView.backgroundColor = self.backgroundColor
        
        //textView
        textView.font = UIFont.systemFontOfSize(16)
        textView.delegate = self
        textView.layer.cornerRadius = 4.0
        textView.layer.borderColor = UIColor(red: 204/255.0, green: 204/255.0, blue: 204/255.0, alpha: 1).CGColor
        textView.returnKeyType = UIReturnKeyType.Send
        textView.layer.borderWidth = 0.5
        textView.layer.masksToBounds  = true
//        textView.frame
        
        
        //voiceButton
        voiceButton.tag = 2
        voiceButton.setBackgroundImage(UIImage(named: "chat_bar_voice_normal"), forState: .Normal)
        voiceButton.setBackgroundImage(UIImage(named: "chat_bar_input_normal"), forState: .Selected)
        voiceButton.addTarget(self, action: "buttonAction:", forControlEvents: .TouchUpInside)
        voiceButton.sizeToFit()
        
        //voiceRecordButton
        voiceRecordButton.hidden = true
        
        voiceRecordButton.autoresizingMask = [.FlexibleWidth,.FlexibleHeight]
        voiceRecordButton.backgroundColor = UIColor.lightGrayColor()
        voiceRecordButton.titleLabel?.font = UIFont.systemFontOfSize(14)
        voiceRecordButton.setTitle("按住录音", forState: .Normal)
        
//        [_voiceRecordButton addTarget:self action:@selector(startRecordVoice) forControlEvents:UIControlEventTouchDown];
//        [_voiceRecordButton addTarget:self action:@selector(cancelRecordVoice) forControlEvents:UIControlEventTouchUpOutside];
//        [_voiceRecordButton addTarget:self action:@selector(confirmRecordVoice) forControlEvents:UIControlEventTouchUpInside];
//        [_voiceRecordButton addTarget:self action:@selector(updateCancelRecordVoice) forControlEvents:UIControlEventTouchDragExit];
//        [_voiceRecordButton addTarget:self action:@selector(updateContinueRecordVoice) forControlEvents:UIControlEventTouchDragEnter];
        
        //moreButton
        moreButton.tag = 3
        moreButton.setBackgroundImage(UIImage(named: "chat_bar_more_normal"), forState: .Normal)
        moreButton.setBackgroundImage(UIImage(named: "chat_bar_input_normal"), forState: .Selected)
        moreButton.addTarget(self, action: "buttonAction:", forControlEvents: .TouchUpInside)
        moreButton.sizeToFit()
        
        //faceButton
        faceButton.tag = 1
        faceButton.setBackgroundImage(UIImage(named: "chat_bar_face_normal"), forState: .Normal)
        faceButton.setBackgroundImage(UIImage(named: "chat_bar_input_normal"), forState: .Selected)
        faceButton.addTarget(self, action: "buttonAction:", forControlEvents: .TouchUpInside)
        faceButton.sizeToFit()
        
        
        //设置位置
        self.voiceButton.frame.origin = CGPointMake(15, (self.bounds.size.height - self.voiceButton.bounds.size.height)*0.5)
        
        let textvieww = self.frame.width -  15 * 5 - self.voiceButton.frame.size.width - self.faceButton.frame.width - self.moreButton.frame.width
        
        self.textView.frame = CGRectMake(CGRectGetMaxX(self.voiceButton.frame)+15, self.frame.height*0.1, textvieww, self.frame.height*0.8)
        
        self.voiceRecordButton.frame = CGRectMake(0, 0, textvieww, self.frame.height*0.8)
        
        self.faceButton.frame.origin = CGPointMake(CGRectGetMaxX(self.textView.frame)+15, (self.bounds.height - self.faceButton.bounds.height)*0.5)
        
        self.moreButton.frame.origin = CGPointMake(CGRectGetMaxX(self.faceButton.frame)+15, (self.bounds.height - self.faceButton.bounds.height)*0.5)
        self.textView.backgroundColor = UIColor.whiteColor()
        
        //bottomHeight
//        if(self.faceView.superview == nil || self.moreButton.superview == nil){
//            self.bottomHeight = max(self.keyboardFrame.size.height, max(self.faceView.frame.size.height, self.moreButton.frame.size.height))
//        }else{
//            print("CGFloat(DBL_MIN):\(CGFloat(DBL_MIN))")
//            self.bottomHeight = self.keyboardFrame.size.height
////                max(self.keyboardFrame.size.height, CGFloat(DBL_MIN))
//        }
//        print("self.bottomHeight:\(self.bottomHeight)")
        //rootViewController
//        self.rootViewController = (UIApplication.sharedApplication().keyWindow?.rootViewController)!
        
    }
    
    
    //MARK:UITextViewDelegate
//    public func textViewDidChange(textView:UITextView) {
//        
//        var textviewFrame = self.textView.frame
//        let textSize = self.textView.sizeThatFits(CGSizeMake(CGRectGetWidth(textviewFrame), 1000))
//        let offset:CGFloat = 10
////        print("\(__FUNCTION__)")
//        textView.scrollEnabled = (textSize.height + 0.1 > kMaxHeight - offset)
//        textviewFrame.size.height = max(34, min(kMaxHeight, textSize.height))
//        
//        var addBarFrame:CGRect = self.frame
//        addBarFrame.size.height = textviewFrame.size.height + offset
//        addBarFrame.origin.y = self.superViewHeight - self.bottomHeight - addBarFrame.size.height
//        self.setFrame(Frme: addBarFrame, Animated: false)
//        
//        if(textView.scrollEnabled){
//            textView.scrollRangeToVisible(NSMakeRange(textView.text.characters.count - 2, 1))
//        }
//        
//    }
    
    
    public func textViewDidChange(textView: UITextView) {
        print("textview:\(textView.text)")
    }
    
    
    
    public func textView(textView: UITextView, shouldChangeTextInRange range: NSRange, replacementText text: String) -> Bool {
        if text == "\n"{
            self.delegate?.charBar_Send_Message!(self, Message: textView.text)
            return false
        }
        return true
    }
    //MARK:- public Methods
    
    /**
    结束输入状态
    */
    public func endInputing(){
        self.showViewWithType(.MMFunctionViewShowNothing)
        
    }
    
    //MARK:- private Methods
    
    func keyboardWillHide(notification:NSNotification){
        
        self.keyboardFrame =  (notification.userInfo![UIKeyboardFrameEndUserInfoKey]?.CGRectValue)!
        print("self.faceButton.selected:\(self.faceButton.selected)")
        if(!self.faceButton.selected && !self.moreButton.selected){
            print("self.frame.height:\(self.frame.height)")
            let keyboardf = CGRectMake(0, self.superViewHeight - kMinHeight, self.keyboardFrame.width, kMinHeight)
            self.setFrame(Frme: keyboardf, Animated: true)
        }
    }
    
    
    func keyboardFrameWillChange(notification:NSNotification){
        self.moreButton.selected = false
        self.faceButton.selected = false
        self.keyboardFrame = (notification.userInfo![UIKeyboardFrameEndUserInfoKey]?.CGRectValue)!
        if(!self.faceButton.selected && !self.moreButton.selected){
            let keyboardf = CGRectMake(0, self.keyboardFrame.origin.y - self.frame.height, self.keyboardFrame.width, self.keyboardFrame.height)
            self.showViewWithType(.MMFunctionViewShowKeyboard)
            self.setFrame(Frme: keyboardf, Animated: true)
        }
        print(self.keyboardFrame)
//        self.textViewDidChange(self.textView)

    }
    
    func setup(){
//       self. mp3 = Mp3Recorder alloc initwithDelegate:self
        self.addSubview(self.voiceButton)
        self.addSubview(self.moreButton)
        self.addSubview(self.faceButton)
        self.addSubview(self.textView)
        self.textView.addSubview(self.voiceRecordButton)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillHide:", name: UIKeyboardWillHideNotification, object: nil)

        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardFrameWillChange:", name: UIKeyboardWillShowNotification, object: nil)
//        UIKeyboardWillChangeFrameNotification
    }
    

    func showViewWithType(showType:MMFunctionViewShowType){
        
        //显示对应的View
        self.showMoreView(showType == .MMFunctionViewShowMore && self.moreButton.selected)
        self.showVoicView(showType == .MMFunctionViewShowVoice && self.voiceButton.selected)
        self.showFaceView(showType == .MMFunctionViewShowFace && self.faceButton.selected)
        
        switch(showType){
        case .MMFunctionViewShowNothing,.MMFunctionViewShowVoice:
            self.inputText = self.textView.text
            self.setFrame(Frme: CGRectMake(0, self.superViewHeight - kMinHeight, self.frame.size.width, kMinHeight), Animated: false)
            self.textView.resignFirstResponder()
            break
            
        case .MMFunctionViewShowMore,.MMFunctionViewShowFace:
            self.inputText = self.textView.text
            let showframe = CGRectMake(0, self.superViewHeight - kFunctionViewHeight - self.textView.frame.size.height - 10, self.frame.size.width, self.textView.frame.size.height + 10)
            self.setFrame(Frme: showframe, Animated: false)
            self.textView.resignFirstResponder()
//            self.textViewDidChange(self.textView)
            break
            
        case .MMFunctionViewShowKeyboard:
            self.textView.text = self.inputText
//            self.textViewDidChange(self.textView)
//            self.inputText = ""
        }
    }
    
    /**
     更改对应按钮的状态
     
     :param: button 对应的按钮
     */
    func buttonAction(button:UIButton){
        self.inputText = self.textView.text
        var showType:MMFunctionViewShowType = MMFunctionViewShowType(rawValue: button.tag)!
        
        print("showType:\(showType)")
        
        //更改度一应按钮的状态
        if(button == self.faceButton){
            self.faceButton.selected = !self.faceButton.selected
            self.moreButton.selected = false
            self.voiceButton.selected = false
        }else if(button == self.moreButton){
            self.faceButton.selected = false
            self.moreButton.selected = !self.moreButton.selected
            self.voiceButton.selected = false
        }else if(button == self.voiceButton){
            self.faceButton.selected = false
            self.moreButton.selected = false
            self.voiceButton.selected = !self.voiceButton.selected
        }
        if(!button.selected){
            showType = MMFunctionViewShowType.MMFunctionViewShowKeyboard
            self.textView .becomeFirstResponder()
        }else{
            self.inputText = self.textView.text
        }
        self.showViewWithType(showType)
        
    }
    
    func showFaceView(show:Bool){
        
        self.faceButton.selected = show
        
        if(show){
            self.superview?.addSubview(self.faceView)
            
            self.faceView.frame = CGRectMake(0, self.superViewHeight,  self.frame.size.width, 0)
            
            UIView.animateWithDuration(0.25, animations: { () -> Void in
                
            self.faceView.frame = CGRectMake(0, self.superViewHeight - kFunctionViewHeight, self.frame.size.width, kFunctionViewHeight)
                
                }, completion: nil)
            
        }else{
            UIView.animateWithDuration(0.15, animations: { () -> Void in
                
                self.faceView.frame = CGRectMake(0, self.superViewHeight, self.frame.size.width, kFunctionViewHeight)
                
                }, completion: { (finished:Bool) -> Void in
                    self.faceView.removeFromSuperview()
            })
        }
    }

    
    /**
     显示moreView
     
     :param: show 要显示的moreView
     */
    func showMoreView(show:Bool){
        
        self.moreButton.selected = show
        
        if(show){
            self.superview?.addSubview(self.moreView)
            
            self.moreView.frame = CGRectMake(0, self.superViewHeight,  self.frame.size.width, 0)

            UIView.animateWithDuration(0.25, animations: { () -> Void in
                self.moreView.frame = CGRectMake(0, self.superViewHeight - kFunctionViewHeight, self.frame.size.width, kFunctionViewHeight)
            })
        }else{
            UIView.animateWithDuration(0.15, animations: { () -> Void in
                 self.moreView.frame = CGRectMake(0, self.superViewHeight, self.frame.size.width, kFunctionViewHeight)
                }, completion: { (finished:Bool) -> Void in
                    self.moreView.removeFromSuperview()
            })
        }
    }
    
    func showVoicView(show:Bool){
        self.voiceButton.selected = show
        self.voiceRecordButton.selected = show
        self.voiceRecordButton.hidden = !show
    }
    
    func setFrame(Frme frame:CGRect,Animated animated:Bool){
        if(animated){
            UIView.animateWithDuration(0.3, animations: { () -> Void in
                self.frame = frame
                })
        }else{
            self.frame = frame
        }
            self.delegate?.chatBar_Frame_DidChange!(self, frame: frame)
    }
    
    public override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        print("点击了chatbar")
    }
    
     deinit{
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardWillChangeFrameNotification, object: nil)
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardWillHideNotification, object: nil)
        
    }
    
    /*
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect) {
        // Drawing code
    }
    */

}
