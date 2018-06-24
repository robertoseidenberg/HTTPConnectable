import Result

extension HTTPConnectable {

  public static func GETJSON(fromEndpoint   endpoint  : String,
                             withParameters parameters: [String: String] = [:],
                             andThen        then      : @escaping (Result<Data, HTTPConnectableErrorBox>) -> Void) {

    GET(fromEndpoint: endpoint, withParameters: parameters, andThen: { result in

      switch result {
      case .failure(let error):
        then(Result(error: error))

      case .success(let data) :
        do {
          _ = try JSONSerialization.jsonObject(with: data)
          then(Result(data))
        } catch {
          then(Result(error: HTTPConnectableErrorBox.jsonFailure(error)))
        }
      }
    })
  }
}
