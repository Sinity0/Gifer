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

class AlamofireManager {

    private let url = Constants.url
    private let apiKey = Constants.apiKey

//    func fetchTrendingGifs(limit: Int, offset: Int, completion:@escaping (Result< [GifsModel] >) -> () ){
//
//        let parameters = [
//            "api_key": apiKey,
//            "limit": limit,
//            "offset": offset
//            ] as [String : Any]
//
//        Alamofire.request(url + "v1/gifs/trending", method: .get, parameters: parameters, encoding: URLEncoding.default).responseJSON( completionHandler: { response in
//
//
//            switch response.result {
//
//            case .failure(let error):
//                print(error)
//                completion(.failure(error))
//            case .success(let value):
//
//                let gifJson = JSON(value)
//
//                //print(gifJson)
//                if let gifData = gifJson["data"].array {
//                    var gifs = [GifsModel]()
//                    for gif in gifData {
//                        let gf = GifsModel(data: gif)
//                        gifs.append(gf)
//                    }
//                    completion(.success(gifs))
//                }
//            }
//        })
//    }

    func fetchTrendingGifs(limit: Int,
                           offset: Int,
                           completion:@escaping (_ gifs: [GifsModel]?,
                                                _ total: Int?,
                                                _ error: String?) -> Void) {

        let parameters = [
            "api_key": apiKey,
            "limit": limit,
            "offset": offset
            ] as [String : Any]

        Alamofire.request(url + "v1/gifs/trending",
                          method: .get,
                          parameters: parameters,
                          encoding: URLEncoding.default).responseJSON( completionHandler: { response in

            switch response.result {
                case .success(let value):
                    let gifJson = JSON(value)
                    var total = 0

                    if let pagination = gifJson["pagination"].dictionary {
                        if let totalcount = pagination["count"]?.int {
                            total = totalcount
                        }
                    }
                    if let gifData = gifJson["data"].array {
                        var gifs = [GifsModel]()
                        for gif in gifData {
                            let gf = GifsModel(data: gif)
                            gifs.append(gf)
                        }
                        completion(gifs, total, nil)
                    }

                case .failure(let error):
                    completion(nil, nil, error.localizedDescription)
            }
        })
    }

    func fetchSearchGifs(searchStr: String, limit: Int, offset: Int, rating: String?, completionHandler:@escaping (_ gifs: [GifsModel]?, _ total: Int?, _ error: String?) -> Void) {
        var ratingStr: String = ""
        if let rating = rating {
            ratingStr = rating
        }

        let parameters = [
            "api_key": apiKey,
            "limit": limit,
            "offset": offset,
            "rating": ratingStr,
            "q": searchStr
            ] as [String : Any]

        Alamofire.request(url + "v1/gifs/search", method: .get, parameters: parameters, encoding: URLEncoding.default, headers: nil).responseJSON(completionHandler: { response in

            switch response.result {
            case .success(let result):

                let resultJSON = JSON(result)
                var total: Int?

                if let pagination = resultJSON["pagination"].dictionary {
                    if let totalcount = pagination["total_count"]?.int {
                        total = totalcount
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

