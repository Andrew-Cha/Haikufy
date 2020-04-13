import SwiftUI

struct GraphView : View {
	func displayGeometry(_ geometry: GeometryProxy) -> String {
		let frameInGlobal = geometry.frame(in: .global)
		let frameInLocal = geometry.frame(in: .local)
		
		let text =
		"""
		safeAreaInsets.top: \t\t\(Int(geometry.safeAreaInsets.top))
		safeAreaInsets.leading: \t\(Int(geometry.safeAreaInsets.leading))
		safeAreaInsets.bottom: \t\(Int(geometry.safeAreaInsets.bottom))
		safeAreaInsets.trailing: \t\(Int(geometry.safeAreaInsets.trailing))
		frame(in: .global): (\(String(Int(frameInGlobal.minX))), \(String(Int(frameInGlobal.minY))), \(String(Int(frameInGlobal.size.width))), \(String(Int(frameInGlobal.size.height))))
		frame(in: .local): (\(String(Int(frameInLocal.minX))), \(String(Int(frameInLocal.minY))), \(String(Int(frameInLocal.size.width))), \(String(Int(frameInLocal.size.height))))
		"""
	
		return text
	}
	
	var body: some View {
		GeometryReader {
			geometry in
			VStack {
				Spacer()
				Text("Global geometry")
					.font(.title)
					.padding()
				
				Text(self.displayGeometry(geometry))
					.padding(15)
					.background(Color.white)
					.cornerRadius(15)
					.multilineTextAlignment(.trailing)
					.foregroundColor(.black)
					.lineLimit(nil)
				Spacer()
				GeometryReader { geometry in
					VStack {
						Text("Local geometry")
							.font(.title)
							.padding()
						Text(self.displayGeometry(geometry))
							.padding(15)
							.foregroundColor(.black)
							.lineLimit(nil)
							.multilineTextAlignment(.trailing)
							.background(Color.white)
							.cornerRadius(15)
					}
					.frame(width: 350)
					.padding()
					.background(Color.red)
					.cornerRadius(25)
				}
			}
			.background(Color.green)
			
		}
	}
}

struct GraphView_Previews: PreviewProvider {
	static var previews: some View {
		GraphView()
	}
}
