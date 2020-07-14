//
//  ChampionListView.swift
//  LolChamps
//
//  Created by Foggin, Oliver (Developer) on 14/07/2020.
//  Copyright © 2020 Foggin, Oliver (Developer). All rights reserved.
//

import SwiftUI

struct ChampionListView: View {
    @ObservedObject var viewModel: LeagueViewModel
    
    var body: some View {
        List(viewModel.champions) { c in
            ChampionRowView(viewModel: ChampionRowViewModel(champion: c))
        }
    }
}

struct ChampionListView_Previews: PreviewProvider {
    static var previews: some View {
        ChampionListView(viewModel: LeagueViewModel(leagueStore: LeagueStore()))
    }
}
