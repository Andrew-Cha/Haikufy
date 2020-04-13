//
//  ContentView.swift
//  Image Labeling
//
//  Created by Andrew on 1/7/20.
//  Copyright © 2020 Andrew. All rights reserved.
//


/*
TODO:
Add text stuff properly
*/

import SwiftUI

struct ContentView: View {
	@Environment(\.managedObjectContext) var managedObjectContext
	@FetchRequest(entity: Haiku.entity(), sortDescriptors: [NSSortDescriptor(keyPath: \Haiku.dateCreated, ascending: false)]) var haikus: FetchedResults<Haiku>
	
	let cardWidthMultiplier: CGFloat = 0.8
	
	var body: some View {
		let haikuArray = haikus.filter({ $0.firstImage != nil || $0.secondImage != nil || $0.thirdImage != nil })
		
		return NavigationView {
			GeometryReader { parentGeometry in
				ScrollView(.horizontal, showsIndicators: false) {
					HStack {
						Group {
							InfoView()
							CreationView()
							ForEach(haikuArray, id: \.self) { haiku in
								ImageView(haiku)
							}
						}
						.frame(width: parentGeometry.size.width * self.cardWidthMultiplier)
						.padding(10)
						.buttonStyle(PlainButtonStyle())
					}
				}
				.background(Color(.systemGroupedBackground))
				.navigationBarTitle("Haiku", displayMode: .inline)
				.edgesIgnoringSafeArea(.top)
			}
		}.navigationViewStyle(StackNavigationViewStyle())
	}
	
	
	
	struct ContentView_Previews: PreviewProvider {
		static var previews: some View {
			let managedObjectContext = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
			
			return ContentView()
				.environment(\.managedObjectContext, managedObjectContext)
				.environment(\.colorScheme, .dark)
		}
	}
}
