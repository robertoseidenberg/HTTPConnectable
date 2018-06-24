import Result

extension Data {

  public func decode<T: Decodable>() -> Result<T, HTTPConnectableErrorBox> {

    do {
      let decoded = try JSONDecoder().decode(T.self, from: self)
      return Result(decoded)

    } catch {
      return Result(error: HTTPConnectableErrorBox.jsonFailure(error))
    }
  }
}
