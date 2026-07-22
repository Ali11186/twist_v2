import 'dart:io';

class VpnDetector {
  static Future<bool> isVpnConnected() async {
    try {
      // طريقة 1: فحص NetworkInterface
      final interfaces = await NetworkInterface.list();
      
      for (var interface in interfaces) {
        final name = interface.name.toLowerCase();
        
        // فحص أسماء واجهات الـ VPN الشهيرة
        if (name.contains('tun') ||
            name.contains('tap') ||
            name.contains('ppp') ||
            name.contains('pptp') ||
            name.contains('l2tp') ||
            name.contains('openvpn') ||
            name.contains('wireguard') ||
            name.contains('utun') ||
            name.contains('wintun')) {
          return true;
        }
      }
      
      return false;
    } catch (e) {
      print('VPN Detection Error: $e');
      return false;
    }
  }

  static Future<bool> checkAndPrevent() async {
    final isVpn = await isVpnConnected();
    return isVpn;
  }
}
