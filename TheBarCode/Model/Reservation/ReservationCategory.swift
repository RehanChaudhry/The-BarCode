//
//  ReservationCategory.swift
//  TheBarCode
//
//  Created by Macbook on 23/07/2020.
//  Copyright © 2020 Cygnis Media. All rights reserved.
//

import Foundation

enum ReservationType: String {
    case onGoingReservations = "onGoingReservations",
    completedReservations = "completedReservations",
    unknown = "unknown"
}


class ReservationCategory {

    var type: ReservationType = .unknown
    var reservations: [Reservation] = []

    func getTitle() -> String {
                  
        if type == .onGoingReservations {
             return  "Ongoing Reservations"
        } else if type == .completedReservations {
             return "Completed Reservations"
         }
         return ""
     }
    
    init(type: ReservationType, reservations: [Reservation]) {
        self.type = type
        self.reservations = reservations
    }
}

extension ReservationCategory {
   static func getAllDummyReservations() -> [ReservationCategory] {
        
        let Category1 = ReservationCategory(type: .onGoingReservations, reservations: Reservation.getDummyOnGoingReservations())
        let Category2 = ReservationCategory(type: .completedReservations, reservations: Reservation.getDummyCompletedReservations())
        return [Category1, Category2]
    }
}
