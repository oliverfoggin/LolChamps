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

class ChampionDetailViewModel: ObservableObject {
    let champion: ChampionSummary
    
    var cancellables = Set<AnyCancellable>()
    
    init(champion: ChampionSummary) {
        self.champion = champion
    }
}

class ChampionRowViewModel: ObservableObject {
    let champion: ChampionSummary
    @Published var image: UIImage?
    
    var cancellables = Set<AnyCancellable>()
    
    init(champion: ChampionSummary) {
        self.champion = champion
    }
    
    @Published var fetchDone = false
    
    func fetchImage() -> Future<UIImage?, Never> {
        return Future { [self] p in
            
            AF.request("https://ddragon.leagueoflegends.com/cdn/10.13.1/img/champion/\(self.champion.name).png").responseImage { response in
                self.fetchDone = true
                
                guard let image = response.value else {
                    p(.success(nil))
                    return
                }
                
                p(.success(image))
            }
        }
    }
}

struct ChampionDetail: Decodable, Identifiable {
    let id: String
    let name: String
}

struct ChampionSummary: Decodable, Identifiable {
    let id: String
    let name: String
    let key: String
    let title: String
    let blurb: String
}

struct League: Decodable {
    let data: [String: ChampionSummary]
}

class LeagueViewModel: ObservableObject {
    @Published var champions: [ChampionSummary] = []
    
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
    
    init() {
        LeagueFetcher.fetchAllChamps()
            .assign(to: \.league, on: self)
            .store(in: &cancellables)
    }
}

struct LeagueFetcher {
    static let baseURL = "https://ddragon.leagueoflegends.com/cdn/10.13.1/data/en_US"
    
    static func fetchAllChamps() -> Future<League, Never> {
        return Future { p in
            AF.request("\(self.baseURL)/champion.json").responseDecodable(of: League.self) { response in
                guard let league = response.value else {
                    p(.success(League(data: [:])))
                    return
                }
                
                p(.success(league))
            }
        }
    }
    
    static func fetchChamp(_ name: String) -> Future<ChampionDetail, Never> {
        return Future { p in
            AF.request("\(self.baseURL)/champion.json").responseDecodable(of: ChampionDetail.self) { response in
                guard let league = response.value else {
                    p(.success(ChampionDetail(id: "", name: "")))
                    return
                }
                
                p(.success(league))
            }
        }
    }
}
