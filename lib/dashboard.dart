import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:liquid_progress_indicator_v2/liquid_progress_indicator.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'sidebar.dart';
import 'email_alert.dart';

class DashboardPage extends StatefulWidget {
  final String username;
  final String email;

  const DashboardPage({super.key, required this.username, required this.email});

  @override
  _DashboardPageState createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  double litterLevel = 0.6; // Start full
  final double maxLitter = 0.6; // Full = 1.0 kg
  final double criticalLevel = 0.1;

  DateTime lastUpdated = DateTime.now();
  bool isConnected = false;
  bool _alertSent = false;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _loadSavedLitter();
    fetchWeight();
    _timer = Timer.periodic(const Duration(seconds: 2), (_) => fetchWeight());
  }

  Future<void> _loadSavedLitter() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      litterLevel = prefs.getDouble('litterLevel') ?? 1.0;
    });
  }

  Future<void> _saveLitter(double value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('litterLevel', value);
  }

  Future<void> fetchWeight() async {
    try {
      final response = await http
          .get(Uri.parse("http://10.195.250.63/get_weight.php"))
          .timeout(const Duration(seconds: 3));

      if (response.statusCode == 200) {
        final rawValue = double.tryParse(response.body.trim()) ?? 0.0;
        final newLitterLevel = (maxLitter - rawValue).clamp(0.0, maxLitter);

        setState(() {
          litterLevel = newLitterLevel;
          isConnected = true;
          lastUpdated = DateTime.now();
        });

        await _saveLitter(newLitterLevel);

        // ✅ Log shows computed value, not raw
        print("[FETCH SUCCESS] Value received: ${newLitterLevel.toStringAsFixed(2)} kg");

        if (litterLevel <= criticalLevel && !_alertSent) {
          EmailAlertService.sendAlert(widget.email);
          _alertSent = true;
          print("[ALERT] Low litter level alert sent!");
        } else if (litterLevel > criticalLevel) {
          _alertSent = false;
        }
      } else {
        print("[ERROR] HTTP ${response.statusCode}");
        setState(() => isConnected = false);
      }
    } catch (e) {
      print("[ERROR] Failed to fetch weight: $e");
      setState(() => isConnected = false);
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double percentage = (litterLevel / maxLitter).clamp(0.0, 1.0).toDouble();

    return Scaffold(
      backgroundColor: const Color(0xFFFFF8E7),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFFF8E7),
        elevation: 0,
        iconTheme: const IconThemeData(color: Color(0xFF5E412F)),
        title: Row(
          children: [
            Icon(Icons.pets, size: 26.sp, color: const Color(0xFF5E412F)),
            SizedBox(width: 8.w),
            Text(
              'Cat Litter Monitor',
              style: TextStyle(color: const Color(0xFF5E412F), fontSize: 18.sp),
            ),
          ],
        ),
      ),
      drawer: Sidebar(username: widget.username, email: widget.email),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.all(16.w),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildLiveWeightBanner(),
                SizedBox(height: 16.h),
                Text(
                  'Cat Litter Level',
                  style: TextStyle(
                    fontSize: (24.sp.clamp(16.0, 28.0)).toDouble(),
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF5E412F),
                  ),
                ),
                SizedBox(height: 20.h),
                SizedBox(
                  height: 0.5.sw,
                  width: 0.5.sw,
                  child: Stack(
                    children: [
                      Positioned.fill(child: SandParticleBackground()),
                      LiquidCircularProgressIndicator(
                        value: percentage > 0 ? percentage : 0.01,
                        valueColor: AlwaysStoppedAnimation(
                          litterLevel <= criticalLevel ? Colors.red : Colors.teal,
                        ),
                        backgroundColor: Colors.grey[300]!,
                        borderColor: Colors.teal,
                        borderWidth: 2.0,
                        direction: Axis.vertical,
                        center: Text(
                          '${litterLevel.toStringAsFixed(2)} kg',
                          style: TextStyle(
                            fontSize: (22.sp.clamp(16.0, 28.0)).toDouble(),
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 20.h),
                _buildInfoRow("Litter Weight:", "${litterLevel.toStringAsFixed(2)} kg", Icons.scale),
                SizedBox(height: 10.h),
                _buildInfoRow("Max Litter:", "$maxLitter kg", Icons.maximize),
                SizedBox(height: 10.h),
                _buildInfoRow("Critical Level:", "$criticalLevel kg", Icons.warning_amber_rounded),
                SizedBox(height: 10.h),
                _buildInfoRow("Last Updated:", _timeAgo(lastUpdated), Icons.update),
                SizedBox(height: 20.h),
                Text(
                  isConnected ? "Connected to Sensor" : "Disconnected or Waiting for Data...",
                  style: TextStyle(fontSize: 14.sp, color: isConnected ? Colors.green : Colors.red),
                ),
                SizedBox(height: 20.h),
                Text("v1.0.0 • by Team Delay",
                    style: TextStyle(fontSize: 14.sp, color: Colors.grey)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLiveWeightBanner() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(vertical: 10.h, horizontal: 16.w),
      decoration: BoxDecoration(
        color: Colors.red.shade600,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        "Real-time Weight: ${litterLevel.toStringAsFixed(2)} kg",
        textAlign: TextAlign.center,
        style: TextStyle(color: Colors.white, fontSize: 16.sp, fontWeight: FontWeight.bold),
      ),
    );
  }

  String _timeAgo(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inSeconds < 60) return 'just now';
    if (difference.inMinutes < 60) return '${difference.inMinutes} min ago';
    if (difference.inHours < 24) {
      final hours = difference.inHours;
      final minutes = difference.inMinutes.remainder(60);
      return '$hours hr${hours > 1 ? 's' : ''}${minutes > 0 ? ' $minutes min' : ''} ago';
    }

    final days = difference.inDays;
    final hours = difference.inHours.remainder(24);
    final minutes = difference.inMinutes.remainder(60);
    return '$days day${days > 1 ? 's' : ''}${hours > 0 ? ' $hours hr' : ''}${minutes > 0 ? ' $minutes min' : ''} ago';
  }

  Widget _buildInfoRow(String label, String value, IconData icon) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.teal.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.teal),
        boxShadow: [BoxShadow(color: Colors.teal.shade200, blurRadius: 4.0, offset: const Offset(0, 2))],
      ),
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
      child: Row(
        children: [
          Icon(icon, color: Colors.teal),
          SizedBox(width: 10.w),
          Expanded(
            child: Text(label, style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w500)),
          ),
          Text(value, style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}

// Dummy background widget (replace later if needed)
class SandParticleBackground extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container();
  }
}
