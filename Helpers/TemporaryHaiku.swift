//
//  TemporaryHaiku.swift
//  Haiku Creator
//
//  Created by Andrew on 3/7/20.
//  Copyright © 2020 Andrew. All rights reserved.
//

import SwiftUI

class HaikuRow: ObservableObject {
	@Published var showImage = false
	@Published var image: UIImage? {
		didSet {
			showImage.toggle()
		}
	}
	var text: String = ""
	var textOffset = CGSize.zero
	
	func removeImage() {
		image = nil
		showImage = false
	}
	
	func removeText() {
		text = ""
	}
	
	func loadFrom(_ haiku: Haiku, rowIndex: Int) {
		switch rowIndex {
		case 1:
			let data = haiku.firstImage
			let text = haiku.firstText
			
			if let data = data {
				image = UIImage(data: data)!
				showImage.toggle()
			}
			
			if let text = text {
				self.text = text
			}
			
			textOffset = CGSize(width: CGFloat(haiku.firstTextOffsetX), height: CGFloat(haiku.firstTextOffsetY))
			break
			
		case 2:
			let data = haiku.secondImage
			let text = haiku.secondText
			
			if let data = data {
				image = UIImage(data: data)!
				showImage.toggle()
			}
			
			if let text = text {
				self.text = text
			}
			
			textOffset = CGSize(width: CGFloat(haiku.secondTextOffsetX), height: CGFloat(haiku.secondTextOffsetY))
			break
			
		case 3:
			let data = haiku.thirdImage
			let text = haiku.thirdText
			
			if let data = data {
				image = UIImage(data: data)!
				showImage.toggle()
			}
			
			if let text = text {
				self.text = text
			}
			
			textOffset = CGSize(width: CGFloat(haiku.thirdTextOffsetX), height: CGFloat(haiku.thirdTextOffsetY))
			break
			
		default:
			image = UIImage(systemName: "warning")!
			break
		}
	}
}
