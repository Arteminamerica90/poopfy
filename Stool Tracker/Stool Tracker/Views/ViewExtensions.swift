//
//  ViewExtensions.swift
//  Stool Tracker
//
//  Created for iOS 13 compatibility
//

import SwiftUI

extension View {
    /// A compatibility wrapper for ignoresSafeArea that works on iOS 13+
    @ViewBuilder
    func ignoresSafeAreaCompat() -> some View {
        if #available(iOS 14.0, *) {
            self.ignoresSafeArea()
        } else {
            self.edgesIgnoringSafeArea(.all)
        }
    }
    
    /// A compatibility wrapper for navigationTitle that works on iOS 13+
    @ViewBuilder
    func navigationTitleCompat(_ title: String) -> some View {
        if #available(iOS 14.0, *) {
            self.navigationTitle(title)
        } else {
            self.navigationBarTitle(title)
        }
    }
    
    /// A compatibility wrapper for onChange that works on iOS 13+
    @ViewBuilder
    func onChangeIfAvailable<T: Equatable>(of value: T, perform action: @escaping (T) -> Void) -> some View {
        if #available(iOS 14.0, *) {
            self.onChange(of: value, perform: action)
        } else {
            // For iOS 13, onChange is not available
            // Changes will be handled manually when user interacts with controls
            self
        }
    }
}

extension Font {
    static var title2Compat: Font {
        if #available(iOS 14.0, *) {
            return .title2
        } else {
            return .system(size: 22, weight: .bold)
        }
    }
}

