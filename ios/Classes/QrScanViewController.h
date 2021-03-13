#import <Foundation/Foundation.h>
#import <Flutter/Flutter.h>
#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
NS_ASSUME_NONNULL_BEGIN

@interface QrScanViewController : NSObject<FlutterPlatformView>
@end

@interface QrScanViewFactory : NSObject <FlutterPlatformViewFactory>
- (instancetype)initWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar;
@end

NS_ASSUME_NONNULL_END
