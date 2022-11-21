# Show Routes Map -Flutter
 
# Add code in AppDelegate.swift

import GoogleMaps


@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {

  override func application(
  
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: 
    [UIApplication.LaunchOptionsKey: Any]?
  ) -> 
  Bool {
    GeneratedPluginRegistrant.register(with: self)
    
     GMSServices.provideAPIKey("Your Map Key")
     
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
    
  }
}

#Add code in info.plist

<key>NSLocationWhenInUseUsageDescription</key>

<string>This app needs access to location when open.</string>

<key>NSLocationAlwaysUsageDescription</key>

<string>This app needs access to location when in the background.</string>

    
# Android Mainfiest
    <uses-permission android:name="android.permission.ACCESS_FINE_LOCATION"/>
    <uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION" />
    <uses-permission android:name="android.permission.INTERNET"/>
    
    
 <meta-data android:name="com.google.android.geo.API_KEY"
 android:value="Api Key of Map"/>
 
 
 # podfile
 
  platform :ios, '13.0'
  
  
 
 # Dependency
 
  google_maps_flutter: ^2.2.1
  geolocator: ^8.2.0
  geocoding: ^2.0.4
