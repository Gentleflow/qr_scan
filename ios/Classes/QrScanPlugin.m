#import "QrScanPlugin.h"
#import "QrScanViewController.h"

@implementation QrScanPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  QrScanViewFactory *viewFactory = [[QrScanViewFactory alloc] initWithRegistrar:registrar];
  [registrar registerViewFactory:viewFactory withId:@"tech.gentleflow.qr_scan.reader_view"];

  FlutterMethodChannel* channel = [FlutterMethodChannel
                                   methodChannelWithName:@"tech.gentleflow.qr_scan"
                                   binaryMessenger:[registrar messenger]];

  QrScanPlugin* instance = [[QrScanPlugin alloc] init];
  [registrar addMethodCallDelegate:instance channel:channel];
}

- (void)handleMethodCall:(FlutterMethodCall*)call result:(FlutterResult)result {
  if ([@"imgQrCode" isEqualToString:call.method]) {
          [self scanQRCode:call result:result];
      } else {
          result(FlutterMethodNotImplemented);
      }
}

- (void)scanQRCode:(FlutterMethodCall*)call result:(FlutterResult)result{
    NSString *path = call.arguments[@"file"];
    UIImage *image = [UIImage imageWithContentsOfFile:path];
    CIDetector *detector = [CIDetector detectorOfType:CIDetectorTypeQRCode context:nil options:@{ CIDetectorAccuracy : CIDetectorAccuracyHigh }];

    NSArray *features = [detector featuresInImage:[CIImage imageWithCGImage:image.CGImage]];
    if (features.count > 0) {
        CIQRCodeFeature *feature = [features objectAtIndex:0];
        NSString *qrData = feature.messageString;
        result(qrData);
    } else {
        result(NULL);
    }
}

@end
