//
//  FlipView.swift
//  Haiku Creator
//
//  Created by Andrew on 1/15/20.
//  Copyright © 2020 Andrew. All rights reserved.
//

import UIKit
import SwiftUI

struct FlipView<FrontView: View, BackView: View>: View {
	@State private var isFlipped = false
	
	let screenRect = UIScreen.main.bounds.size
	let cardWidthMultiplier: CGFloat = 0.8
	
	private var frontView: FrontView
	private var backView: BackView
	
	init(_ frontView: FrontView, _ backView: BackView) {
		self.frontView = frontView
		self.backView = backView
	}
	
	public var body: some View {
		GeometryReader { geometry in
			self.viewSwapper
				.frame(width: geometry.size.width, height: geometry.size.height)
				.rotation3DEffect(.degrees(self.isFlipped ? 180 : 0), axis: (x: 0, y: 1, z: 0))
				.onTapGesture(perform: {
					withAnimation(.linear(duration: 0.25)) {
						self.isFlipped.toggle()
					}
				})
		}
	}
	
	var viewSwapper: some View {
		ZStack {
			frontView.opacity(isFlipped ? 0 : 1)
			backView.opacity(isFlipped ? 1 : 0)
		}
	}
}
