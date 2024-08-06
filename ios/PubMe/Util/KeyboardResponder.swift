//
//  KeyboardResponder.swift
//  PubMe
//
//  Created by Jason van den Berg on 2024/08/06.
//


import SwiftUI
import Combine

final class KeyboardResponder: ObservableObject {
    private var notificationCenter: NotificationCenter
    @Published private(set) var currentHeight: CGFloat = 0
    @Published var isOpen = false
    
    init(center: NotificationCenter = .default) {
        notificationCenter = center
        notificationCenter.addObserver(self, selector: #selector(keyBoardWillShow(notification:)), name: UIResponder.keyboardWillShowNotification, object: nil)
//        notificationCenter.addObserver(self, selector: #selector(keyBoardDidShow(notification:)), name: UIResponder.keyboardDidShowNotification, object: nil)
        notificationCenter.addObserver(self, selector: #selector(keyBoardWillHide(notification:)), name: UIResponder.keyboardWillHideNotification, object: nil)
//        notificationCenter.addObserver(self, selector: #selector(keyBoardDidHide(notification:)), name: UIResponder.keyboardDidHideNotification, object: nil)
    }

    deinit {
        notificationCenter.removeObserver(self)
    }

    @objc func keyBoardWillShow(notification: Notification) {
        isOpen = true
        setSize(notification)
    }
    
    @objc func keyBoardDidShow(notification: Notification) {
        isOpen = true
        setSize(notification)
    }
    
    @objc func keyBoardDidHide(notification: Notification) {
        isOpen = false
        currentHeight = 0
    }

    @objc func keyBoardWillHide(notification: Notification) {
        isOpen = false
        currentHeight = 0
    }
    
    private func setSize(_ notification: Notification) {
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            currentHeight = keyboardSize.height
        }
    }
}
