import 'dart:io';

abstract class NetworkUtils {
  /// Returns the device's local WiFi/LAN IPv4 address.
  /// Filters for private RFC 1918 addresses to avoid picking up
  /// cellular, VPN, or tunnel interfaces.
  static Future<String?> getLocalIpAddress() async {
    try {
      final interfaces = await NetworkInterface.list(
        type: InternetAddressType.IPv4,
        includeLinkLocal: false,
      );

      // First pass: prefer private IPs (WiFi/LAN)
      for (final interface in interfaces) {
        for (final addr in interface.addresses) {
          if (_isPrivateIp(addr.address)) {
            return addr.address;
          }
        }
      }

      // Fallback: any non-loopback IP
      for (final interface in interfaces) {
        for (final addr in interface.addresses) {
          if (!addr.isLoopback) {
            return addr.address;
          }
        }
      }
    } catch (_) {}
    return null;
  }

  /// Checks if an IPv4 address is in a private RFC 1918 range:
  /// 10.0.0.0/8, 172.16.0.0/12, 192.168.0.0/16
  static bool _isPrivateIp(String ip) {
    final parts = ip.split('.');
    if (parts.length != 4) return false;
    final a = int.tryParse(parts[0]) ?? -1;
    final b = int.tryParse(parts[1]) ?? -1;
    if (a == 10) return true;
    if (a == 172 && b >= 16 && b <= 31) return true;
    if (a == 192 && b == 168) return true;
    return false;
  }
}
