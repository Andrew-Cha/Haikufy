//
//  ImageView.swift
//  Haiku Creator
//
//  Created by Andrew on 1/16/20.
//  Copyright © 2020 Andrew. All rights reserved.
//

import SwiftUI
import Photos

struct ImageView: View {
	var haiku: Haiku
	
	init (_ haiku: Haiku) {
		self.haiku = haiku
	}
	
	var body: some View {
		FlipView(ScrollImage(haiku), BackView(haiku: haiku))
	}
}

private struct ScrollImage: View {
	var haiku: Haiku
	@State private var images: [UIImage?] = []
	@State private var firstImage: UIImage?
	@State private var secondImage: UIImage?
	@State private var thirdImage: UIImage?
	
	init(_ haiku: Haiku) {
		self.haiku = haiku
	}
	
	var body: some View {
		GeometryReader { geometry in
			VStack(alignment: .center, spacing: 0, content: {
				ForEach(self.images, id: \.self) { image in
					return Group {
						ZStack {
							if image != nil {
								Image(uiImage: image!)
									.resizable()
									.aspectRatio(contentMode: .fit)
									.frame(width: geometry.size.width, height: geometry.size.height / 3)
								
							} else {
								Image(systemName: "camera.on.rectangle")
									.resizable()
									.aspectRatio(contentMode: .fit)
									.frame(width: geometry.size.height / 5, height: geometry.size.height / 5)
							}
						}.frame(width: geometry.size.width, height: geometry.size.height / 3)
						
						Divider()
					}
				}
			})
				.frame(width: geometry.size.width, height: geometry.size.height)
				.background(Color(.secondarySystemGroupedBackground))
				.cornerRadius(10)
				.overlay(
					RoundedRectangle(cornerRadius: 10)
						.stroke(Color(.separator), lineWidth: 1 / UIScreen.main.scale)
			)
		}
		.onAppear(perform: {
			self.images = []
			
			self.images.append(self.haiku.firstImage.flatMap { UIImage.init(data: $0) })
			self.images.append(self.haiku.secondImage.flatMap { UIImage.init(data: $0) })
			self.images.append(self.haiku.thirdImage.flatMap { UIImage.init(data: $0) })
		})
	}
}

private struct BackView: View {
	@Environment(\.managedObjectContext) var managedObjectContext
	var haiku: Haiku
	@State private var isOpaque = false
	@State private var isAlertShown = false
	@State private var isLabelShown = false
	@State private var labelText: String = ""
	let cameraPermissions = PHPhotoLibrary.authorizationStatus()
	
