//
//  CardService.swift
//  Mtg Cards
//
//  Created by alexander on 07.03.2020.
//  Copyright © 2020 alexander. All rights reserved.
//

import Foundation

protocol CardService {
    typealias CardCompletion = ([Card]?) -> Void
    func getCards(completion: @escaping CardCompletion)
    func getMoreCards(completion: @escaping CardCompletion)
}

final class CardServiceImpl: CardService {
    private let baseURL = "https://api.scryfall.com/cards"
    private var nextPage: URL?
    
    func getCards(completion: @escaping CardCompletion) {
        guard let url = URL(string: baseURL) else {
            completion(nil)
            return
        }
        getCards(url: url, completion: completion)
    }
    
    func getMoreCards(completion: @escaping CardCompletion) {
        guard let url = nextPage else {
            completion(nil)
            return
        }
        getCards(url: url, completion: completion)
    }
    
    private func getCards(url: URL, completion: @escaping CardCompletion) {
        URLSession.shared.dataTask(with: url){ data, response, error in
            guard let data = data, error == nil else {
                completion(nil)
                return
            }
            
            var page: CardPage<Card>? = nil
            do
            {
                let decoder = JSONDecoder()
                decoder.keyDecodingStrategy = .convertFromSnakeCase
                page = try decoder.decode(CardPage<Card>.self, from: data)
            }
            catch let error {
                print(error.localizedDescription)
            }
                self.nextPage = URL(string: page?.nextPage ?? "")
            completion(page?.data)
        }
    .resume()
    }
}
