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
    
    @State var show = false
    
    var body: some View {
        ZStack {
            NavigationView {
            Home()
                .navigationBarTitle("Наше меню", displayMode: .inline)
                .navigationBarItems(trailing:
                                        Button(action: {
                                            self.show.toggle()
                                        }) {
                                            Image(systemName: "cart.fill")
                                                .font(.body)
                                                .foregroundColor(.black)
                                        }
                )
        }
            if self.show {
                GeometryReader {_ in
                    CartView()
                        .padding(.top, 100) //без этих паддинков, почему то всплывающее окно корзины находится сбоку
                        .padding(.leading, 50)
                }.background(Color.black.opacity(0.55).edgesIgnoringSafeArea(.all)
                
                                .onTapGesture {
                                    self.show.toggle()
                                }
                )
            }
        } .animation(.linear(duration: 1.0))
       
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
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
                        .foregroundColor(.white)
                        .padding(14)
                } .background(Color.orange)
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
struct CartView: View {
    @ObservedObject var cartdata = getCartData()
    
    var body: some View {
        VStack(alignment: .leading) {
            
            Text(self.cartdata.datas.count != 0 ? "Ваши заказы" : "Ваша корзина пуста").padding([.top, .leading])
                .foregroundColor(.white)
            
            if self.cartdata.datas.count != 0 {
                List(self.cartdata.datas) { i in
                    HStack(spacing: 15) {
                        AnimatedImage(url: URL(string: i.pic))
                            .resizable()
                            .frame(width: 55, height: 55)
                            .cornerRadius(10)
                        VStack(alignment: .leading) {
                            Text(i.name)
                            Text("Количество: \(i.quantity)")
                        }
                    }
                }
            }
        }.frame(width: UIScreen.main.bounds.width - 110, height: UIScreen.main.bounds.height - 350)
        .background(Color.orange)
        .cornerRadius(25)
    }
}
//Надо будет перенести этот класс
class getCartData: ObservableObject {
    @Published var datas = [cart]()
    init() {
        let db = Firestore.firestore()
        db.collection("cart").getDocuments { (snap, err) in
            if err != nil {
                print((err?.localizedDescription)!)
                return
            }
            for i in snap!.documents {
                let id = i.documentID
                let name = i.get("item") as! String
                let quantity = i.get("quantity") as! NSNumber
                let pic = i.get("pic") as! String
                
                self.datas.append(cart(id: id, name: name, quantity: quantity, pic: pic))
            }
        }
    }
}
struct cart: Identifiable {
    var id: String
    var name: String
    var quantity: NSNumber
    var pic: String
}
