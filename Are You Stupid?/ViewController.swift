//
//  ViewController.swift
//  Are You Stupid?
//
//  Created by Sai Tadikonda on 10/24/15.
//  Copyright (c) 2015 TadCorp. All rights reserved.
//

import UIKit
import AVFoundation
import iAd

class ViewController: UIViewController, ADBannerViewDelegate {
    
    let model:QuizModel = QuizModel()
    var questions:[Question] = [Question]()
    
    @IBOutlet weak var scrollViewContent: UIView!
    @IBOutlet weak var questionLabel: UILabel!
    @IBOutlet weak var moduleLabel: UILabel!
    @IBOutlet weak var Banner: ADBannerView!
    
    var currentQuestion:Question?
    var answerButtonArray:[AnswerButtonView] = [AnswerButtonView]()
    
    //Score keeping
    var numberCorrect:Int = 0
    
    //Background Theme
    var backgroundThemePlayer: AVAudioPlayer?
    
    //Result view IBOutlet properties
    
    @IBOutlet weak var correctLabel: UILabel!
    @IBOutlet weak var feedbackLabel: UILabel!
    @IBOutlet weak var nextButton: UIButton!
    @IBOutlet weak var resultView: UIView!
    @IBOutlet weak var dimView: UIView!
    
    
    @IBOutlet weak var resultViewTopMargin: NSLayoutConstraint!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        //Load Ads
        Banner.hidden = true
        Banner.delegate = self
        self.canDisplayBannerAds=true
        
        //initialize AudioPlayer
        var backgroundThemePlayerURL:NSURL? = NSURL(fileURLWithPath: NSBundle.mainBundle().pathForResource("Lessons", ofType: "mp3")!)
        if(backgroundThemePlayerURL != nil) {
            self.backgroundThemePlayer = AVAudioPlayer(contentsOfURL: backgroundThemePlayerURL!, error: nil)
        }
        
        //Hide the dim and result view
        self.dimView.alpha = 0
        self.resultView.alpha = 0
        
