//
//  ChampionRowView.swift
//  LolChamps
//
//  Created by Foggin, Oliver (Developer) on 14/07/2020.
//  Copyright © 2020 Foggin, Oliver (Developer). All rights reserved.
//

import SwiftUI

struct ChampionRowView: View {
    @ObservedObject var viewModel: ChampionRowViewModel
    
    let defaultImage = Image("ellipsis")
    
    var body: some View {
        HStack {
            viewModel.image
                .resizable()
                .frame(width: 40, height: 40, alignment: .center)
                .onAppear() { self.loadImage() }
            Text(viewModel.champion.name)
        }
    }
    
    func loadImage() {
        self.viewModel.fetchImage()
            .assign(to: \.image, on: self.viewModel)
            .store(in: &self.viewModel.cancellables)
    }
}

struct ChampionRowView_Previews: PreviewProvider {
    static var previews: some View {
        ChampionRowView(viewModel: ChampionRowViewModel(champion: Champion(
            id: "Aatrox",
            name: "Aatrox",
            key: "",
            title: "",
            blurb: ""))
        )
    }
}
