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

    typealias SearchGifsCompletion = (Result<[GifModel]>) -> Void

    func fetchTrendedGifs(limit: Int, offset: Int, completionHandler: @escaping SearchGifsCompletion) {

        request(url: Constants.urlTrending, parameters: getParameters(limit: limit, offset: offset)) { result -> Void in
            completionHandler(result)
        }
    }
    
    func searchGifs(searchTerm: String, rating: String, limit: Int, offset: Int,
                           completionHandler: @escaping SearchGifsCompletion) {

        request(url: Constants.urlSearch, parameters: getParameters(limit: limit, offset: offset, searchTerm: searchTerm, rating: rating)) { result -> Void in
            completionHandler(result)
        }
    }

    private func getParameters(limit: Int, offset: Int, searchTerm: String = "", rating: String = "") -> [String: Any] {
        let parameters: [String: Any] = [
            "api_key": Constants.apiKey,
            "limit": limit,
            "offset": offset,
            "rating": rating,
            "q": searchTerm
        ]
        return parameters
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
                                let gifs: [GifModel] = value.map { GifModel(data: $0)}
                                completion(.success(gifs))
                            }
        }
    }
}
