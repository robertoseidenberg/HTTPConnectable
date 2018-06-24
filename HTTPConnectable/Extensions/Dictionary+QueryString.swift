extension Dictionary where Key == String, Value == String {

  func queryString() throws -> String {

    var query = [String]()

    for (key, value) in self {

      var characterSet = CharacterSet.urlFragmentAllowed
      characterSet.remove(charactersIn: "!#$%&'*+-/=?^_`{|}~")

      if let escaped = value.addingPercentEncoding(withAllowedCharacters: characterSet) {
        query += [key + "=" + "\(escaped)"]
      } else {
        throw NetworkError.invalidRequestParameters(value)
      }
    }
    return (!query.isEmpty ? "?" : "") + query.joined(separator: "&")
  }
}
