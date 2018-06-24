import Result

extension HTTPConnectable {

  public static func GET(fromEndpoint   endpoint  : String?          = nil,
                         headers                  : Headers          = [.contentType : .applicationJSON],
                         withParameters parameters: [String: String] = [:],
                         andThen                  : @escaping (Result<Data, HTTPConnectableErrorBox>) -> Void) {

    handleTransmit(headers   : headers,
                   toEndpoint: endpoint,
                   parameters: parameters,
                   httpMethod: .GET,
                   andThen   : andThen)
  }

  public static func POST(data                     : Data,
                          headers                  : Headers          = [.contentType : .applicationJSON],
                          toEndpoint     endpoint  : String?          = nil,
                          withParameters parameters: [String: String] = [:],
                          andThen                  : @escaping (Result<Data, HTTPConnectableErrorBox>) -> Void) {

    handleTransmit(data      : data,
                   headers   : headers,
                   toEndpoint: endpoint,
                   parameters: parameters,
                   httpMethod: .POST,
                   andThen   : andThen)
  }

  static func handleTransmit(data      : Data? = nil,
                             headers   : Headers,
                             toEndpoint: String? = nil,
                             parameters: [String: String],
                             httpMethod: HTTPMethod,
                             andThen   : @escaping (Result<Data, HTTPConnectableErrorBox>) -> Void) {

    transmit(data          : data,
             with          : headers,
             parameters    : parameters,
             toEndpoint    : toEndpoint,
             withHTTPMethod: httpMethod,
             andThen       : andThen)
  }

  static func transmit(data                   : Data? = nil,
                       with           headers : Headers,
                       parameters             : [String: String],
                       toEndpoint     endpoint: String?,
                       withHTTPMethod method  : HTTPMethod,
                       andThen        then    : @escaping (Result<Data, HTTPConnectableErrorBox>) -> Void) {
    do {
      let query = try parameters.queryString()
      var path = self.root

      path += query

      guard let baseURL = URL(string: path) else { throw NetworkError.invalidURL(path) }
      guard let scheme  = baseURL.scheme else { throw NetworkError.invalidURL(path) }
      guard let host    = baseURL.host else { throw NetworkError.invalidURL(path) }
      guard var url     = URL(string: "\(scheme)://\(host)") else { throw NetworkError.invalidURL(path) }

      if let port     = self.port { url.appendPathComponent(":\(port)") }
      if let endpoint = endpoint { url.appendPathComponent(endpoint) }

      let config  = self.configuration
      let session = URLSession(configuration: config)
      var request = URLRequest(url: url)

      request.httpMethod = method.rawValue
      request.httpBody   = data

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

          guard let data = data else { throw NetworkError.emptyResponse(url.absoluteString) }
          guard data.count > 0  else { throw NetworkError.emptyResponse(url.absoluteString) }
          then(Result(data))

        } catch {
          if let error = error as? NetworkError {
            then(Result(error: .networkFailure(error)))
          } else {
            fatalError("\(error)")
          }
        }
      })

      task.resume()

    } catch {
      if let error = error as? NetworkError {
        then(Result(error: .networkFailure(error)))
      } else {
        fatalError("\(error)")
      }
    }
  }
}
