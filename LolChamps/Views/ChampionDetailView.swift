//
//  ChampionDetailView.swift
//  LolChamps
//
//  Created by Foggin, Oliver (Developer) on 14/07/2020.
//  Copyright © 2020 Foggin, Oliver (Developer). All rights reserved.
//

import SwiftUI

struct ChampionDetailView: View {
    
    @ObservedObject var viewModel: ChampionDetailViewModel
    
    var body: some View {
        VStack {
            if viewModel.detail == nil {
                Image(systemName: "ellipsis")
                    .font(.system(.largeTitle))
            } else {
                NavigationLink(destination: ChampionSkinCarousel(viewModel: ChampionSkinCarouselViewModel(name: self.viewModel.summary.name, skins: self.viewModel.detail!.skins))) {
                    Text("Skins")
                }
            }
        }
        .navigationBarTitle(viewModel.summary.name)
    }
}

struct ChampionDetailView_Previews: PreviewProvider {
    static var previews: some View {
        ChampionDetailView(viewModel: ChampionDetailViewModel(champion: Champion(summary: ChampionSummary(id: "Aatrox", name: "Aatrox", key: "Aatrox", title: "Aatrox", blurb: "Aatrox"))))
    }
}
