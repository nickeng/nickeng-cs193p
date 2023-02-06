//
//  StripedView.swift
//  Set
//
//  Created by Eng, Nick on 2/5/23.
//

import SwiftUI

struct StripedView: View {
    var body: some View {
        GeometryReader { proxy in
           HStack(spacing: 4) {
                ForEach(0..<Int(proxy.size.width) / 4, id: \.self) { index in
                    Rectangle().frame(width: 1)
                }
            }
        }
    }
}

struct StripedView_Previews: PreviewProvider {
    static var previews: some View {
      StripedView().foregroundColor(.blue)
    }
}
