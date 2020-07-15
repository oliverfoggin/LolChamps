//
//  ChampionSkinCarousel.swift
//  LolChamps
//
//  Created by Foggin, Oliver (Developer) on 15/07/2020.
//  Copyright © 2020 Foggin, Oliver (Developer). All rights reserved.
//

import SwiftUI

struct ChampionSkinCarousel: View {
    @ObservedObject var viewModel: ChampionSkinCarouselViewModel
    let gradientStops = [
        Color.black.opacity(0.0),
        Color.black.opacity(0.2),
        Color.black.opacity(0.5),
        Color.black.opacity(0.6),
        Color.black.opacity(0.7),
        Color.black.opacity(0.85),
        Color.black.opacity(1.0),
    ]
    
    var body: some View {
        List(viewModel.skins) { skin in
            ZStack {
                if self.viewModel.images[skin.num] != nil {
                    Image(uiImage: self.viewModel.images[skin.num]!)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                } else {
                    Image(systemName: "ellipsis").onAppear {
                        self.viewModel
                            .fetchSkinImage(skin: skin)
                            .sink { self.viewModel.images[skin.num] = $0 }
                            .store(in: &self.viewModel.cancellables)
                    }
                }
                VStack {
                    Spacer()
                    Text(skin.name == "default" ? "" : skin.name)
                        .font(.system(.title))
                        .frame(maxWidth: .infinity)
                        .padding()
                        .foregroundColor(Color.white)
                        .background(LinearGradient(gradient: Gradient(colors: self.gradientStops), startPoint: .top, endPoint: .bottom))
                }
            }
            .frame(minWidth: 0, idealWidth: .infinity, maxWidth: .infinity, minHeight: 320, idealHeight: 320, maxHeight: 320, alignment: .center)
            .navigationBarTitle("\(self.viewModel.name) Skins")
        }
    }
}

