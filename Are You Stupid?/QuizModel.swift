//
//  QuizModel.swift
//  Are You Stupid?
//
//  Created by Sai Tadikonda on 10/24/15.
//  Copyright (c) 2015 TadCorp. All rights reserved.
//


import UIKit

class QuizModel: NSObject {
    
    func getQuestions() -> [Question] {
        
        //Array of Question objects
        var questions:[Question] = [Question]()
        
        //Get JSON array of dictionaries
        let jsonObjects:[NSDictionary] = self.getLocalJsonFile()
        
        var index:Int
        for index = 0 ; index < jsonObjects.count ; index++ {
            
            //Current JSON Dict
            let jsonDictionary:NSDictionary = jsonObjects[index]
            
            //Creates Question object
            var q:Question = Question()
            
            // Assign the values of each key value pair to the question object
            q.questionText = jsonDictionary["question"] as! String
            q.answers = jsonDictionary["answers"] as! [String]
            q.correctAnswerIndex = jsonDictionary["correctIndex"] as! Int
            q.module = jsonDictionary["module"] as! Int
            q.lesson = jsonDictionary["lesson"] as! Int
            q.feedback = jsonDictionary["feedback"] as! String
            
            //Add the question to the question array
            questions.append(q)
        }
        
        //Loop through dictionary
        
        return questions
    }
    
    func getLocalJsonFile() -> [NSDictionary] {
        
        //Get an NSURL object pointing to the JSON file in our app bundle
        let appBundlePath:String? = NSBundle.mainBundle().pathForResource("QuestionData", ofType: "json")
        
        //Use optional binding to see if path exists
        if let actualBundlePath = appBundlePath {
            //Bundle path exists
            let urlPath:NSURL? = NSURL(fileURLWithPath: actualBundlePath)
            
            //
            if let actualUrlPath = urlPath {
                //NSURL object was created
                let jsonData:NSData? = NSData(contentsOfURL: actualUrlPath)
                
                if let actualJsonData = jsonData {
                    
                    //NSData exists, use the NSJSONSerialization classes to parse the data and create dictionary/arrays
                    let arrayOfDictionaries:[NSDictionary]? = NSJSONSerialization.JSONObjectWithData(actualJsonData, options: NSJSONReadingOptions.MutableContainers, error: nil) as! [NSDictionary]?
                    
                    if let actualArrayOfDictionaries = arrayOfDictionaries {
                        //Return dictionaries
                        return actualArrayOfDictionaries
                    }
                    else {
                        //Parsed out nil
                    }
                }
                    
                else {
                    //NSdata does not exist
                }
            }
            else {
                //NSURL object was not created
            }
        }
        else {
            //Path to JSON file doesn't exist
        }
        return [NSDictionary]()
    }
}

