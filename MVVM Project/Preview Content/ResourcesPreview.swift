//
//  ResourcesPreview.swift
//  MVVM Project
//
//  Created by Sergiu Corbu on 26.10.2022.
//

import SwiftUI

struct ColorsPreview: View {
    var body: some View {
        ZStack {
            Color(red: 0.5, green: 0.5, blue: 0.5).ignoresSafeArea()
            
            VStack(alignment: .leading, spacing: 5) {
                ForEach(Array(zip(Color.allColors, Color.colorNames.indices)), id: \.0) { color, index in
                    HStack {
                        color
                            .frame(width: 60, height: 60)
                        Text(Color.colorNames[index])
                            .font(.system(size: 20))
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                    }
                }
            }
        }
    }
}

struct FontsPreview: View {
    var body: some View {
        ScrollView {
            VStack(spacing: 10) {
                Text("Main h1 Regular with kern")
                    .font(kernedFont: .Main.h1RegularKerned)
                Text("Main Italic")
                    .font(.Main.italic())
                Text("Main h1 Medium with kern")
                    .font(kernedFont: .Main.h1MediumKerned)
                Text("Main h2 Medium with kern")
                    .font(kernedFont: .Main.h2MediumKerned)
                Text("Main p1 Regular with kern")
                    .font(kernedFont: .Main.p1RegularKerned)
                Text("Secondary p1 Regular with kern")
                    .font(kernedFont: .Secondary.p1RegularKerned)
                Text("Secondary p1 Bold with kern")
                    .font(kernedFont: .Secondary.p1BoldKerned)
                Text("Main p2 Regular with kern")
                    .font(kernedFont: .Main.p2RegularKerned)
                Text("Main p2 Medium with kern")
                    .font(kernedFont: .Main.p2MediumKerned)
                Text("Main p2 Medium with kern uppercased")
                    .font(kernedFont: .Main.p2MediumKerned)
                    .textCase(.uppercase)
            }
            VStack(spacing: 10) {
                Text("Secondary p1 Medium with kern uppercased")
                    .font(kernedFont: .Secondary.p1MediumKerned)
                    .textCase(.uppercase)
                Text("Secondary p1 Bold")
                    .font(.Secondary.p1Bold)
                Text("Secondary p1 Bold with kern")
                    .font(kernedFont: .Secondary.p1BoldKerned)
                Text("Secondary p2 Regular with kern")
                    .font(kernedFont: .Secondary.p2RegularKerned)
                Text("Secondary p2 Medium with kern")
                    .font(kernedFont: .Secondary.p3MediumKerned)
                Text("Secondary p2 Bold")
                    .font(.Secondary.p2Bold)
                Text("Secondary p3 Regular with kern")
                    .font(kernedFont: .Secondary.p3RegularKerned)
                Text("Secondary p3 Bold with kern")
                    .font(kernedFont: .Secondary.p3BoldKerned)
                Text("Secondary p4 Regular with kern")
                    .font(kernedFont: .Secondary.p4RegularKerned)
            }
        }
        .foregroundColor(.ebony)
    }
}

#if DEBUG
struct ResourcesPreview_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            ColorsPreview()
            FontsPreview()
        }
    }
}
#endif
