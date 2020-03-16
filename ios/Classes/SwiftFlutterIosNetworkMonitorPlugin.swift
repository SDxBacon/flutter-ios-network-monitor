import Flutter
import UIKit
import Network
import Reachability

struct NetInfo {
  let ip: String
  let netmask: String
}

enum NWMonitor {
  case reachability(Reachability)
  @available(iOS 12.0, *)
  case pathMonitor(NWPathMonitor)
}

enum MyFlutterErroCode {
  static let unavailable = "UNAVAILABLE"
}

public class SwiftFlutterIosNetworkMonitorPlugin: NSObject, FlutterPlugin, FlutterStreamHandler {
  private var monitor: NWMonitor?

  public static func register(with registrar: FlutterPluginRegistrar) {
    let instance = SwiftFlutterIosNetworkMonitorPlugin()
    let channel = FlutterMethodChannel(name: "plugin/flutter_ios_network_monitor",
                                       binaryMessenger: registrar.messenger())
    let eventChannel = FlutterEventChannel(name: "plugin/flutter_ios_network_monitor/notify",
                                           binaryMessenger: registrar.messenger())

    registrar.addMethodCallDelegate(instance, channel: channel)
    eventChannel.setStreamHandler(instance)
  }

  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    if (call.method == "getIPv4NetworkInfo") {
      let netinfo = getIFAddresses()
      result(netinfo)
    }
    else {
      result(nil)
    }
  }

  @available(iOS 12.0, *)
  func interfaceTypeToString(type: NWInterface.InterfaceType) -> String {
    switch (type) {
      case NWInterface.InterfaceType.wifi:
        return "wifi";
      case NWInterface.InterfaceType.cellular:
        return "cellular";
      case NWInterface.InterfaceType.wiredEthernet:
        return "wiredEthernet";
      case NWInterface.InterfaceType.other:
        return "other";
      default:
        return "other";
    }
  }

  public func onListen(withArguments arguments: Any?, eventSink events: @escaping FlutterEventSink) -> FlutterError? {
    if #available(iOS 12.0, *) {
      let _monitor = NWPathMonitor()
      _monitor.pathUpdateHandler = { path in
        let data = path.availableInterfaces.map({ interface -> String in
          print(interface.type)
          return self.interfaceTypeToString(type: interface.type)
        })
        events(data)
      }
      _monitor.start(queue: DispatchQueue.global())
      monitor = .pathMonitor(_monitor)
      return nil
    } else {
      //declare this property where it won't go out of scope relative to your listener
      let reachability = try! Reachability()

      reachability.whenReachable = { reachability in
        if reachability.connection == .wifi {
          print("Reachable via WiFi")
          events("wifi")
        } else if reachability.connection == .cellular {
          print("Reachable via Cellular")
          events("cellular")
        } else {
          print("No internet :-(")
          events("No internet")
        }
      }
      reachability.whenUnreachable = { _ in
        print("Not reachable")
        events("Not reachable")
      }

      do {
        try reachability.startNotifier()
        monitor = .reachability(reachability)
      } catch {
        print("Unable to start notifier")
        return FlutterError(code: MyFlutterErroCode.unavailable,
                            message: "unavailable",
                            details: nil
        )
      }
    }
    return nil
  }

  public func onCancel(withArguments arguments: Any?) -> FlutterError? {
    switch (monitor) {
    case .reachability(let reachability):
      reachability.stopNotifier()
      break
    case .pathMonitor(let monitor):
      monitor.cancel()
      break
    case .none:
      return FlutterError(code: MyFlutterErroCode.unavailable,
                          message: "unavailable",
                          details: nil)
    }

    monitor = nil
    return nil
  }

  // Get the local ip addresses used by this node
  func getIFAddresses() -> Dictionary<String, String> {
    var addresses = [NetInfo]()

    // Get list of all interfaces on the local machine:
    var ifaddr : UnsafeMutablePointer<ifaddrs>? = nil
    if getifaddrs(&ifaddr) == 0 {
      var ptr = ifaddr;

      while ptr != nil {
        let flags = Int32((ptr?.pointee.ifa_flags)!)
        var addr = ptr?.pointee.ifa_addr.pointee

        // Check for running IPv4 interfaces. Skip the loopback interface.
        if
          (flags & (IFF_UP|IFF_RUNNING|IFF_LOOPBACK)) == (IFF_UP|IFF_RUNNING)
          && addr?.sa_family == UInt8(AF_INET)
        {
          /**
           * sa_family == UInt8(AF_INET): IPv4
           * sa_family == UInt8(AF_INET6): IPv6
           */

          // Convert interface address to a human readable string:
          var hostname = [CChar](repeating: 0, count: Int(NI_MAXHOST))
          if (getnameinfo(&addr!, socklen_t((addr?.sa_len)!), &hostname, socklen_t(hostname.count),
                          nil, socklen_t(0), NI_NUMERICHOST) == 0) {
              if let address = String.init(validatingUTF8:hostname) {

                  var net = ptr?.pointee.ifa_netmask.pointee
                  var netmaskName = [CChar](repeating: 0, count: Int(NI_MAXHOST))
                  getnameinfo(&net!, socklen_t((net?.sa_len)!), &netmaskName, socklen_t(netmaskName.count),
                              nil, socklen_t(0), NI_NUMERICHOST)// == 0
                  if let netmask = String.init(validatingUTF8:netmaskName) {
                      addresses.append(NetInfo(ip: address, netmask: netmask))
                  }
              }
          }

        }
        ptr = ptr?.pointee.ifa_next
      }
      freeifaddrs(ifaddr)
    }
    return Dictionary(uniqueKeysWithValues: addresses.map{ ($0.ip, $0.netmask) })
  }
}
