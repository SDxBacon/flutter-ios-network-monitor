#import "FlutterIosNetworkMonitorPlugin.h"
#if __has_include(<flutter_ios_network_monitor/flutter_ios_network_monitor-Swift.h>)
#import <flutter_ios_network_monitor/flutter_ios_network_monitor-Swift.h>
#else
// Support project import fallback if the generated compatibility header
// is not copied when this plugin is created as a library.
// https://forums.swift.org/t/swift-static-libraries-dont-copy-generated-objective-c-header/19816
#import "flutter_ios_network_monitor-Swift.h"
#endif

@implementation FlutterIosNetworkMonitorPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  [SwiftFlutterIosNetworkMonitorPlugin registerWithRegistrar:registrar];
}
@end
