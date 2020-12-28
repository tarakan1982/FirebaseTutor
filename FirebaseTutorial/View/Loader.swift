//
//  Loader.swift
//  FirebaseTutorial
//
//  Created by Дмитрий on 28.12.2020.
//

import SwiftUI
import Firebase

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

struct Loader_Previews: PreviewProvider {
    static var previews: some View {
        Loader()
    }
}
