//
//  Home.swift
//  FirebaseTutorial
//
//  Created by Дмитрий on 28.12.2020.
//

import SwiftUI

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


struct Home_Previews: PreviewProvider {
    static var previews: some View {
        Home()
    }
}