	var body: some View {
		GeometryReader { geometry in
			VStack {
				NavigationLink(destination: EditView(self.haiku)) {
					Image("pencil")
						.resizable()
						.aspectRatio(contentMode: .fit)
						.frame(width: geometry.size.width * 0.2, height: geometry.size.width * 0.2)
				}.padding(5)
				
				ZStack {
					Button(action: {
						self.isAlertShown.toggle()
					}) {
						Image("square.and.arrow.up")
							.resizable()
							.aspectRatio(contentMode: .fit)
							.frame(width: geometry.size.width * 0.25, height: geometry.size.width * 0.25)
					}
					.blur(radius: self.isLabelShown ? 1.0 : 0.0)
					.padding(5)
					
					Text(self.labelText)
						.frame(width: geometry.size.width * 0.7, height: geometry.size.height * 0.2, alignment: .center)
						.background(Color(.secondarySystemGroupedBackground))
						.overlay(
							RoundedRectangle(cornerRadius: 10)
								.stroke(Color(.separator), lineWidth: 2 / UIScreen.main.scale)
					)
						.cornerRadius(10)
						.opacity(self.isLabelShown ? 1 : 0)
						.animation(.easeInOut)
						.transition(.opacity)
						.multilineTextAlignment(.center)
				}
				
				Button(action: {
					withAnimation(.linear(duration: 0.25)) {
						self.isOpaque.toggle()
						
						DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
							withAnimation(.easeOut(duration: 0.25)) {
								self.managedObjectContext.delete(self.haiku)
								
								do {
									try self.managedObjectContext.save()
								} catch {
									fatalError()
								}
							}
						}
					}
				}) {
					Image("trash")
						.resizable()
						.aspectRatio(contentMode: .fit)
						.frame(width: geometry.size.width * 0.25, height: geometry.size.width * 0.25)
				}.padding(10)
			}
			.buttonStyle(PlainButtonStyle())
			.frame(width: geometry.size.width, height: geometry.size.height)
			.background(Color(.secondarySystemGroupedBackground))
			.opacity(self.isOpaque ? 0.0 : 1.0)
			.contentShape(Rectangle())
			.rotationEffect(.degrees(180))
			.rotation3DEffect(.degrees(180), axis: (x: 1, y: 0, z: 0))
			.background(Color(.secondarySystemGroupedBackground))
			.cornerRadius(10)
			.overlay(RoundedRectangle(cornerRadius: 10).stroke(Color(.separator), lineWidth: 1 / UIScreen.main.scale))
			.alert(isPresented: self.$isAlertShown, content: {
				Alert(title: Text("Confirm"),
					  message: Text("Are you sure you want to save the Haiku?"),
					  primaryButton: .default(Text("Save"), action: {
						var canSave = false
						
						switch self.cameraPermissions {
						case .denied:
							self.labelText = "Failed to save Haiku because permission to save images to camera roll is denied."
							break
							
						case .restricted:
							self.labelText = "Failed to save Haiku because permission to save images to camera roll is restricted."
							break
							
						case .notDetermined:
							PHPhotoLibrary.requestAuthorization({ newStatus in
								if newStatus ==  PHAuthorizationStatus.authorized {
									self.labelText = "Haiku saved to camera roll successfully."
									canSave = true
								} else {
									self.labelText = "Failed to save Haiku because permission to save images to camera roll is denied."
								}
							})
							
							break
							
						case .authorized:
							self.labelText = "Haiku saved to camera roll successfully."
							canSave = true
							
							break
							
						default:
							self.labelText = "Something went wrong..."
							
							break
						}
						
						if canSave {
							let mergedImage = mergeImagesFrom(self.haiku)
							UIImageWriteToSavedPhotosAlbum(mergedImage, nil, nil, nil)
						}
						
						self.isLabelShown = true
						
						DispatchQueue.main.asyncAfter(deadline: .now() + 4.0, execute: {
							self.isLabelShown = false
						})
					}),
					  secondaryButton: .cancel(Text("Cancel")))
			})
		}
	}
}

private func mergeImagesFrom(_ haiku: Haiku) -> UIImage {
	let images = [haiku.firstImage, haiku.secondImage, haiku.thirdImage]
	let imageTexts = [haiku.firstText, haiku.secondText, haiku.thirdText]
	let imageOffsets = [haiku.firstTextOffsetX, haiku.firstTextOffsetY, haiku.secondTextOffsetX, haiku.secondTextOffsetY, haiku.thirdTextOffsetX, haiku.thirdTextOffsetY]
	
	var imagesToMerge: [UIImage] = []
	var offsetIndex = 0
	
	for imageIndex in 0...2 {
		let imageData = images[imageIndex]
		if let imageData = imageData {
			let image = UIImage(data: imageData)
			let imageText = imageTexts[imageIndex]
			let textOffset = CGSize(width: CGFloat(imageOffsets[offsetIndex]) * image!.size.width, height: CGFloat(imageOffsets[offsetIndex + 1]) * image!.size.height)
			
			let imageWithText = image!.textToImage(drawText: imageText!, inImage: image!, atPoint: textOffset)
			
			imagesToMerge.append(imageWithText)
		}
		
		offsetIndex += 2
	}
	
	return imagesToMerge.compactMap({ $0 })[0]
}
