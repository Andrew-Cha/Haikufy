//
//  EditView.swift
//  Image Labeling
//
//  Created by Andrew on 1/13/20.
//  Copyright © 2020 Andrew. All rights reserved.
//

import SwiftUI
import UIKit

struct CreationView: View {
	var body: some View {
		FrontView()
	}
}

private struct FrontView: View {
	var body: some View {
		GeometryReader { geometry in
			NavigationLink(destination: EditView(nil)) {
				ZStack {
					Text("")
						.frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity)
					
					Image("plus")
						.resizable()
						.aspectRatio(contentMode: .fit)
						.frame(width: geometry.size.width * 0.2, height: geometry.size.width * 0.2)
				}
				.frame(width: geometry.size.width, height: geometry.size.height)
				.contentShape(Rectangle())
				.background(Color(.secondarySystemGroupedBackground))
				.cornerRadius(10)
				.overlay(
					RoundedRectangle(cornerRadius: 10)
						.stroke(Color(.separator), lineWidth: 1 / UIScreen.main.scale)
				)
			}
		}
	}
}

struct EditView: View {
	var oldHaiku: Haiku?
	@State private var didLoadInitially = false
	
	@Environment(\.managedObjectContext) private var managedObjectContext
	@Environment(\.presentationMode) private var presentationMode
	
	@ObservedObject private var firstHaikuRow = HaikuRow()
	@ObservedObject private var secondHaikuRow = HaikuRow()
	@ObservedObject private var thirdHaikuRow = HaikuRow()
	
	init(_ haiku: Haiku?) {
		self.oldHaiku = haiku
	}
	
	var body: some View {
		GeometryReader { geometry in
			VStack {
				Divider().opacity(0)
				ImagePickerView(haikuRow: self.firstHaikuRow)
				Divider().padding([.leading, .trailing], 5)
				ImagePickerView(haikuRow: self.secondHaikuRow)
				Divider().padding([.leading, .trailing], 5)
				ImagePickerView(haikuRow: self.thirdHaikuRow)
				Divider().opacity(0)
			}
			.background(Color(.systemGroupedBackground))
			.navigationBarTitle("", displayMode: .inline)
			.navigationBarItems(trailing: HStack {
				self.previewButton.padding(.trailing, 5)
				self.saveButton
			})
				.transition(.opacity)
				.frame(width: geometry.size.width, height: geometry.size.height)
				.onAppear(perform: {
					if !self.didLoadInitially {
						if let haiku = self.oldHaiku {
							self.firstHaikuRow.loadFrom(haiku, rowIndex: 1)
							self.secondHaikuRow.loadFrom(haiku, rowIndex: 2)
							self.thirdHaikuRow.loadFrom(haiku, rowIndex: 3)
							
							self.didLoadInitially = true
						}
					}
				})
		}
	}
	
	var previewButton: some View {
		return NavigationLink(destination: HaikuPreview(firstHaikuRow, secondHaikuRow, thirdHaikuRow), label: {
			Text("Preview")
		}).disabled(firstHaikuRow.image == nil && secondHaikuRow.image == nil && thirdHaikuRow.image == nil)
	}
	
	var saveButton: some View {
		Button(action: {
			//Could it be that this is only copying the old Haiku and not directly referencing it?
			let haiku = self.oldHaiku != nil ? self.oldHaiku! : Haiku(context: self.managedObjectContext)
			self.save(haiku)
			
			self.presentationMode.wrappedValue.dismiss()
		}) {
			Text("Save")
		}.disabled(firstHaikuRow.image == nil && secondHaikuRow.image == nil && thirdHaikuRow.image == nil)
	}
	
	func save(_ haiku: Haiku) {
		haiku.firstImage = self.firstHaikuRow.image?.pngData()
		haiku.secondImage = self.secondHaikuRow.image?.pngData()
		haiku.thirdImage = self.thirdHaikuRow.image?.pngData()
		
		if self.oldHaiku == nil {
			haiku.dateCreated = Date()
		}
		
		haiku.firstText = self.firstHaikuRow.text
		haiku.secondText = self.secondHaikuRow.text
		haiku.thirdText = self.thirdHaikuRow.text
		/*
		if let image = self.firstImage {
		haiku.firstTextOffsetX = Float(self.firstTextOffset.width / image.size.width)
		haiku.firstTextOffsetY = Float(self.firstTextOffset.height / image.size.height)
		}
		
		if let image = self.secondImage {
		haiku.secondTextOffsetX = Float(self.secondTextOffset.width / image.size.width)
		haiku.secondTextOffsetY = Float(self.secondTextOffset.height / image.size.height)
		}
		
		if let image = self.thirdImage {
		haiku.thirdTextOffsetX = Float(self.thirdTextOffset.width / image.size.width)
		haiku.thirdTextOffsetY = Float(self.thirdTextOffset.height / image.size.height)
		}
		*/
		
		do {
			try self.managedObjectContext.save()
		} catch {
			print(error)
		}
	}
}

