//
//  UIKitDatePicker.swift
//  MVVM Project
//
//  Created by Sergiu Corbu on 03.03.2023.
//

import SwiftUI
import UIKit

struct UIKitDatePicker: UIViewRepresentable {
    
    @Binding var publishDate: Date
    
    let minimumDate: Date?
    let maximumDate: Date?
    var datePickerMode: UIDatePicker.Mode = .dateAndTime
    var minuteInterval: Int?
    
    func makeUIView(context: Context) -> UIDatePicker {
        let datePicker = UIDatePicker()
        datePicker.date = publishDate
        datePicker.datePickerMode = datePickerMode
        datePicker.preferredDatePickerStyle = .wheels
        datePicker.tintColor = UIColor.darkGreen
        
        datePicker.minimumDate = minimumDate
        datePicker.maximumDate = maximumDate
        if let minuteInterval {
            datePicker.minuteInterval = minuteInterval
        }
        datePicker.addTarget(context.coordinator, action: #selector(context.coordinator.changeSelectedValue(_:)), for: .valueChanged)
        
        return datePicker
    }
    
    func updateUIView(_ uiView: UIDatePicker, context: Context) {
        uiView.date = publishDate
    }
    
     func makeCoordinator() -> Coordinator {
        Coordinator(onValueChanged: { updatedDate in
            publishDate = updatedDate
        })
    }
    
    class Coordinator {
        
        let onValueChanged: (Date) -> Void
        
        init(onValueChanged: @escaping (Date) -> Void) {
            self.onValueChanged = onValueChanged
        }
        
        @objc func changeSelectedValue(_ sender: UIDatePicker) {
            onValueChanged(sender.date)
        }
    }
}
