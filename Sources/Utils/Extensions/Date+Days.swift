//
//  Date+Days.swift
//  PrivacyMonitorFramework
//
//  Created by Christian Roman on 1/13/19.
//

import Foundation

extension Date {

    func daysFromDate(_ date: Date = .init()) -> Int? {
        return Calendar.current.dateComponents([.day], from: date, to: self).day
    }
}
