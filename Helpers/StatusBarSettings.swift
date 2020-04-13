//
//  StatusBarSettings.swift
//  Haiku Creator
//
//  Created by Andrew on 2/10/20.
//  Copyright © 2020 Andrew. All rights reserved.
//

import Foundation
class StatusBarSettings: ObservableObject {
    @Published var isHidden = false
	@Published var isInSubview = false
}
