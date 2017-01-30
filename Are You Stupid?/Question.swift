//
//  Question.swift
//  Are You Stupid?
//
//  Created by Sai Tadikonda on 10/24/15.
//  Copyright (c) 2015 TadCorp. All rights reserved.
//

import UIKit

class Question: NSObject {
    
    var questionText:String = ""
    var answers:[String] = [String]()
    var correctAnswerIndex:Int = 0
    var module: Int = 0
    var lesson: Int = 0
    var feedback:String = ""
    
}