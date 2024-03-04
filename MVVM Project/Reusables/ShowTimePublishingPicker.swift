//
//  ShowTimePublishingPicker.swift
//  MVVM Project
//
//  Created by Sergiu Corbu on 08.12.2022.
//

import SwiftUI

struct ShowTimePublishingPicker: View {
    
    @State private var publishDate: Date
    var dateComponents: DatePickerComponents = [.date, .hourAndMinute]
    var startDateInAdvance: Date?
    
    let onCancel: () -> Void
    let onSave: (Date) -> Void
    
    init(
        publishDate: Date?,
        dateComponents: DatePickerComponents = [.date, .hourAndMinute],
        startDateInAdvance: Date? = nil,
        onCancel: @escaping () -> Void,
        onSave: @escaping (Date) -> Void
    ) {
        self._publishDate = State(wrappedValue: (publishDate ?? (startDateInAdvance ?? .now)))
        self.dateComponents = dateComponents
        self.startDateInAdvance = startDateInAdvance
        self.onCancel = onCancel
        self.onSave = onSave
    }
    
    var body: some View {
        VStack(alignment: .center, spacing: 16) {
            Text(Strings.ContentCreation.publishingTimeSelection.uppercased())
                .font(kernedFont: .Main.p1RegularKerned)
                .foregroundColor(.jet)
            UIKitDatePicker(
                publishDate: $publishDate,
                minimumDate: startDateInAdvance ?? .now,
                maximumDate: Calendar.current.date(byAdding: .month, value: 1, to: .now),
                minuteInterval: 15
            )
            .labelsHidden()
            .colorMultiply(.darkGreen)
            actionButtonsView
        }
        .background(Color.cultured)
        .padding(.bottom, safeAreaInsets.bottom + 16)
    }
    
    private var actionButtonsView: some View {
        HStack(spacing: 8) {
            Buttons.BorderedActionButton(
                title: Strings.Buttons.cancel,
                tint: .middleGrey, height: 56, action: onCancel
            )
            Buttons.FillableButton(
                title: Strings.Buttons.save,
                isSelected: true
            ) {
                onSave(publishDate)
            }
        }
        .padding(.horizontal, 12)
    }
}

#if DEBUG
struct ShowTimePublishingPicker_Previews: PreviewProvider {
    
    static var previews: some View {
        ShowTimePublishingPickerPreview()
    }
    
    private struct ShowTimePublishingPickerPreview: View {
        
        @State var date = Date.now
        
        var body: some View {
            Color.feldgrau
                .bottomSheet(isPresented: .constant(true)) {
                    ShowTimePublishingPicker(publishDate: nil, onCancel: {}, onSave: {_ in})
                }
        }
    }
}
#endif