private struct ImagePickerView: View {
	@ObservedObject var haikuRow: HaikuRow
	@State private var isImagePickerShown = false
	@State private var textOffset = CGSize.zero {
		didSet {
			haikuRow.textOffset = textOffset
		}
	}
	

	
	var body: some View {
		let imagePicker = ImagePicker(isShown: $isImagePickerShown, haikuRow: haikuRow)
			.navigationBarTitle("Pick an Image", displayMode: .inline)
			.navigationBarBackButtonHidden(true)
		
		return HStack {
			GeometryReader { geometry in
				NavigationLink(destination: imagePicker, isActive: self.$isImagePickerShown) {
					if self.haikuRow.showImage {
						ZStack {
							Image(uiImage: self.haikuRow.image!)
								.resizable()
								.aspectRatio(contentMode: .fit)
								.frame(width: geometry.size.width, height: geometry.size.height)
							
							Text("Temporary")
								.foregroundColor(Color.white)
								.frame(width: geometry.size.height / 3, height: geometry.size.height / 3)
								.font(.system(size: 11))
						}
					} else {
						Image(systemName: "camera.on.rectangle")
							.resizable()
							.aspectRatio(contentMode: .fit)
							.frame(width: geometry.size.width, height: geometry.size.height * 3 / 4)
							.padding()
						
					}
				}
				.frame(width: geometry.size.width, height: geometry.size.height)
				.buttonStyle(PlainButtonStyle())
			}
			
			Divider()
			
			VStack {
				NavigationLink(destination: ImageEditor(haikuRow: self.haikuRow)) {
					Image("pencil")
						.resizable()
						.aspectRatio(contentMode: .fit)
						.frame(width: 44, height: 44)
				}
				.disabled(self.haikuRow.image == nil)
				
				
				Button(action: {
					withAnimation(.linear(duration: 0.25)) {
						self.haikuRow.image = nil
						self.haikuRow.removeText()
					}
				}) {
					Image("trash")
						.resizable()
						.aspectRatio(contentMode: .fit)
						.frame(width: 44, height: 44)
				}
				.disabled(self.haikuRow.image == nil)
			}
			.animation(.easeInOut)
			.transition(.opacity)
			.padding(.leading, 10)
			.padding(.trailing, 20)
		}
	}
}

private struct ImageEditor: View {
	var haikuRow: HaikuRow

	@State private var currentText = "" {
		didSet {
			self.haikuRow.text = self.currentText
		}
	}
	@State private var newOffset = CGSize.zero
	@State private var oldOffset = CGSize.zero
	
	@ObservedObject private var keyboard = KeyboardResponder()
	
	var body: some View {
		GeometryReader { geometry in
			VStack {
				ZStack {
					Image(uiImage: self.haikuRow.image!)
						.resizable()
						.frame(width: geometry.size.width, height: geometry.size.height)
						.aspectRatio(contentMode: .fit)
					
					Text("Replace with text to be saved")
						.shadow(color: Color.black, radius: 3, x: 0, y: 0)
						.frame(width: geometry.size.width * 0.7, height: geometry.size.height * 0.2)
						.offset(x: self.newOffset.width, y: self.newOffset.height)
						.gesture(
							DragGesture()
								.onChanged { value in
									let newValue = CGSize(width: value.translation.width + self.oldOffset.width, height: value.translation.height + self.oldOffset.height)
									if geometry.size.width * 0.7 * 0.5 - abs(newValue.width) > 0 && geometry.size.width * 0.7 * 0.5 - abs(newValue.height) > 0 {
										self.newOffset = newValue
									}
							}
							.onEnded { value in
								self.oldOffset = self.newOffset
								self.haikuRow.textOffset = CGSize(width: self.newOffset.width * 1/2, height: self.newOffset.height * 1/2)
						})
				}.background(Color(.systemBackground))
			}
			.frame(width: geometry.size.width, height: geometry.size.height)
			.background(Color(.systemGroupedBackground))
			.offset(y: -self.keyboard.currentHeight)
				//.edgesIgnoringSafeArea(self.keyboard.currentHeight > 0 ? .bottom : [])
				.animation(.linear(duration: 0.2))
				.transition(.slide)
		}
	}
}

private struct ImagePicker: UIViewControllerRepresentable {
	@Binding var isShown: Bool
	var haikuRow: HaikuRow
	
	class Coordinator: NSObject, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
		@Binding var isShown: Bool
		var haikuRow: HaikuRow
		
		init(isShown: Binding<Bool>, haikuRow: HaikuRow) {
			_isShown = isShown
			self.haikuRow = haikuRow
		}
		
		func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
			let screenRect = UIScreen.main.bounds.size
			let imagePicked = info[UIImagePickerController.InfoKey.originalImage] as! UIImage
			let resizedImage = screenRect.height < imagePicked.size.height ? imagePicked.resizeImage(screenRect.height) : imagePicked
			haikuRow.image = resizedImage
			haikuRow.showImage = true
			isShown = false
		}
		
		func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
			isShown = false
		}
		
	}
	
	func makeCoordinator() -> Coordinator {
		return Coordinator(isShown: $isShown, haikuRow: haikuRow)
	}
	
	func makeUIViewController(context: UIViewControllerRepresentableContext<ImagePicker>) -> UIImagePickerController {
		let picker = UIImagePickerController()
		picker.delegate = context.coordinator
		
		return picker
	}
	
	func updateUIViewController(_ uiViewController: UIImagePickerController, context: UIViewControllerRepresentableContext<ImagePicker>) {
		
	}
}

