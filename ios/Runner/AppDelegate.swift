import UIKit
import Flutter
import GoogleMaps
import MapKit

@main
@objc class AppDelegate: FlutterAppDelegate {
  private let CHANNEL = "com.example.app/maps"

  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    let controller: FlutterViewController = window?.rootViewController as! FlutterViewController
    let mapChannel = FlutterMethodChannel(name: CHANNEL, binaryMessenger: controller.binaryMessenger)
    
    mapChannel.setMethodCallHandler { (call: FlutterMethodCall, result: @escaping FlutterResult) -> Void in
    if call.method == "openMap" {
      if let args = call.arguments as? [String: String],
        let location1 = args["location1"],
        let location2 = args["location2"] {
          self.openAppleMap(location1: location1, location2: location2)
          result(nil)
        } else {
          result(FlutterError(code: "ERROR", message: "Arguments are missing", details: nil))
        }
      } else if call.method == "openSingleMap" {
        if let args = call.arguments as? [String: String],
           let location = args["location"] {
          self.openSingleMap(location: location) // Opens only one location
          result(nil)
        } else {
          result(FlutterError(code: "INVALID_ARGUMENT", message: "Location argument is missing", details: nil))
        }
      } else {
        result(FlutterMethodNotImplemented)
      }
    }

    GMSServices.provideAPIKey("AIzaSyDz92Bgq4J9TRG87K_sGfgLHYB_gR68BoY")
    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

    private func openAppleMap(location1: String, location2: String) {
    let coordinate1 = CLLocationCoordinate2D(latitude: Double(location1.split(separator: ",")[0])!,
                                              longitude: Double(location1.split(separator: ",")[1])!)
    let coordinate2 = CLLocationCoordinate2D(latitude: Double(location2.split(separator: ",")[0])!,
                                              longitude: Double(location2.split(separator: ",")[1])!)

    let placemark1 = MKPlacemark(coordinate: coordinate1, addressDictionary: ["Name": "Park N Jet Lot-1, SeaTac Airport Parking"])
    let placemark2 = MKPlacemark(coordinate: coordinate2, addressDictionary: ["Name": "Park N Jet Lot-2, SeaTac Airport Parking"])

    let mapItem1 = MKMapItem(placemark: placemark1)
    let mapItem2 = MKMapItem(placemark: placemark2)

            // Provide names for the locations
        mapItem1.name = "Park N Jet Lot-1, SeaTac Airport Parking"
        mapItem2.name = "Park N Jet Lot-2, SeaTac Airport Parking"

    let mapItems = [mapItem1, mapItem2]
    MKMapItem.openMaps(with: mapItems, launchOptions: nil)
  }

  // Function to open Apple Maps for a single location without directions
  private func openSingleMap(location: String) {
      let coordinates = self.locationStringToCLLocation(locationString: location)
      var name: String = ""

      // Check the location coordinates and set the appropriate name
      if location == "47.43913773817353, -122.32347728049845" {
          name = "Park N Jet Lot-1, SeaTac Airport Parking"
      } else if location == "47.47791718815681, -122.31643312461328" {
          name = "Park N Jet Lot-2, SeaTac Airport Parking"
      } else {
          name = "Park N Jet, SeaTac Airport Parking" // Default name if location doesn't match
      }

      let mapItem = MKMapItem(placemark: MKPlacemark(coordinate: coordinates))
      mapItem.name = name
      
      // Open the single location in Apple Maps without directions
      mapItem.openInMaps(launchOptions: nil) // No options, so no directions
  }

  // Helper function to convert a location string (lat, long) to CLLocationCoordinate2D
  private func locationStringToCLLocation(locationString: String) -> CLLocationCoordinate2D {
    let coordinatesArray = locationString.split(separator: ",")
    let lat = Double(coordinatesArray[0]) ?? 0.0
    let lon = Double(coordinatesArray[1]) ?? 0.0
    return CLLocationCoordinate2D(latitude: lat, longitude: lon)
  }
}
