import Foundation

public enum NetworkError: Error {

  public typealias Description     = String
  public typealias UnterlyingError = Error

  // Errors invoked via HTTPConnectable
  case invalidURL              (Description)
  case invalidRequestParameters(Description)
  case emptyResponse           (Description)

  // Mapped error via NSURLSession
  case serverUnreachable   (UnterlyingError)
  case unexpectedResponse  (UnterlyingError)
  case authenticationFailed(UnterlyingError)
  case notConnected        (UnterlyingError)
  case other               (UnterlyingError)

  init(_ error: Error) {

    let error = error as NSError
    if error.domain == NSURLErrorDomain {
      switch error.code {
      case
      NSURLErrorTimedOut,
      NSURLErrorCannotFindHost,
      NSURLErrorCannotConnectToHost,
      NSURLErrorNetworkConnectionLost,
      NSURLErrorHTTPTooManyRedirects,
      NSURLErrorResourceUnavailable: self = .serverUnreachable(error)
      case
      NSURLErrorNotConnectedToInternet,
      NSURLErrorInternationalRoamingOff,
      NSURLErrorCallIsActive,
      NSURLErrorDataNotAllowed,
      NSURLErrorRequestBodyStreamExhausted: self = .notConnected(error)
      case
      NSURLErrorRedirectToNonExistentLocation,
      NSURLErrorBadServerResponse,
      NSURLErrorFileDoesNotExist,
      NSURLErrorFileIsDirectory,
      NSURLErrorZeroByteResource,
      NSURLErrorCannotDecodeRawData,
      NSURLErrorCannotDecodeContentData,
      NSURLErrorCannotParseResponse: self = .unexpectedResponse(error)
      case
      NSURLErrorUserCancelledAuthentication,
      NSURLErrorUserAuthenticationRequired,
      NSURLErrorNoPermissionsToReadFile,
      NSURLErrorSecureConnectionFailed,
      NSURLErrorServerCertificateHasBadDate,
      NSURLErrorServerCertificateUntrusted,
      NSURLErrorServerCertificateHasUnknownRoot,
      NSURLErrorServerCertificateNotYetValid,
      NSURLErrorClientCertificateRejected,
      NSURLErrorClientCertificateRequired: self = .authenticationFailed(error)
      default:
        self = .other(error)
      }

    } else {
      self = .other(error)
    }
  }

  init?(_ code: Int) {

    if code >= 400 && code < 500 {
      self = .authenticationFailed(NSError(domain: "", code: code, userInfo: nil))
    } else if code >= 500 && code < 600 {
      self = .serverUnreachable(NSError(domain: "", code: code, userInfo: nil))
    } else {
      return nil
    }
  }
}