        //Get the questions from the quiz model
        self.questions = self.model.getQuestions()
        
        
        //Check if there is atleast one question
        if(self.questions.count > 0) {
            
            //Set the first question to the current question
            self.currentQuestion = self.questions[0]
            
            //Load state
            self.loadState()
            
            //Call the display question method
            self.displayCurrentQuestion()
        }
    }
    
    func displayCurrentQuestion() {
        self.backgroundThemePlayer!.play()
        
        //Optional Unwrapping to see if it is empty
        if let actualCurrentQuestion = self.currentQuestion {
            
            //Start the question out as invisible
            self.questionLabel.alpha = 0
            self.moduleLabel.alpha = 0
            
            //Update the question text
            self.questionLabel.text = self.currentQuestion?.questionText
            
            //Update the module and lesson
            self.moduleLabel.text = String(format: "Question# %i", self.currentQuestion!.module)
            
            //Reveal the question
            UIView.animateWithDuration(1, delay: 0, options: UIViewAnimationOptions.CurveEaseOut, animations: {
                self.questionLabel.textColor = UIColor.whiteColor()
                self.questionLabel.alpha = 1
                self.moduleLabel.alpha = 1
                }, completion: nil)
            
            //Create and display the answer button views
            self.createAnswerButtons()
            
            //Save state
            self.saveState()
        }
    }
    
    func createAnswerButtons() {
        
        var index: Int
        for( index = 0; index < self.currentQuestion?.answers.count; index++) {
            
            //Create an answer button view
            let answer:AnswerButtonView = AnswerButtonView()
            answer.setTranslatesAutoresizingMaskIntoConstraints(false)
            
            //Place it into the content view
            self.scrollViewContent.addSubview(answer)
            
            //Add a tap gesture recognizer to the button
            let tapGesture:UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: Selector("answerTapped:"))
            answer.addGestureRecognizer(tapGesture)
            
            //add constraints depending on what button it is
            let heightConstraint:NSLayoutConstraint = NSLayoutConstraint(item: answer, attribute: NSLayoutAttribute.Height, relatedBy: NSLayoutRelation.Equal, toItem: nil, attribute: NSLayoutAttribute.NotAnAttribute, multiplier: 1, constant: 100)
            answer.addConstraint(heightConstraint)
            
            let leftMarginConstraint:NSLayoutConstraint = NSLayoutConstraint(item: answer, attribute: NSLayoutAttribute.Left, relatedBy: NSLayoutRelation.Equal, toItem: scrollViewContent, attribute: NSLayoutAttribute.Left, multiplier: 1, constant: 400)
            
            let rightMarginConstraint:NSLayoutConstraint = NSLayoutConstraint(item: answer, attribute: NSLayoutAttribute.Right, relatedBy: NSLayoutRelation.Equal, toItem: scrollViewContent, attribute: NSLayoutAttribute.Right, multiplier: 1, constant: 400)
            
            let topMarginConstraint:NSLayoutConstraint = NSLayoutConstraint(item: answer, attribute: NSLayoutAttribute.Top, relatedBy: NSLayoutRelation.Equal, toItem: scrollViewContent, attribute: NSLayoutAttribute.Top, multiplier: 1, constant: CGFloat(101 * index))
            
            self.scrollViewContent.addConstraints([leftMarginConstraint, rightMarginConstraint, topMarginConstraint])
            
            //set the answer text for it
            let answerText = self.currentQuestion!.answers[index]
            answer.setAnswerText(answerText)
            
            //Set the answer number
            answer.setAnswerNumber(index+1)
            
            //Add it to the button array
            self.answerButtonArray.append(answer)
            
            //Make the buttons slide in
            self.view.layoutIfNeeded()
            
            let slideInDelay:Double = Double(index) * 0.1
            
            UIView.animateWithDuration(1, delay: slideInDelay, options: UIViewAnimationOptions.CurveEaseOut, animations: {
                leftMarginConstraint.constant = 0
                rightMarginConstraint.constant = 0
                self.view.layoutIfNeeded()
                
                }, completion: nil)
        }
        
        //adjust the height of the content veiw if need be
        let contentViewHeight:NSLayoutConstraint = NSLayoutConstraint(item: scrollViewContent, attribute: NSLayoutAttribute.Height, relatedBy: NSLayoutRelation.Equal, toItem: self.answerButtonArray[0], attribute: NSLayoutAttribute.Height, multiplier: CGFloat(self.answerButtonArray.count - 1), constant: 101)
        
        scrollViewContent.addConstraint(contentViewHeight)
    }
    
    func answerTapped(gesture: UITapGestureRecognizer) {
        
        //Get access to the button that was tapped
        let answerButtonThatWasTapped: AnswerButtonView? = gesture.view as! AnswerButtonView?
        
        if let actualButton = answerButtonThatWasTapped {
            //We got the button
            let answerTappedIndex:Int? = find(self.answerButtonArray, actualButton)
            
            if let answerIndex = answerTappedIndex {
                
                //Check to see if the user got it right
                if(answerIndex == self.currentQuestion!.correctAnswerIndex) {
                    
                    //Change result view background color and answer label
                    self.resultView.backgroundColor = UIColor(red: 0, green: 197/255, blue: 0, alpha: 1)
                    self.nextButton.backgroundColor = UIColor(red: 0, green: 85/255, blue: 0, alpha: 1)
                    
                    //User got it right
                    self.correctLabel.text = "Correct"
                    self.numberCorrect++
                }
                else {
                    
                    //Change result view background color and answer label
                    self.resultView.backgroundColor = UIColor(red: 224/255, green: 56/255, blue: 70/255, alpha: 1)
                    self.nextButton.backgroundColor = UIColor(red: 167/255, green: 0, blue: 0, alpha: 1)
                    
                    //User got it wrong
                    self.correctLabel.text = "Incorrect"
                }
                //Set the feedback labeland button text
                self.feedbackLabel.text = self.currentQuestion?.feedback
                self.nextButton.setTitle("Next", forState: UIControlState.Normal)
                
                //Set result view top margin constraint to high value
                self.resultViewTopMargin.constant = 900
                self.view.layoutIfNeeded()
                
                //Display the dim view and the result view and hide the current view
                UIView.animateWithDuration(0.5, animations: {
                    
                    //Set result view top margin constraint to high value
                    self.resultViewTopMargin.constant = 30
                    self.view.layoutIfNeeded()
                    
                    //Fades into view
                    self.dimView.alpha = 1
                    self.resultView.alpha = 1
                })
                
                //Save the state
                self.saveState()
            }
        }
    }
    
    @IBAction func changeQuestion(sender: UIButton) {
        
        //Check if button text is Restart if so restart otherwise go to next question
        if(self.nextButton.titleLabel?.text == "Restart Quiz" && self.questions.count > 0) {
            
            //Reset question to first question
            self.currentQuestion = self.questions[0]
            self.displayCurrentQuestion()
            
            //Remove the dim view and result view
            self.dimView.alpha = 0
            self.resultView.alpha = 0
            
            //Reset number correct
            self.numberCorrect = 0
            
            return
        }
        
        //Dismiss result view
        self.dimView.alpha = 0
        self.resultView.alpha = 0
        
        //Erase the previous text
        self.questionLabel.text = ""
        self.moduleLabel.text = ""
        
        //Remove all the answer button views
        for button in self.answerButtonArray {
            button.removeFromSuperview()
        }
        
        //Remove all buttons from button array
        self.answerButtonArray.removeAll(keepCapacity: false)
        
        //Finding current index of question
        let indexOfCurrentQuestion:Int? = find(self.questions,self.currentQuestion!)
        
        //Finding the current index of the question
        if let actualCurrentIndex = indexOfCurrentQuestion {
            
            //Found the index advance the index
            let nextQuestionIndex = actualCurrentIndex + 1
            
            //Check to make sure next question is in the array
            if(nextQuestionIndex < self.questions.count) {
                //Display next question
                self.currentQuestion = self.questions[nextQuestionIndex]
                self.displayCurrentQuestion()
            }
            else {
                //No more questions end the quiz
                
                //Change the background colors
                self.resultView.backgroundColor = UIColor.grayColor()
                self.nextButton.backgroundColor = UIColor.darkGrayColor()
                
                //Change the label texts
                self.correctLabel.text = "Quiz Finished"
                self.feedbackLabel.text = String(format: "Your score : %i/%i ", self.numberCorrect, self.questions.count)
                self.nextButton.setTitle("Restart Quiz", forState: UIControlState.Normal)
                
                //Display the final view
                self.dimView.alpha = 1
                self.resultView.alpha = 1
            }
        }
    }
    
    func eraseState() {
        
        let userDefaults: NSUserDefaults = NSUserDefaults.standardUserDefaults()
        userDefaults.setInteger(0, forKey: "numberCorrect")
        userDefaults.setInteger(0, forKey: "questionIndex")
        userDefaults.setInteger(0, forKey: "resultViewAlpha")
        userDefaults.setObject("", forKey: "resultTitle")
        
        userDefaults.synchronize()
    }
    
    func saveState() {
        
        let userDefaults:NSUserDefaults = NSUserDefaults.standardUserDefaults()
        
        //Save the current score and current question index and whether or not the result view is visible
        userDefaults.setInteger(numberCorrect, forKey: "numberCorrect")
        
        //Finding current index of question
        let indexOfCurrentQuestion:Int? = find(self.questions,self.currentQuestion!)
        if let actualIndex = indexOfCurrentQuestion {
            userDefaults.setInteger(actualIndex, forKey: "questionIndex")
        }
        
        //Set true if result view is visible otherwise set false
        userDefaults.setBool(self.resultView.alpha == 1, forKey: "resultViewAlpha")
        
        //Save the title of the result view
        userDefaults.setObject(self.correctLabel.text, forKey: "resultTitle")
        
        //Save those changes
        userDefaults.synchronize()
    }
    
    func loadState() {
        let userDefaults:NSUserDefaults = NSUserDefaults.standardUserDefaults()
        
        //Load the saved question into the current question
        let currentQuestionIndex:Int = userDefaults.integerForKey("questionIndex")
        
        if currentQuestionIndex < questions.count {
            self.currentQuestion = questions[currentQuestionIndex]
        }
        
        //Load score
        let score:Int = userDefaults.integerForKey("numberCorrect")
        
        self.numberCorrect = score
        
        //Load result view
        let isResultViewVisible:Bool = userDefaults.boolForKey("resultViewAlpha")
        if(isResultViewVisible) {
            //Display the result view
            self.feedbackLabel.text = currentQuestion?.feedback
            
            //Retrieve result view title
            let title:String? = userDefaults.objectForKey("resultTitle") as! String?
            
            if let actualTitle = title {
                self.correctLabel.text = actualTitle
                
                if(actualTitle == "Correct") {
                    self.resultView.backgroundColor = UIColor(red: 0, green: 114/255, blue: 0, alpha: 1)
                    self.nextButton.backgroundColor = UIColor(red: 0, green: 85/255, blue: 0, alpha: 1)
                }
                else if (actualTitle == "Incorrect"){
                    //Change result view background color and answer label
                    self.resultView.backgroundColor = UIColor(red: 224/225, green: 0, blue: 0, alpha: 1)
                    self.nextButton.backgroundColor = UIColor(red: 167/225, green: 0, blue: 0, alpha: 1)
                }
            }
            
            self.dimView.alpha = 1
            self.resultView.alpha = 1
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func bannerView(banner: ADBannerView!, didFailToReceiveAdWithError error: NSError!) {
        NSLog("Error Loading Ad")
    }
    
    func bannerViewActionShouldBegin(banner: ADBannerView!, willLeaveApplication willLeave: Bool) -> Bool {
        return true
    }
    
    func bannerViewDidLoadAd(banner: ADBannerView!) {
        Banner.hidden = false
    }
}


