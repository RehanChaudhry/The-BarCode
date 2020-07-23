//
//  Reservation.swift
//  TheBarCode
//
//  Created by Macbook on 22/07/2020.
//  Copyright © 2020 Cygnis Media. All rights reserved.
//

import Foundation

enum ReservationStatus: String {
    case valid = "valid",
    cancelled = "cancelled",
    completed = "completed",
    other = "other"
}

class Reservation {

    var barName: String = ""
    var noOfPersons: Int = 0
    var visaCardInfo: String = ""
    var date: String = ""
    var time: String = ""
    var orderNo: String = ""
    var status: ReservationStatus =  .other
    
    init(barName: String, noOfPersons: Int, visaCardInfo: String, date: String, time: String, status: ReservationStatus) {
        self.barName = barName
        self.noOfPersons = noOfPersons
        self.date = date
        self.visaCardInfo = visaCardInfo
        
        self.status = status
        self.time = time
    }
    
    init(orderNo: String, barName: String, noOfPersons: Int, visaCardInfo: String, date: String, time: String, status: ReservationStatus) {
        self.orderNo = orderNo
        self.barName = barName
        self.noOfPersons = noOfPersons
        self.date = date
        self.visaCardInfo = visaCardInfo
        self.status = status
        self.time = time
      }
      

}

extension Reservation {
  static  func getDummyOnGoingReservations() -> [Reservation] {
        let reservation1 = Reservation(barName: "Albert's Schloss", noOfPersons: 6, visaCardInfo: "Visa Ending in 1881", date: "Wed,July 15,29", time: "9:00AM", status: .valid)
    let reservation2 = Reservation(barName: "The Blue Bar at The Berkeley", noOfPersons: 6, visaCardInfo: "Visa Ending in 1881", date: "Wed,July 15,29", time: "8:00AM", status: .cancelled)

        return [reservation1, reservation2]
    }
    
   static func getDummyCompletedReservations() -> [Reservation] {
        let reservation1 = Reservation(orderNo: "434267378", barName: "Neighbourhood", noOfPersons: 3, visaCardInfo: "Visa Ending in 1881", date: "Wed,July 15,29", time: "9:00AM", status: .completed)
        return [reservation1]
    }
    
}
