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
    let summary: ChampionSummary
    @Published var detail: ChampionDetail?
    
    var cancellables = Set<AnyCancellable>()
    
    init(champion: Champion) {
        self.summary = champion.summary
        
        LeagueFetcher.fetchChamp(champion.summary.name)
            .assign(to: \.detail, on: self)
            .store(in: &cancellables)
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

class ChampionSkinCarouselViewModel: ObservableObject {
    @Published var name: String
    @Published var skins: [ChampionSkin]
    @Published var images: [Int: UIImage] = [:]
    
    var cancellables = Set<AnyCancellable>()
    
    init(name: String, skins: [ChampionSkin]) {
        self.name = name
        self.skins = skins
    }
    
    func fetchSkinImage(skin: ChampionSkin) -> Future<UIImage?, Never> {
        return Future { [self] p in
            AF.request("http://ddragon.leagueoflegends.com/cdn/img/champion/splash/\(self.name)_\(skin.num).jpg").responseImage { response in
                guard let image = response.value else {
                    p(.success(nil))
                    return
                }
                
                p(.success(image))
            }
        }
    }
}

struct Champion: Identifiable {
    let id: String
    let summary: ChampionSummary
    var detail: ChampionDetail?
    
    init(summary: ChampionSummary) {
        self.id = summary.id
        self.summary = summary
    }
}

struct ChampionSkin: Decodable, Identifiable {
    enum State {
        case fetching
        case image(UIImage)
        case none
    }
    
    let id: String
    let name: String
    let num: Int
}

struct ChampionDetail: Decodable, Identifiable {
    let id: String
    let name: String
    let lore: String
    let skins: [ChampionSkin]
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
    @Published var champions: [Champion] = []
    
    let leagueStore: LeagueStore
    
    var cancellables = Set<AnyCancellable>()
    
    init(leagueStore: LeagueStore) {
        self.leagueStore = leagueStore
        
        leagueStore.$league
            .map { Array($0.data.values).map { c in Champion(summary: c) } }
            .sink { self.champions = $0.sorted(by: { (c1, c2) in c1.summary.name <= c2.summary.name }) }
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
    
    struct ChampionDetailContainer: Decodable {
        let data: [String: ChampionDetail]
    }
    
    static func fetchChamp(_ name: String) -> Future<ChampionDetail?, Never> {
        return Future { p in
            AF.request("\(self.baseURL)/champion/\(name).json").responseDecodable(of: ChampionDetailContainer.self) { response in
                guard let container = response.value,
                    let champion = container.data.values.first else {
                    p(.success(nil))
                    return
                }
                
                p(.success(champion))
            }
        }
    }
}
