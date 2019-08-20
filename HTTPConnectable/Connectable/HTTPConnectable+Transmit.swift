import Foundation

extension HTTPConnectable {
    
    public static func GET(fromEndpoint   endpoint  : Endpoint         = .none,
                           headers                  : Headers          = [:],
                           withParameters parameters: [String: String] = [:],
                           contentType              : String           = "application/json; charset=utf-8",
                           accept                   : String           = "application/json; charset=utf-8",
                           andThen                  : @escaping (Result<Data, HTTPConnectableErrorBox>) -> Void) {
        
        transmit(data          : nil,
                 with          : headers,
                 parameters    : parameters,
                 toEndpoint    : endpoint,
                 withHTTPMethod: .GET,
                 contentType   : contentType,
                 accept        : accept,
                 andThen       : andThen)
    }
    
    public static func POST(data                     : Data,
                            headers                  : Headers          = [:],
                            toEndpoint     endpoint  : Endpoint         = .none,
                            withParameters parameters: [String: String] = [:],
                            contentType              : String           = "application/json; charset=utf-8",
                            accept                   : String           = "application/json; charset=utf-8",
                            andThen                  : @escaping (Result<Data, HTTPConnectableErrorBox>) -> Void) {
        
        transmit(data          : data,
                 with          : headers,
                 parameters    : parameters,
                 toEndpoint    : endpoint,
                 withHTTPMethod: .POST,
                 contentType   : contentType,
                 accept        : accept,
                 andThen       : andThen)
    }
    
    static func transmit(data                   : Data? = nil,
                         with           headers : Headers,
                         parameters             : [String: String],
                         toEndpoint     endpoint: Endpoint,
                         withHTTPMethod method  : HTTPMethod,
                         contentType            : String,
                         accept                 : String,
                         andThen        then    : @escaping (Result<Data, HTTPConnectableErrorBox>) -> Void) {
        do {
            
            var requestURL: URL
            
            switch endpoint {
            case .none:
                requestURL = try url(withFragment: nil, parameters: parameters)
                
            case .url(let string):
                guard let url = URL(string: string) else { throw NetworkError.invalidURL(string) }
                requestURL    = url
                
            case .fragment(let fragment):
                requestURL = try url(withFragment: fragment, parameters: parameters)
            }
            
            let config  = self.configuration
            let session = URLSession(configuration: config)
            var request = URLRequest(url: requestURL)
            
            request.httpMethod = method.rawValue
            request.httpBody   = data
            
            request.setValue(contentType, forHTTPHeaderField: Header.Name.contentType.rawValue)
            request.setValue(accept,      forHTTPHeaderField: Header.Name.accept.rawValue)
            
            let task = session.dataTask(with: request, completionHandler: { data, response, error in
                
                do {
                    if let error = error {
                        throw NetworkError(error)
                    }
                    
                    // Bail early in case the response contains no usable JSON
                    if let data = data {
                        do {
                            _ = try JSONSerialization.jsonObject(with: data)
                        } catch {
                            if let response = response as? HTTPURLResponse, let err = NetworkError(response.statusCode) {
                                throw NetworkError(err)
                            }
                        }
                    }
                    
                    guard let data = data else { throw NetworkError.emptyResponse(requestURL.absoluteString) }
                    guard data.count > 0  else { throw NetworkError.emptyResponse(requestURL.absoluteString) }
                    then(.success(data))
                    
                } catch {
                    if let error = error as? NetworkError {
                        then(.failure(.networkFailure(error)))
                    } else {
                        fatalError("\(error)")
                    }
                }
            })
            
            task.resume()
            
        } catch {
            if let error = error as? NetworkError {
                then(.failure(.networkFailure(error)))
            } else {
                fatalError("\(error)")
            }
        }
    }
}
