import Foundation

public extension HTTPConnectable where Self: Decodable {

    static func POST(json                     : JSON,
                     toEndpoint     endpoint  : Endpoint,
                     withParameters parameters: [String: String] = [:],
                     andThen        then      : @escaping (Result<Self, HTTPConnectableErrorBox>) -> Void) {
        
        do {
            Self.POST(data          : try JSONEncoder().encode(json),
                      toEndpoint    : endpoint,
                      withParameters: parameters,
                      andThen       : { result in
                switch result {
                case .failure(let error):
                    then(.failure(error))
                    
                case .success(let data) :
                    do {
                        let decoded = try JSONDecoder().decode(Self.self, from: data)
                        then(.success(decoded))
                        
                    } catch {
                        then(.failure(HTTPConnectableErrorBox.jsonFailure(error)))
                    }
                }
            })
            
        } catch {
            then(.failure(HTTPConnectableErrorBox.jsonFailure(error)))
        }
        
    }
    
    static func GETJSON(fromEndpoint   endpoint  : Endpoint,
                        withParameters parameters: [String: String] = [:],
                        andThen        then      : @escaping (Result<Self, HTTPConnectableErrorBox>) -> Void) {
        
        GET(fromEndpoint: endpoint, withParameters: parameters, andThen: { result in
            
            switch result {
            case .failure(let error):
                then(.failure(error))
                
            case .success(let data) :
                
                do {
                    let decoded = try JSONDecoder().decode(Self.self, from: data)
                    then(.success(decoded))
                    
                } catch {
                    then(.failure(HTTPConnectableErrorBox.jsonFailure(error)))
                }
            }
        })
    }
}
