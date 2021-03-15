/*
 Copyright (c) 2017 M.I. Hollemans
 
 Permission is hereby granted, free of charge, to any person obtaining a copy
 of this software and associated documentation files (the "Software"), to
 deal in the Software without restriction, including without limitation the
 rights to use, copy, modify, merge, publish, distribute, sublicense, and/or
 sell copies of the Software, and to permit persons to whom the Software is
 furnished to do so, subject to the following conditions:
 
 The above copyright notice and this permission notice shall be included in
 all copies or substantial portions of the Software.
 
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
 FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS
 IN THE SOFTWARE.
 */

import Foundation
public typealias RecordTime = (String)->Void
public class RecordTimeCounterGCD {
    
    var isTimerWork = false//计时器实际状态
    var currentSecond = 0
    var stepper = 1//步长，负数没用，1～10
    
    var gcdTimer: DispatchSourceTimer?
    
    
    var recordTimeAction:RecordTime?
    
    
    
    static let sharedInstance: RecordTimeCounterGCD = {
        let instance = RecordTimeCounterGCD()
        // setup code
        return instance
    }()
    
   private func scheduleTimer(){
        if gcdTimer == nil {
            gcdTimer = DispatchSource.makeTimerSource()
            }
            gcdTimer?.schedule(deadline: DispatchTime.now(),
                               repeating: DispatchTimeInterval.seconds(1))
            gcdTimer?.setEventHandler(handler: {
                self.taskUpdate()
                
            })
            gcdTimer?.resume()
//            isTimerWork = true

        
    }
  private  func stopScheduleTimer() {
        if gcdTimer != nil{
            gcdTimer?.cancel()
        }
    }
   private func taskUpdate() {
        if let recordCallback = self.recordTimeAction{
            
            recordCallback(getCurrentTimeString())
        }
        //           countdownLabel.text = getCurrentTimeString()
    }
    
//    func getRecordTime(ac:@escaping RecordTime) {
//        self.recordTimeAction = ac
//    }
    
    
   public func startTimeCounter(ac:@escaping RecordTime){
    if(isTimerWork){
       return
    }
    self.recordTimeAction = ac
    if self.isTimerWork {
            self.stopTimer()
        }else {
            self.startTimer()
        }
    }
    
   public func stopTimer() {
        currentSecond = 0
        isTimerWork = false
        stopScheduleTimer()
        gcdTimer = nil
    }
    
   private func startTimer() {
    
        isTimerWork = true//进来就拦截标记，不然太快
        scheduleTimer()
    }
    
    //logic
   private func getCurrentTimeString() -> String {
        let currentIncrementValue = stepper
        currentSecond = currentSecond + currentIncrementValue
        if currentSecond <= 0 {
            currentSecond = 0
            return "00:00:00"
        }
        if currentSecond < 59 {
            return "00:00:\(currentSecond > 9 ? "\(currentSecond)" : "0\(currentSecond)" )"
        }else if getMins(currentSecond) < 59 {
            let currentMin = getMins(currentSecond) > 9 ? "\(getMins(currentSecond))"  : "0\(getMins(currentSecond))"
            let currentSec = getRemainSec(currentSecond) > 9 ? "\(getRemainSec(currentSecond))" : "0\(getRemainSec(currentSecond))"
            return "00:\(currentMin):\(currentSec)"
        }else {
            let currentHours = getHours(currentSecond) > 9 ? "\(getHours(currentSecond))"  : "0\(getHours(currentSecond))"
            let totalMin = getMins(currentSecond)
            let currentMinWithHrs = totalMin % 60
            let currentMin = currentMinWithHrs > 9 ? "\(currentMinWithHrs)"  : "0\(currentMinWithHrs)"
            
            let currentSec = getReaminSecFromHrsSec(currentSecond) > 9 ? "\(getReaminSecFromHrsSec(currentSecond))" : "0\(getReaminSecFromHrsSec(currentSecond))"
            return "\(currentHours):\(currentMin):\(currentSec)"
            
        }
    }
    
   private func getHours(_ sec: Int) -> Int {
        return sec/60/60
    }
    
   private func getMins(_ sec: Int) -> Int {
        return sec/60
    }
    
   private func getRemainSec(_ sec: Int) -> Int {
        return sec%60
    }
    
   private func getReaminSecFromHrsSec(_ sec: Int) -> Int {
        let currentSec =  Double(sec) / 60.0
        let floatingMinRemainder = currentSec.truncatingRemainder(dividingBy: 1)
        return Int((floatingMinRemainder * 60).rounded())
    }
    
    
}
