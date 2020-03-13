//
//  OfferStatus.swift
//  TheBarCode
//
//  Created by Mac OS X on 06/03/2020.
//  Copyright © 2020 Cygnis Media. All rights reserved.
//

import UIKit

class OfferStatus {
    
    var startDateTime: Date
    var endDateTime: Date
    
    var startTime: Date
    var endTime: Date
    
    init(startDateTime: Date, endDateTime: Date, startTime: Date, endTime: Date) {
        self.startDateTime = startDateTime
        self.endDateTime = endDateTime
        
        self.startTime = startTime
        self.endTime = endTime
    }
    
    func getCurrentStatus() -> (status: DealStatus, statusReason: String) {
        
        let currentDate = Date()
        
        let isDealStarted = currentDate.compare(self.startDateTime) == .orderedDescending
        let isDealExpired = currentDate.compare(self.endDateTime) == .orderedDescending
        
        guard isDealStarted else {
            return (.notStarted, "Deal start date time is > device's current date time i.e. values ---> Current date time: \(currentDate) deal start date time: \(self.startDateTime)")
        }
        
        guard !isDealExpired else {
            return (.expired, "Deal end date time is < device's current date time i.e. values ---> Current date time: \(currentDate) deal end date time: \(self.endDateTime)")
        }
        
        //Current date should be greater than start date time and end date should be less than current date time
        let isInRange = currentDate.isDate(inRange: self.getStartDateTime(), toDate: self.getEndDateTime(), inclusive: true)
        //            (currentDate.compare(self.getStartDateTime()) == .orderedDescending) && (currentDate.compare(self.getEndDateTime()) == .orderedAscending)
        if isInRange {
            return (.started, "Device's current date time lies between serverDealStartDateTime and serverDealEndDateTime i.e. values ---> Current date time: \(currentDate) serverDealStartDateTime: \(self.getStartDateTime()) serverDealEndDateTime: \(self.getEndDateTime())")
        } else {
            return (.notStarted, "Device's current date time does not lie between serverDealStartDateTime \(self.getStartDateTime()) and serverDealEndDateTime \(self.getEndDateTime())")
        }
    }
    
    func getStartDateTime() -> Date {
        
        let currentDate = Date()
        
        let dateformatter = DateFormatter()
        dateformatter.timeZone = serverTimeZone!
        dateformatter.dateFormat = serverDateFormat
        
        let todayDateString = dateformatter.string(from: currentDate)
        
        dateformatter.dateFormat = serverTimeFormat
        let dealStartTimeString = dateformatter.string(from: self.startTime)
        
        let todayDateTimeString = todayDateString + " " + dealStartTimeString
        
        dateformatter.dateFormat = serverDateFormat + " " + serverTimeFormat
        
        let todayStartDealDateTime = dateformatter.date(from: todayDateTimeString)!
        
        //If today start deal date time is > end deal date time --> Subtract 1 day
        if todayStartDealDateTime.compare(self.getEndDateTime()) == .orderedDescending {
            return todayStartDealDateTime.addingTimeInterval(-(24.0 * 60.0 * 60.0))
            
        } else if (self.getEndDateTime().timeIntervalSince(todayStartDealDateTime) > (24.0 * 60.0 * 60.0)) {
            return todayStartDealDateTime.addingTimeInterval((24.0 * 60.0 * 60.0))
        } else {
            return todayStartDealDateTime
        }
    }
    
    func getEndDateTime() -> Date {
        let currentDate = Date()
        
        let dateformatter = DateFormatter()
        dateformatter.timeZone = serverTimeZone!
        dateformatter.dateFormat = serverDateFormat
        
        let todayDateString = dateformatter.string(from: currentDate)
        
        dateformatter.dateFormat = serverTimeFormat
        let dealEndTimeString = dateformatter.string(from: self.endTime)
        
        let todayDateTimeString = todayDateString + " " + dealEndTimeString
        
        dateformatter.dateFormat = serverDateFormat + " " + serverTimeFormat
        
        let todayEndDealDateTime = dateformatter.date(from: todayDateTimeString)!
        
        //If current date is less than deal end date time
        if currentDate.compare(todayEndDealDateTime) == .orderedAscending {
            return todayEndDealDateTime
        } else {
            //If today deal date time is < deal end date time
            if todayEndDealDateTime.compare(self.endDateTime) == .orderedAscending {
                return todayEndDealDateTime.addingTimeInterval(24.0 * 60.0 * 60.0)
            } else {
                return self.endDateTime
            }
        }
    }
    
    func getStartsInRemainingSeconds() -> Int {
        
        //If current date time is less than deal start date time
        //Means deal is not initiated yet
        if Date().compare(self.startDateTime) == .orderedAscending {
            return Int(self.startDateTime.timeIntervalSinceNow)
        } else {
            let dateformatter = DateFormatter()
            dateformatter.dateFormat = serverDateFormat
            let todayDateString = dateformatter.string(from: Date())
            
            dateformatter.dateFormat = serverTimeFormat
            let dealStartTime = dateformatter.string(from: self.startTime)
            
            let todayDealDateTimeString = todayDateString + " " + dealStartTime
            
            dateformatter.dateFormat = serverDateTimeFormat
            let todayDealDateTime = dateformatter.date(from: todayDealDateTimeString)!
            
            //Current date time is less than today deal date time
            if Date().compare(todayDealDateTime) == .orderedAscending {
                return Int(todayDealDateTime.timeIntervalSinceNow) + 1
            } else {
                let nextDayDateTime = todayDealDateTime.addingTimeInterval(60.0 * 60.0 * 24.0)
                return Int(nextDayDateTime.timeIntervalSinceNow) + 1
            }
        }
    }
    
    func getExpiresInRemainingSeconds() -> Int {
        let dateformatter = DateFormatter()
        dateformatter.dateFormat = serverDateFormat
        let todayDateString = dateformatter.string(from: Date())
        
        dateformatter.dateFormat = serverTimeFormat
        let dealEndTime = dateformatter.string(from: self.endTime)
        
        let todayDealDateTimeString = todayDateString + " " + dealEndTime
        
        dateformatter.dateFormat = serverDateTimeFormat
        let todayDealDateTime = dateformatter.date(from: todayDealDateTimeString)!
        
        //Current date time is less than today deal date time
        if Date().compare(todayDealDateTime) == .orderedAscending {
            return Int(todayDealDateTime.timeIntervalSinceNow) + 1
        } else {
            let nextDayDateTime = todayDealDateTime.addingTimeInterval(60.0 * 60.0 * 24.0)
            return Int(nextDayDateTime.timeIntervalSinceNow) + 1
        }
    }
    
}

