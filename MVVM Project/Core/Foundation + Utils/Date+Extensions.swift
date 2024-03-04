//
//  Date+Extensions.swift
//  MVVM Project
//
//  Created by Sergiu Corbu on 08.12.2022.
//

import Foundation

extension Date {
    
    enum DateFormatStyle: String {
        case defaultDate = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"
        case compactDate = "dd MMM YYYY"
        case compactDateAndTime = "dd MMM • h:mm a"
        case fullDateAndTime = "dd MMM YYYY • h:mm a"
    }

    var passedTimeSinceNow: String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .full
        formatter.dateTimeStyle = .named
        return formatter.localizedString(for: self, relativeTo: Date())
    }

    func dateString(formatType: DateFormatStyle, timeZone: TimeZone = .current) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = formatType.rawValue
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = timeZone
        return formatter.string(from: self)
    }
    
    func adding(component: Calendar.Component, value: Int) -> Date {
        return Calendar.current.date(byAdding: component, value: value, to: self) ?? .now
    }
        
    func nearestTime(minutes: TimeInterval) -> Date {
        let seconds = max(min(minutes, 60), 0) * 60
        let timeInterval = (timeIntervalSinceReferenceDate / seconds).rounded(.toNearestOrEven)
        return Date(timeIntervalSinceReferenceDate: timeInterval * seconds)
    }
    
    var minutesFromCurrentDate: Int? {
        return Calendar.current.dateComponents([.minute], from: .now, to: self).minute
    }
    
    var isLessThanOneDay: Bool {
        guard let remainingHours = Calendar.current.dateComponents([.hour], from: .now, to: self).hour else {
            return false
        }
        return abs(remainingHours) < 24
    }
}

extension DateFormatter {
    
    var defaultDateFormatter: DateFormatter {
        locale = Locale(identifier: "en_US_POSIX")
        dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        return self
    }
}
