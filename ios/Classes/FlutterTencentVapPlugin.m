#import "FlutterTencentVapPlugin.h"
#if __has_include(<flutter_tencent_vap/flutter_tencent_vap-Swift.h>)
#import <flutter_tencent_vap/flutter_tencent_vap-Swift.h>
#else
// Support project import fallback if the generated compatibility header
// is not copied when this plugin is created as a library.
// https://forums.swift.org/t/swift-static-libraries-dont-copy-generated-objective-c-header/19816
#import "flutter_tencent_vap-Swift.h"
#endif

@implementation FlutterTencentVapPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  [SwiftFlutterTencentVapPlugin registerWithRegistrar:registrar];
}
@end
