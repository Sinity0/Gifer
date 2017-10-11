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

class AlamofireManager {

    private let apiKey = Constants.apiKey

    func fetchGifs(type: FeedType,
                  limit: Int,
                 offset: Int,
                 rating: String?,
                 searchStr: String?,
      completionHandler: @escaping ( _ gifs: [GifsModel]?,
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
                        encoding: URLEncoding.default).responseJSON(completionHandler: { response in

            switch response.result {
                case .success(let result):

                    let resultJSON = JSON(result)
                    var total: Int?

                    if let pagination = resultJSON["pagination"].dictionary {
                        switch type {
                            case .search:
                                if let totalcount = pagination["total_count"]?.int {
                                    total = totalcount
                                }

                            case .trending:
                                if let totalcount = pagination["count"]?.int {
                                    total = totalcount
                                }
                        }
                    }

                    if let gifdata = resultJSON["data"].array {
                        var gifs = [GifsModel]()
                        for gifJSON in gifdata {
                            let gif = GifsModel(data: gifJSON)
                            gifs.append(gif)
                        }
                        completionHandler(gifs, total, nil)
                    } else {
                        completionHandler(nil, nil, "Something went wrong")
                    }
                case .failure(let error):
                    completionHandler(nil, nil, error.localizedDescription)
            }
        })
    }
}

