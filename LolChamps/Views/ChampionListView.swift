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
        NavigationView {
            List(viewModel.champions) { c in
                NavigationLink(destination: ChampionDetailView(viewModel: ChampionDetailViewModel(champion: c))) {
                    ChampionRowView(viewModel: ChampionRowViewModel(champion: c.summary))
                }
            }
            .navigationBarTitle("Champions")
        }
    }
}

struct ChampionListView_Previews: PreviewProvider {
    static var previews: some View {
        ChampionListView(viewModel: LeagueViewModel(leagueStore: LeagueStore()))
    }
}
