import Foundation

public enum HTTPTransport: String {
  case HTTP  = "http"
  case HTTPS = "https"
}

public enum Endpoint {
  case none
  case fragment(String)
  case url     (String)
}

enum HTTPMethod: String {
  case GET
  case POST
}

enum MimeType: String {
    case json = "application/json; charset=utf-8"
}

public typealias Headers = [String: String]

public struct Header {

  public enum Name: String {
    case contentType = "Content-Type"
    case accept = "Accept"
    }
}

public protocol HTTPConnectable {

  static var transport    : HTTPTransport           { get }
  static var root         : String                  { get }
  static var port         : Int?                    { get }
  static var headers      : Headers?                { get }
  static var configuration: URLSessionConfiguration { get }
}
