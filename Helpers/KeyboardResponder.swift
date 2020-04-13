//
//  KeyboardResponder.swift
//  Haiku Creator
//
//  Created by Andrew on 2/28/20.
//  Copyright © 2020 Andrew. All rights reserved.
//

import SwiftUI
import Combine

final class KeyboardResponder: ObservableObject {
	private var _center: NotificationCenter
	let objectWillChange = ObservableObjectPublisher()
	@Published var currentHeight: CGFloat = 0

    init(center: NotificationCenter = .default) {
        _center = center
        _center.addObserver(self, selector: #selector(keyBoardWillShow(notification:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        _center.addObserver(self, selector: #selector(keyBoardWillHide(notification:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }

    @objc func keyBoardWillShow(notification: Notification) {
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            currentHeight = keyboardSize.height
        }
    }

    @objc func keyBoardWillHide(notification: Notification) {
        currentHeight = 0
    }
}
