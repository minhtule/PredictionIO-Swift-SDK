# PredictionIO Swift SDK

[![Build Status](https://travis-ci.org/minhtule/PredictionIO-Swift-SDK.svg?branch=master)](https://travis-ci.org/minhtule/PredictionIO-Swift-SDK)

The Swift SDK provides a convenient API for your iOS and macOS application to record your users' behaviors in the [PredictionIO](https://github.com/apache/predictionio) event server and retrieve predictions from PredictionIO engines.

## Requirements
- iOS 10+ or macOS 10.10+
- Xcode 11+
- Swift 5+
- PredictionIO 0.12.0+

## Installation

### Cocoapods
Install [CocoaPods](https://cocoapods.org/), the dependency manager for Cocoa project.
```bash
$ gem install cocoapods
```

To integrate PredictionIO, add the following lines to your `Podfile`.
```ruby
source 'https://github.com/CocoaPods/Specs.git'
platform :ios, '10.0'
use_frameworks!

target '<Your target name>' do
    pod 'PredictionIO', '~> 3.0'
end
```

Then run the following command.
```bash
$ pod install
```

Finally, import the SDK in your Swift files before using.
```swift
import PredictionIO
```

## Usage

### EngineClient
Use `EngineClient` to query predictions from the PredictionIO Engines.

```swift
// Response format of a Recommendation engine.
struct RecommendationResponse: Decodable {
    struct ItemScore: Decodable {
        let item: String
        let score: Double
    }

    let itemScores: [ItemScore]
}

let engineClient = EngineClient(baseURL: "http://localhost:8000")
let query = [
    "user": "1",
    "num": 2
]

engineClient.sendQuery(query, responseType: RecommendationResponse.self) { result in
    guard let response = result.value else { return }

    print(response.itemScores)
}
```

### EventClient
Use `EventClient` to send information to the PredictionIO Event Server.

```swift
let eventClient = EventClient(accessKey: "Access key of the app", baseURL: "http://localhost:7070")
let event = Event(
    event: "rate",
    entityType: "user",
    entityID: "1",
    targetEntity: (type: "item", id: "9"),
    properties: [
        "rating": 5
    ]
)

eventClient.createEvent(event) { result in
    guard let response = result.value else { return }

    print(response.eventID)
}
```

There are other convenience methods to manage User and Item entity types. Please see the [API documentation](http://minhtule.github.io/PredictionIO-Swift-SDK/index.html) for more details.

## Documentation

The documentation is generated by [jazzy](https://github.com/realm/jazzy). To build the documentation, run

```bash
$ jazzy
```

The latest API documentation is available at http://minhtule.github.io/PredictionIO-Swift-SDK/index.html.

## iOS Demo App
Please follow this [quick guide](http://predictionio.apache.org/templates/recommendation/quickstart/) to start the Event Server and set up a Recommendation Engine on your local machine first.

You also need to:
- Include your app's access key in `RatingViewController.swift`.
- Import some data using the python script as instructed in step 4. Alternatively, you can use the demo app to record new rating events; however, remember to re-train and deploy the engine before querying for recommendations.
- Run the simulator!

There are 2 screens in the demo app:
- **Rating**: corresponding to step *4. Collecting Data* in the quick guide.
- **Recommendation**: corresponding to step *6. Use the Engine* in the quick guide.

### Tapster iOS Demo

Also check out [Tapster iOS](https://github.com/minhtule/Tapster-iOS-Demo), a recommender for comics, to see a more extensive intergration of the SDK.

## License
PredictionIO Swift SDK is released under the Apache License 2.0. Please see
[LICENSE](https://github.com/minhtule/PredictionIO-Swift-SDK/blob/master/LICENSE) for details.
