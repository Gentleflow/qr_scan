# qr_scan

Flutter QR Scan Plugin.

- support qr scan
- support flashlight

### Getting Started
```dart
// Identify images
String data = await QrScan.imgScan(File);
// Add view
Container(
   child: QrReaderView(
     width: 300,
     height: 300,
     callback: (controller){
       controller.startScan((data,_){
         // scan success 
       });
       controller.stopScan();
       controller.setFlashlight();
     },
   ),
)
```

### For iOS 
add app's `info.list` file
```
<key>io.flutter.embedded_views_preview</key>
<true/>
// Camera
<key>NSCameraUsageDescription</key>
<string>Camera Permissions</string>
// Photo
<key>NSPhotoLibraryUsageDescription</key>
<string>Photo Gallery Permissions</string>
```

#### Specific use can be referred to [qr_scan_widget](https://github.com/Gentleflow/qr_scan/blob/master/example/lib/qr_scan_widget.dart)

