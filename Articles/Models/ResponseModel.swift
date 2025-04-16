//
//  Article.swift
//  Articles
//
//  Created by Dwistari on 15/04/25.
//

import Foundation

struct ResponseModel: Decodable {
    let count: Int
    let next: String?
    let previous: String?
    let results: [ArticleModel]
}

struct ArticleModel: Decodable {
    let id: Int?
    let title: String?
    let authors: [Author]?
    let url: String?
    let image_url: String?
    let news_site: String?
    let summary: String?
    let published_at: String?
    let updated_at: String?
    let featured: Bool? // opsional
    let launches: [Launch]?
    let events: [Event]?
}

struct Author: Decodable {
    let name: String?
    let socials: Socials?
}

struct Socials: Decodable {
    let x: String?
    let youtube: String?
    let instagram: String?
    let linkedin: String?
    let mastodon: String?
    let bluesky: String?
}

struct Launch: Decodable {
    let id: String?
}

struct Event: Decodable {
    let id: String?
}
