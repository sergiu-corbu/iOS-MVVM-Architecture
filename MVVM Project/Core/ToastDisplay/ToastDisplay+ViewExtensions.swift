//
//  ToastDisplay+ViewExtensions.swift
//  MVVM Project
//
//  Created by Sergiu Corbu on 03.11.2022.
//

import SwiftUI

extension View {
    
    func toastDisplay(
        isPresented: Binding<Bool>,
        style: ToastDisplay.Style,
        title: String?,
        message: String
    ) -> some View {
        
        ZStack(alignment: .top) {
            self
            ToastDisplay(
                isPresented: isPresented,
                style: style,
                title: title,
                message: message
            )
            .zIndex(1)
        }
    }
    
    //MARK: Success
    
    func successToast(
        isPresented: Binding<Bool>,
        title: String?,
        message: String
    ) -> some View {
        
        ZStack(alignment: .top) {
            self
            ToastDisplay(
                isPresented: isPresented,
                style: .success,
                title: title,
                message: message
            )
            .zIndex(1)
        }
    }
    
    func successToast(
        isPresented: Binding<Bool>,
        message: String
    ) -> some View {
        
        ZStack(alignment: .top) {
            self
            ToastDisplay(
                isPresented: isPresented,
                style: .success,
                title: nil,
                message: message
            )
            .zIndex(1)
        }
    }

    
    //MARK: Errors
    
    func errorToast(error: Binding<Error?>, title: String?) -> some View {
        var isPresentedBinding: Binding<Bool> {
            Binding(get: {
                return error.wrappedValue != nil
            }, set: { newValue in
                if !newValue {
                    error.wrappedValue = nil
                }
            })
        }
        
        return ZStack(alignment: .top) {
            self
            ToastDisplay(
                isPresented: isPresentedBinding,
                style: .error,
                title: title,
                message: error.wrappedValue?.localizedDescription ?? ""
            )
            .zIndex(1)
        }
    }
    
    func errorToast(error: Binding<Error?>) -> some View {
        var isPresentedBinding: Binding<Bool> {
            Binding(get: {
                return error.wrappedValue != nil
            }, set: { newValue in
                if !newValue {
                    error.wrappedValue = nil
                }
            })
        }
        
        return ZStack(alignment: .top) {
            self
            ToastDisplay(
                isPresented: isPresentedBinding,
                style: .error,
                title: "Error",
                message: error.wrappedValue?.localizedDescription ?? ""
            )
            .zIndex(1)
        }
    }
    
    //MARK: Informative
    
    func informativeToast(
        isPresented: Binding<Bool>,
        title: String?,
        message: String
    ) -> some View {
        
        ZStack(alignment: .top) {
            self
            ToastDisplay(
                isPresented: isPresented,
                style: .informative,
                title: title,
                message: message
            )
            .zIndex(1)
        }
    }

    func informativeToast(
        isPresented: Binding<Bool>,
        message: String
    ) -> some View {
        
        ZStack(alignment: .top) {
            self
            ToastDisplay(
                isPresented: isPresented,
                style: .informative,
                title: nil,
                message: message
            )
            .zIndex(1)
        }
    }
}
