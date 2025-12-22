import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../services/connectivity_service.dart';
import '../utils/api_diagnostics.dart';

/// Dialog to check internet connection and diagnose issues
class InternetCheckDialog {
  static Future<void> show(BuildContext context) async {
    final connectivity = ConnectivityService();
    final diagnostics = ApiDiagnostics();

    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => _InternetCheckDialogContent(
        connectivity: connectivity,
        diagnostics: diagnostics,
      ),
    );
  }
}

class _InternetCheckDialogContent extends StatefulWidget {
  final ConnectivityService connectivity;
  final ApiDiagnostics diagnostics;

  const _InternetCheckDialogContent({
    required this.connectivity,
    required this.diagnostics,
  });

  @override
  State<_InternetCheckDialogContent> createState() =>
      _InternetCheckDialogContentState();
}

class _InternetCheckDialogContentState
    extends State<_InternetCheckDialogContent> {
  bool _checking = false;
  DiagnosticReport? _report;

  @override
  void initState() {
    super.initState();
    _runDiagnostics();
  }

  Future<void> _runDiagnostics() async {
    setState(() {
      _checking = true;
      _report = null;
    });

    try {
      final report = await widget.diagnostics.runDiagnostics();
      if (mounted) {
        setState(() {
          _report = report;
          _checking = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _checking = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [AppColors.darkCard, AppColors.darkBg],
          ),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: AppColors.neonCyan.withValues(alpha: 0.3),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.neonCyan.withValues(alpha: 0.2),
              blurRadius: 30,
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Icon
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: _checking
                    ? AppColors.cyanPurpleGradient
                    : (_report?.isHealthy ?? false)
                    ? const LinearGradient(
                        colors: [Color(0xFF10B981), Color(0xFF059669)],
                      )
                    : const LinearGradient(
                        colors: [Color(0xFFEF4444), Color(0xFFDC2626)],
                      ),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: (_report?.isHealthy ?? false)
                        ? const Color(0xFF10B981).withValues(alpha: 0.4)
                        : const Color(0xFFEF4444).withValues(alpha: 0.4),
                    blurRadius: 20,
                  ),
                ],
              ),
              child: Icon(
                _checking
                    ? Icons.wifi_find
                    : (_report?.isHealthy ?? false)
                    ? Icons.wifi
                    : Icons.wifi_off,
                size: 48,
                color: Colors.white,
              ),
            ),

            const SizedBox(height: 24),

            // Title
            Text(
              _checking
                  ? 'جاري الفحص...'
                  : (_report?.isHealthy ?? false)
                  ? 'الاتصال جيد!'
                  : 'مشكلة في الاتصال',
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 16),

            // Status
            if (_checking)
              Column(
                children: [
                  const CircularProgressIndicator(color: AppColors.neonCyan),
                  const SizedBox(height: 16),
                  Text(
                    'فحص الاتصال بالإنترنت...',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.white.withValues(alpha: 0.7),
                    ),
                  ),
                ],
              )
            else if (_report != null)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildCheckItem(
                    'الإنترنت',
                    _report!.hasInternetConnection,
                    _report!.connectionType,
                  ),
                  _buildCheckItem(
                    'DNS',
                    _report!.dnsResolved,
                    _report!.resolvedIPs.isEmpty
                        ? null
                        : _report!.resolvedIPs.first,
                  ),
                  _buildCheckItem(
                    'الخادم',
                    _report!.serverReachable,
                    _report!.serverReachable
                        ? '${_report!.pingTimeMs}ms'
                        : null,
                  ),
                  if (_report!.sslValid != null)
                    _buildCheckItem('SSL', _report!.sslValid!, null),
                  _buildCheckItem('API', _report!.apiEndpointReachable, null),
                ],
              ),

            const SizedBox(height: 24),

            // Actions
            Row(
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      backgroundColor: Colors.white.withValues(alpha: 0.1),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'إغلاق',
                      style: TextStyle(color: Colors.white, fontSize: 16),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _checking ? null : _runDiagnostics,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      backgroundColor: AppColors.neonCyan,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'إعادة الفحص',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCheckItem(String label, bool status, String? detail) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: status
              ? const Color(0xFF10B981).withValues(alpha: 0.3)
              : const Color(0xFFEF4444).withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Icon(
            status ? Icons.check_circle : Icons.cancel,
            color: status ? const Color(0xFF10B981) : const Color(0xFFEF4444),
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
                if (detail != null)
                  Text(
                    detail,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.white.withValues(alpha: 0.6),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
