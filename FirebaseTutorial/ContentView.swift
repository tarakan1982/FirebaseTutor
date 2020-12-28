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
    @State var show = false
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
                    self.show.toggle()
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
        .sheet(isPresented: self.$show) {
            OrderView(data: self.data)
        }
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

struct OrderView: View {
    var data: category
    @State var cash = false
    @State var quick = false
    @State var quantity = 0
    @Environment(\.presentationMode) var presentation
    
    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            AnimatedImage(url: URL(string: data.pic)!)
                .resizable()
                .frame(height: UIScreen.main.bounds.height / 2 - 100)
            VStack(alignment: .leading, spacing: 25) {
                Text(data.name)
                    .fontWeight(.heavy)
                    .font(.title)
                Text("Цена: \(data.price) руб.")
                    .fontWeight(.heavy)
                    .font(.body)
                
                Toggle(isOn: $cash) {
                    Text("Оплата наличными")
                }
                Toggle(isOn: $quick) {
                    Text("Быстрая доставка")
                }
               Stepper(
                onIncrement: {
                    self.quantity += 1
                },
                onDecrement: {
                    if self.quantity != 0 {
                        self.quantity -= 1
                    }
                })
                 {
                    Text("Количество \(self.quantity)")
                }
                Button(action: {
                    let db = Firestore.firestore()
                    db.collection("cart")
                        .document()
                        .setData(["item":self.data.name, "quantity":self.quantity, "quickdelivery":self.quick, "cashondelivery":self.cash, "pic":self.data.pic]) { (err) in
                            if err != nil {
                                print((err?.localizedDescription)!)
                                return
                            }
                            self.presentation.wrappedValue.dismiss()
                        }
                }) {
                    Text("В корзину")
                        .padding(.vertical)
                        .frame(width: UIScreen.main.bounds.width - 30)
                }.background(Color.orange)
                .foregroundColor(.white)
                .cornerRadius(20)

            } .padding()
            Spacer()
        }
    }
}
