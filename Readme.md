![Cookies!](docs/cookiemonster.png)

# HTTPConnectable

Swift µframework providing a thin protocol based network abstraction layer

### Usage

Use like so in your API wrapper:

```swift
import HTTPConnectable

protocol UserConvertible: HTTPConnectable, Decodable {
	var name: String { get }
}

extension UserConvertible {

	func login(email: String, password: String, andThen then: (UserConvertible?) -> Void) {
		
		// Given that your API returns JSON like so:
		// {"name": "Winnie-the-Pooh"}
		// "result contains" a readily populated "User" objects 
		Self.POST(json    : ["login" : email, "password": password],
                        toEndpoint: Endpoint.fragment("myapi/login"),
                        andThen   : { result in then(result) })
	}
}
```

Use like so in your client:
```swift
import HTTPConnectable

struct User: UserConvertible {
	let name: String
}

User.login(email: String, password: String, andThen: { user in
  print(user)
})
```
