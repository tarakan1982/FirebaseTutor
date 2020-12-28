//
//  ContentView.swift
//  FirebaseTutorial
//
//  Created by Dmitriy Borisov on 25.12.2020.
//

import SwiftUI
import Firebase
import SDWebImageSwiftUI

struct ContentView: View {
    var body: some View {
        NavigationView {
        Home()
            .navigationBarTitle("Наше меню", displayMode: .inline)
            .navigationBarItems(trailing:
                                    Button(action: {
                                        
                                    }) {
                                        Image(systemName: "cart.fill")
                                            .font(.body)
                                            .foregroundColor(.black)
                                    }
            )
    }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

struct Home: View {
    
    @ObservedObject var categories = getCategoriesData()
    
    var body: some View {
        VStack {
            if self.categories.datas.count != 0 {
                ScrollView(.vertical, showsIndicators: false) {
                    VStack(spacing: 15) {
                        ForEach(self.categories.datas) { i in
                            CellView(data: i)
                        }
                        
                    } .padding()
                    
                }.background(Color("Color").edgesIgnoringSafeArea(.all))
            }
            else {
                Loader()
            }
        }
    }
}
struct CellView: View {
    var data: category
    var body: some View {
        VStack {
            AnimatedImage(url: URL(string: data.pic))
                .resizable()
                .frame(height: 270)
            HStack {
                VStack(alignment: .leading) {
                    Text(data.name)
                        .font(.title)
                        .fontWeight(.heavy)
                    Text("\(data.price) руб.")
                        .fontWeight(.heavy)
                        .font(.body)
                }
                Spacer()
                Button(action: {
                    
                }) {
                    Image(systemName: "arrow.right")
                        .font(.body)
                        .foregroundColor(.black)
                        .padding(14)
                } .background(Color.yellow)
                .clipShape(Circle())
            }.padding(.horizontal)
            .padding(.bottom, 6)
        }.background(Color.white)
        .cornerRadius(20)
    }
}

struct Loader: UIViewRepresentable {
    func makeUIView(context: UIViewRepresentableContext<Loader>) -> UIActivityIndicatorView {
        let indicator = UIActivityIndicatorView(style: .large)
        indicator.startAnimating()
        return indicator
    }
    func updateUIView(_ uiView: UIActivityIndicatorView, context: UIViewRepresentableContext<Loader>) {
        
    }
}

class getCategoriesData: ObservableObject {
    @Published var datas = [category]()
    init() {
        let db = Firestore.firestore()
        
        db.collection("categories").addSnapshotListener { (snap, err) in
            if err != nil {
                print((err?.localizedDescription)!)
                return
            }
            for i in snap!.documentChanges {
                let id = i.document.documentID
                let name = i.document.get("name") as! String
                let price = i.document.get("price") as! String
                let pic = i.document.get("pic") as! String
                
                self.datas.append(category(id: id, name: name, price: price, pic: pic))
            }
        }
    }
}

struct category: Identifiable {
    var id: String
    var name: String
    var price: String
    var pic: String
}
