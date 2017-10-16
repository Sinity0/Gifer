
import Foundation
import Alamofire
import SwiftyJSON
import AlamofireObjectMapper

public enum FeedType {
    case trending, search
}

public enum Result<Value> {
    case success(Value)
    case failure(Error)
}

public class NetworkManager {
    
    private let apiKey = Constants.apiKey
    private let url = Constants.url

    typealias SearchGifsCompletion = (Result<[GifModel]>) -> Void
    
    
    func fetchTrendedGifs(limit: Int, offset: Int, completionHandler: @escaping SearchGifsCompletion) {
        
        let url = Constants.url + "v1/gifs/trending"
        let parameters: [String : Any] = [
            "api_key": apiKey,
            "limit": limit,
            "offset": offset
            ]
        
        request(url: url, parameters: parameters) { result -> Void in
            completionHandler(result)
        }
    }
    
    func searchGifs(searchTerm: String, rating: String, limit: Int, offset: Int,
                           completionHandler: @escaping SearchGifsCompletion) {
        
        let url = Constants.url + "v1/gifs/search"
        let parameters: [String : Any] = [
            "api_key": apiKey,
            "limit": limit,
            "offset": offset,
            "rating": rating,
            "q": searchTerm
            ]
        
        request(url: url, parameters: parameters) { result -> Void in
            completionHandler(result)
        }
    }
    
    private func request(url: String, parameters: [String: Any], completion: @escaping SearchGifsCompletion) {
        Alamofire.request(url,
                          method: .get,
                          parameters: parameters,
                          encoding: URLEncoding.default).responseArray(keyPath: "data") { (response: DataResponse<[GifMapper]>) in
                            
                            switch response.result {
                                
                            case .failure(let error):
                                completion(.failure(error))
                            case .success(let value):
                                
                                let gifArray: [GifMapper] = value

                                var gifs = [GifModel]()
                                for gif in gifArray {
                                    let a = GifModel(data: gif)
                                    gifs.append(a)
                                }
                                completion(.success(gifs))
                            }
        }
    }
}
