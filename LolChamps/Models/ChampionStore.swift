//
//  ChampionStore.swift
//  LolChamps
//
//  Created by Foggin, Oliver (Developer) on 14/07/2020.
//  Copyright © 2020 Foggin, Oliver (Developer). All rights reserved.
//

import Foundation
import Combine
import Alamofire
import AlamofireImage
import SwiftUI

class ChampionRowViewModel: ObservableObject {
    let champion: Champion
    @Published var image: SwiftUI.Image = .init(systemName: "ellipsis")
    
    var cancellables = Set<AnyCancellable>()
    
    init(champion: Champion) {
        self.champion = champion
    }
    
    func fetchImage() -> Future<SwiftUI.Image, Never> {
        return Future { [self] p in
            
            AF.request("https://ddragon.leagueoflegends.com/cdn/10.13.1/img/champion/\(self.champion.name).png").responseImage { response in
                guard let image = response.value else {
                    p(.success(.init(systemName: "questionmark.square")))
                    return
                }
                
                p(.success(SwiftUI.Image(uiImage: image)))
            }
        }
    }
}

struct Champion: Decodable, Identifiable {
    let id: String
    let name: String
    let key: String
    let title: String
    let blurb: String
}

struct League: Decodable {
    let data: [String: Champion]
}

class LeagueViewModel: ObservableObject {
    @Published var champions: [Champion] = []
    
    let leagueStore: LeagueStore
    
    var cancellables = Set<AnyCancellable>()
    
    init(leagueStore: LeagueStore) {
        self.leagueStore = leagueStore
        
        leagueStore.$league
            .map { Array($0.data.values) }
            .sink(receiveValue: {
                self.champions = $0.sorted(by: { (c1, c2) in c1.name <= c2.name })
            })
            .store(in: &cancellables)
    }
}

class LeagueStore {
    @Published var league: League = League(data: [:])
    
    var cancellables = Set<AnyCancellable>()
    
    let fetcher = LeagueFetcher()
    
    init() {
        fetcher.fetch()
            .assign(to: \.league, on: self)
            .store(in: &cancellables)
    }
}

struct LeagueFetcher {
    let url = URL(string: "https://ddragon.leagueoflegends.com/cdn/10.13.1/data/en_US/champion.json")!
    
    func fetch() -> Future<League, Never> {
        return Future { p in
            AF.request(self.url).responseDecodable(of: League.self) { response in
                guard let league = response.value else {
                    p(.success(League(data: [:])))
                    return
                }
                
                p(.success(league))
            }
        }
    }
}
