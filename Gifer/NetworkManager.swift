
import Foundation
import Alamofire
import SwiftyJSON
import AlamofireObjectMapper

public enum FeedType {
    case trending, search
}

class NetworkManager {

    private let apiKey = Constants.apiKey
    private let url = Constants.url

    public typealias SearchGifsCompletion = ( _ gifs: [GifModel]?, _ total: Int?, _ error: String?) -> Void

    public func fetchTrendedGifs(limit: Int,
                                 offset: Int,
                                 completionHandler: @escaping SearchGifsCompletion) {
        let url = Constants.url + "v1/gifs/trending"
        let parameters = [
            "api_key": apiKey,
            "limit": limit,
            "offset": offset
            ] as [String : Any]

        request(url: url, parameters: parameters, completion: { gifs, total, error -> Void in
            completionHandler(gifs, total, error)
        })
    }

    public func searchGifs(searchTerm: String,
                           rating: String? = nil,
                           limit: Int,
                           offset: Int,
                           completionHandler: @escaping SearchGifsCompletion) {
        let url = Constants.url + "v1/gifs/search"
        let parameters = [
            "api_key": apiKey,
            "limit": limit,
            "offset": offset,
            "rating": rating ?? "",
            "q": searchTerm
            ] as [String : Any]

        request(url: url, parameters: parameters, completion: { gifs, total, error -> Void in
            completionHandler(gifs, total, error)
        })
    }


    private func request(url: String, parameters: [String: Any], completion: @escaping SearchGifsCompletion){
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
                completion(gifs, total, nil)

            case .failure(let error):
                completion(nil, nil, error.localizedDescription)
            }
        }
    }
}

//import Foundation
//import Alamofire
//import SwiftyJSON
//import ObjectMapper
//import AlamofireObjectMapper
//
//public class NetworkManager {
//
//    public enum FeedType {
//        case trending, search
//    }
//
//    private let apiKey = Constants.apiKey
//
//    internal func fetchGifs(type: FeedType,
//                          limit: Int,
//                          offset: Int,
//                          rating: String?,
//                          searchStr: String?,
//                          completionHandler: @escaping ( _ gifs: [GifModel]?,
//                                                        _ total: Int?,
//                                                        _ error: String?) -> Void) {
//
//        var parameters: [String : Any] = [:]
//        var url = Constants.url
//
//        switch type {
//        case .search:
//            url += "v1/gifs/search"
//            parameters = [
//                "api_key": apiKey,
//                "limit": limit,
//                "offset": offset,
//                "rating": rating!,
//                "q": searchStr!
//                ] as [String : Any]
//        case .trending:
//            url += "v1/gifs/trending"
//            parameters = [
//                "api_key": apiKey,
//                "limit": limit,
//                "offset": offset
//                ] as [String : Any]
//        }
//
//
//        Alamofire.request(url,
//                          method: .get,
//                          parameters: parameters,
//                          encoding: URLEncoding.default).responseArray(keyPath: "data") { (response: DataResponse<[GifMapper]>) in
//
//            switch response.result {
//            case .success:
//                let gifArray: [GifMapper] = response.result.value ?? []
//                let total = gifArray.count
//
//                var gifs = [GifModel]()
//                for gif in gifArray {
//                    let a = GifModel(data: gif)
//                    gifs.append(a)
//                }
//                completionHandler(gifs, total, nil)
//
//            case .failure(let error):
//                completionHandler(nil, nil, error.localizedDescription)
//            }
//        }
//    }
//}

