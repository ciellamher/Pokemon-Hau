import 'dart:async';
import 'package:flutter/material.dart';
import 'package:pokemon_hau/core/services/admin_service.dart';
import 'package:pokemon_hau/core/widgets/mascot_card.dart';

class SystemStatusWrapper extends StatefulWidget {
  final Widget child;
  const SystemStatusWrapper({super.key, required this.child});

  @override
  State<SystemStatusWrapper> createState() => _SystemStatusWrapperState();
}

class _SystemStatusWrapperState extends State<SystemStatusWrapper> {
  final AdminService _adminService = AdminService();
  bool _isEc2Online = true;
  bool _isVpnOnline = true;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _checkStatus();
    // Poll every 10 seconds for simulation purposes
    _timer = Timer.periodic(const Duration(seconds: 10), (_) => _checkStatus());
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _checkStatus() async {
    final config = await _adminService.getAppConfig();
    if (mounted) {
      setState(() {
        _isEc2Online = config['ec2_server'] ?? true;
        _isVpnOnline = config['vpn_connection'] ?? true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    bool isOffline = !_isEc2Online || !_isVpnOnline;

    return Stack(
      children: [
        widget.child,
        if (isOffline)
          Positioned.fill(
            child: Container(
              color: Colors.black.withOpacity(0.85),
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 30),
                  child: MascotCard(
                    title: 'SYSTEM OFFLINE',
                    titleFontSize: 24,
                    child: SingleChildScrollView(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text(
                            'The following services are currently offline. Please contact an administrator.',
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 20),
                          _buildStatusRow('EC2 WEB SERVER', _isEc2Online),
                          const SizedBox(height: 10),
                          _buildStatusRow('VPN CONNECTION', _isVpnOnline),
                          const SizedBox(height: 30),
                          ElevatedButton(
                            onPressed: _checkStatus,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF2C3E1F),
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                                side: const BorderSide(color: Colors.black, width: 2),
                              ),
                              padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 12),
                            ),
                            child: const Text('RETRY CONNECTION', style: TextStyle(fontWeight: FontWeight.bold)),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildStatusRow(String label, bool isOnline) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w900)),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            color: isOnline ? const Color(0xFF67B569) : const Color(0xFFA50000),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: Colors.black, width: 1.5),
          ),
          child: Text(
            isOnline ? 'ONLINE' : 'OFFLINE',
            style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w900),
          ),
        ),
      ],
    );
  }
}
