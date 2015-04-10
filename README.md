# PredictionIO Swift SDK

[![Build Status](https://travis-ci.org/minhtule/PredictionIO-Swift-SDK.svg?branch=master)]
(https://travis-ci.org/minhtule/PredictionIO-Swift-SDK)

The Swift SDK provides a convenient API for your iOS and OS X application to record your users' behaviors in the event server and retrieve predictions from PredictionIO engines.

## Requirements
- iOS 7.0+ or OS X 10.9+
- Xcode 6.1

## Installation

### Cocoapods
Only CocoaPods 0.36.0 beta (and rc1) supports Swift and embedded frameworks. So CocoaPods needs to be installed with the following command.
```bash
$ gem install cocoapods --pre
```

Add the following lines to your `Podfile`.
```ruby
# platform must be at least iOS 8.0 to use dynamic frameworks
platform :ios, '8.0'
use_frameworks!

pod 'PredictionIOSDK', :git => 'https://github.com/minhtule/PredictionIO-Swift-SDK.git'
```

Then run the following command.
```bash
$ pod install 
```

Finally, import the SDK in your Swift files before using.
```swift
import PredictionIOSDK
```

### Manually
You can just drag two files: `PredictionIOSDK.swift` and `Alamofire.swift` into your project. 

**Note** that `Alamofire.swift` has been slightly modified from the original; however, if you have already integrated the original `Alamofire.swift` file to your project, you don't need to include `Alamofire.swift` from this repo again.

## Usage

### EngineClient
Use `EngineClient` to query predictions from the PredictionIO Engines.

```swift
let engineClient = EngineClient(baseURL: "http://localhost:8000")
let query = [
    "user": 1,
    "num": 2
]
        
engineClient.sendQuery(query) { (request, response, JSON, error) in
    if let data = JSON as? [String: [[String: AnyObject]]] {
        ...
    }
    ...
}
```

### EventClient
Use `EventClient` to send information to the PredictionIO Event Server.

```swift
let eventClient = EventClient(accessKey: accessKey, baseURL: "http://localhost:7070")
let event = Event(
    event: "rate",
    entityType: "user",
    entityID: "1",
    targetEntityType: "item",
    targetEntityID: "9",
    properties: [
        "rating": 5
    ]
)

eventClient.createEvent(event) { (request, response, JSON, error) in
    ...
}
```

There are other convenient methods to modify user's or item's properties. Please see the [API documentation](http://minhtule.github.io/PredictionIO-Swift-SDK/index.html) for more details.

## Documentation
The latest API documentation is available at http://minhtule.github.io/PredictionIO-Swift-SDK/index.html.

## iOS Demo App
Please follow this [quick guide](http://docs.prediction.io/templates/recommendation/quickstart/) to start the Event Server and set up a Recommendation Engine on your local machine first.

You also need to:
- Include your app's access key in `DataCollectorViewController.swift`.
- Import some data using the python script as instructed in step 4b. Alternatively, you can use the demo app to record new rating events; however, remember to re-train and deploy the engine before querying for recommendations.
- Run the iPhone or iPad simulator!

There are 2 screens in the demo app:
- **Data Collector**: corresponding to step *4a. Collecting Data* in the quick guide.
- **Item Recommendation**: corresponding to step *6. Use the Engine* in the quick guide.

## License
PredictionIO Swift SDK is released under the Apache License 2.0. Please see
[LICENSE](https://github.com/minhtule/PredictionIO-Swift-SDK/blob/master/LICENSE) for details.

