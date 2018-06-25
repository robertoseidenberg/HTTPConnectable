extension HTTPConnectable {

  static func url(withFragment fragment: String? = nil, parameters: [String: String]) throws -> URL {

    guard root.count > 0 else { throw NetworkError.invalidURL(root) }

    let query  = try parameters.queryString()
    var path   = self.root
    path      += query

    var urlString = "\(transport.rawValue)://\(root)"
    if let port   = self.port { urlString = "\(transport.rawValue)://\(root):\(port)" }
    guard var url = URL(string: urlString) else { throw NetworkError.invalidURL(path) }

    if let fragment = fragment { url.appendPathComponent(fragment) }

    return url
  }
}
