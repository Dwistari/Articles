//
//  Endpoint.swift
//  Articles
//
//  Created by Dwistari on 15/04/25.
//

import Foundation

struct UrlConstants {
    static let baseURL = "https://api.spaceflightnewsapi.net"
}


enum Endpoint {
    case articles
    case detailArticles(id: Int)
    case blogs
    case detailBlogs(id: Int)
    case reports
    case detailReports(id: Int)
    
    var path: String {
        switch self {
        case .articles: return "/v4/articles"
        case .detailArticles(let id):  return "/v4/articles/\(id)"
        case .blogs: return "/v4/blogs"
        case .detailBlogs(let id): return "/v4/blogs\(id)"
        case .reports: return "/v4/reports"
        case .detailReports(let id): return "/v4/reports\(id)"
        }
    }
    
    var url: String {
        return UrlConstants.baseURL + path
    }
}
