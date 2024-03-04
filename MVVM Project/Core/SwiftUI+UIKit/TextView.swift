//
//  TextView.swift
//  MVVM Project
//
//  Created by Sergiu Corbu on 25.11.2022.
//

import SwiftUI
import UIKit

struct TextView: UIViewRepresentable {
    
    typealias UIViewType = UITextView
    
    @Binding var text: String
    let maxCharachters: Int?
    var whitespacesEnabled = false
    var tintColor: UIColor = .jet
    var focusDelay: TimeInterval?
    
    private var textAttributes: [NSAttributedString.Key : Any] {
        return [
            .kern: 0.3, .font: UIFont.Secondary.regular(15) as Any,
            .foregroundColor: tintColor
        ]
    }
    
    func makeUIView(context: Context) -> UITextView {
        let textView = UITextView()
        textView.text = text
        textView.typingAttributes = textAttributes
        textView.attributedText = NSMutableAttributedString(
            string: text,
            attributes: textAttributes
        )
        textView.contentInset = UIEdgeInsets(top: 12, left: 12, bottom: 12, right: 12)
        textView.backgroundColor = .cultured
        textView.tintColor = tintColor
        
        textView.returnKeyType = .done
        textView.clearsOnInsertion = false
        textView.delegate = context.coordinator
        
        if let focusDelay {
            DispatchQueue.main.asyncAfter(seconds: focusDelay) {
                textView.becomeFirstResponder()
            }
        }
        
        return textView
    }
    
    func updateUIView(_ uiView: UITextView, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        return Coordinator(textView: self)
    }
    
    class Coordinator: NSObject, UITextViewDelegate {
        
        let textView: TextView
        
        init(textView: TextView) {
            self.textView = textView
        }
        
        func textViewDidChange(_ textView: UITextView) {
            if let maxCharachters = self.textView.maxCharachters,
               textView.text.count > maxCharachters {
                textView.text = String(textView.text.prefix(maxCharachters))
            }
            self.textView.text = textView.text
        }
        
        func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
            guard !self.textView.whitespacesEnabled,
                  textView.text.count > (self.textView.maxCharachters ?? range.location) - 1 else {
                return true
            }
            textView.text = textView.text.trimmingCharacters(in: .whitespaces)
            return true
        }
    }
}
