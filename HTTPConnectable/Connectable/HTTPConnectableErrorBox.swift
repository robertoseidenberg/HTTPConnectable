public enum HTTPConnectableErrorBox: Error {

  case networkFailure(NetworkError)
  case jsonFailure(Error)

  init(_ error: NetworkError) {
    self = .networkFailure(error)
  }
}
