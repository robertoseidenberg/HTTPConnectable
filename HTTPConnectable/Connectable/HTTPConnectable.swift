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


public typealias Headers = [Header.Name: Header.Value]

public struct Header {

  public enum Name: String {
    case contentType = "Content-Type"
  }

  public enum Value: String {
    case applicationJSON = "application/json"
  }
}

public protocol HTTPConnectable {

  static var transport    : HTTPTransport           { get }
  static var root         : String                  { get }
  static var port         : Int?                    { get }
  static var headers      : Headers?                { get }
  static var configuration: URLSessionConfiguration { get }
}

extension HTTPConnectable {

  public static var transport: HTTPTransport {
    return .HTTP
  }

  public static var root: String {
    return "127.0.0.1"
  }

  public static var port: Int? {
    return nil
  }

  public static var headers: Headers? {
    return nil
  }

  public static var configuration: URLSessionConfiguration {
    return URLSessionConfiguration.default
  }
}
