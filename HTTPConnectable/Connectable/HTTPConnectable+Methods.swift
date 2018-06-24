import Result

extension HTTPConnectable {

  public static func GETJSON<Self: Decodable>(fromEndpoint   endpoint  : String,
                                              withParameters parameters: [String: String] = [:],
                                              andThen        then      : @escaping (Result<Self, HTTPConnectableErrorBox>) -> Void) {

    GET(fromEndpoint: endpoint, withParameters: parameters, andThen: { result in

      switch result {
      case .failure(let error):
        then(Result(error: error))

      case .success(let data) :

        do {
          let decoded = try JSONDecoder().decode(Self.self, from: data)
          then(Result(decoded))

        } catch {
          then(Result(error: HTTPConnectableErrorBox.jsonFailure(error)))
        }
      }
    })
  }
}