private struct HaikuPreview: View {
	var images: [UIImage?]
	
	init(_ firstHaikuRow: HaikuRow, _ secondHaikuRow: HaikuRow, _ thirdHaikuRow: HaikuRow) {
		images = []
		
		images.append(firstHaikuRow.image)
		images.append(secondHaikuRow.image)
		images.append(thirdHaikuRow.image)
	}
	
	var body: some View {
		GeometryReader { geometry in
			VStack(alignment: .center, spacing: 0, content: {
				ForEach(self.images, id: \.self) { image in
					return Group {
						if image != nil {
							Image(uiImage: image!)
								.resizable()
								.aspectRatio(contentMode: .fit)
								.frame(width: geometry.size.width, height: geometry.size.height / 3)
							
						} else {
							ZStack {
								Group {
									Image(systemName: "camera.on.rectangle")
										.resizable()
										.aspectRatio(contentMode: .fit)
										.frame(width: geometry.size.height / 5, height: geometry.size.height / 5)
								}.frame(width: geometry.size.width, height: geometry.size.height / 3)
							}
						}
						
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
	}
}

extension UIImage {
	func crop(to: CGSize) -> UIImage {
		guard let cgimage = self.cgImage else { return self }
		
		let contextImage: UIImage = UIImage(cgImage: cgimage)
		
		let contextSize: CGSize = contextImage.size
		
		//Set to square
		var posX: CGFloat = 0.0
		var posY: CGFloat = 0.0
		let cropAspect: CGFloat = to.width / to.height
		
		var cropWidth: CGFloat = to.width
		var cropHeight: CGFloat = to.height
		
		if to.width > to.height { //Landscape
			cropWidth = contextSize.width
			cropHeight = contextSize.width / cropAspect
			posY = (contextSize.height - cropHeight) / 2
		} else if to.width < to.height { //Portrait
			cropHeight = contextSize.height
			cropWidth = contextSize.height * cropAspect
			posX = (contextSize.width - cropWidth) / 2
		} else { //Square
			if contextSize.width >= contextSize.height { //Square on landscape (or square)
				cropHeight = contextSize.height
				cropWidth = contextSize.height * cropAspect
				posX = (contextSize.width - cropWidth) / 2
			}else{ //Square on portrait
				cropWidth = contextSize.width
				cropHeight = contextSize.width / cropAspect
				posY = (contextSize.height - cropHeight) / 2
			}
		}
		
		let rect: CGRect = CGRect(x : posX, y : posY, width : cropWidth, height : cropHeight)
		
		// Create bitmap image from context using the rect
		let imageRef: CGImage = contextImage.cgImage!.cropping(to: rect)!
		
		// Create a new image based on the imageRef and rotate back to the original orientation
		let cropped: UIImage = UIImage(cgImage: imageRef, scale: self.scale, orientation: self.imageOrientation)
		
		cropped.draw(in: CGRect(x : 0, y : 0, width : to.width, height : to.height))
		
		return cropped
	}
	
	func resizeImage(_ dimension: CGFloat) -> UIImage {
		var width: CGFloat
		var height: CGFloat
		var newImage: UIImage
		
		let size = self.size
		let aspectRatio =  size.width / size.height
		
		if aspectRatio > 1 {
			width = dimension
			height = dimension / aspectRatio
		} else {
			height = dimension
			width = dimension * aspectRatio
		}
		
		UIGraphicsBeginImageContextWithOptions(CGSize(width: width, height: height), false, 0)
		self.draw(in: CGRect(x: 0, y: 0, width: width, height: height))
		newImage = UIGraphicsGetImageFromCurrentImageContext()!
		UIGraphicsEndImageContext()
		
		return newImage
	}
	
	func textToImage(drawText text: String, inImage image: UIImage, atPoint point: CGSize) -> UIImage {
		let textColor = UIColor.white
		let textFont = UIFont(name: "Helvetica Bold", size: 100)!
		
		let scale = UIScreen.main.scale
		UIGraphicsBeginImageContextWithOptions(image.size, false, scale)
		
		let textFontAttributes = [
			NSAttributedString.Key.font: textFont,
			NSAttributedString.Key.foregroundColor: textColor,
			] as [NSAttributedString.Key : Any]
		image.draw(in: CGRect(origin: CGPoint.zero, size: image.size))
		
		let rect = CGRect(origin: CGPoint(x: point.width, y: point.height), size: image.size)
		text.draw(in: rect, withAttributes: textFontAttributes)
		
		let newImage = UIGraphicsGetImageFromCurrentImageContext()
		UIGraphicsEndImageContext()
		
		return newImage!
	}
}
