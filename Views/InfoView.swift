//
//  InfoView.swift
//  Haiku Creator
//
//  Created by Andrew on 1/28/20.
//  Copyright © 2020 Andrew. All rights reserved.
//

import SwiftUI

struct InfoView: View {
	var body: some View {
		FlipView(FrontView(), BackView())
	}
}

private struct FrontView: View {
	let screenRect = UIScreen.main.bounds.size
	
	var body: some View {
		GeometryReader { geometry in
			ZStack {
				Text("")
					.frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity)
					.background(Color(.secondarySystemGroupedBackground))
					.cornerRadius(10)
					.overlay(
						RoundedRectangle(cornerRadius: 10)
							.stroke(Color(.separator), lineWidth: 1 / UIScreen.main.scale)
				)
				
				Image("info")
					.resizable()
					.aspectRatio(contentMode: .fit)
					.frame(width: geometry.size.height * 0.2, height: geometry.size.height * 0.2)
			}
			.contentShape(Rectangle())
		}
	}
}

private struct BackView: View {
	let backViewText: String = """
		Welcome to Haikufy v0.2.0
		
		Haiku Creation:
		• Scroll Right and tap on "+".
		
		Haiku Editing:
		• Scroll to your Haiku and tap on it, then on the pen.

		Haiku Deletion:
		• Scroll to your Haiku and tap on it, then on the trash bin.
		
		Haiku Exporting:
		• Scroll to your Haiku and tap on it, then on the arrow.
		"""
	
	var body: some View {
		Text(self.backViewText)
			.frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity)
			.padding(10)
			.contentShape(Rectangle())
			.rotationEffect(.degrees(180))
			.rotation3DEffect(.degrees(180), axis: (x: 1, y: 0, z: 0))
			.background(Color(.secondarySystemGroupedBackground))
			.cornerRadius(10)
			.overlay(
				RoundedRectangle(cornerRadius: 10)
					.stroke(Color(.separator), lineWidth: 1 / UIScreen.main.scale)
		)
	}
}
