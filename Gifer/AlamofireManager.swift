//
//  AlamofireManager.swift
//  Gifer
//
//  Created by Niar on 9/27/17.
//  Copyright © 2017 Niar. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON
import ObjectMapper
import AlamofireObjectMapper

class AlamofireManager {

    private let apiKey = Constants.apiKey

    func fetchGifs(type: FeedType,
                  limit: Int,
                 offset: Int,
                 rating: String?,
                 searchStr: String?,
      completionHandler: @escaping ( _ gifs: [GifModel]?,
                                    _ total: Int?,
                                    _ error: String?) -> Void) {

        var parameters: [String : Any] = [:] 
        var url = Constants.url

        switch type {
        case .search:
            url += "v1/gifs/search"
            parameters = [
                "api_key": apiKey,
                "limit": limit,
                "offset": offset,
                "rating": rating!,
                "q": searchStr!
                ] as [String : Any]
        case .trending:
            url += "v1/gifs/trending"
            parameters = [
                "api_key": apiKey,
                "limit": limit,
                "offset": offset
                ] as [String : Any]
        }


        Alamofire.request(url,
                          method: .get,
                          parameters: parameters,
                          encoding: URLEncoding.default).responseArray(keyPath: "data") { (response: DataResponse<[GifMapper]>) in

            switch response.result {
            case .success:
                let gifArray: [GifMapper] = response.result.value ?? []
                let total = gifArray.count

                var gifs = [GifModel]()
                for gif in gifArray {
                    let a = GifModel(data: gif)
                    gifs.append(a)
                }
                completionHandler(gifs, total, nil)

            case .failure(let error):
                completionHandler(nil, nil, error.localizedDescription)
            }
        }
    }
}

