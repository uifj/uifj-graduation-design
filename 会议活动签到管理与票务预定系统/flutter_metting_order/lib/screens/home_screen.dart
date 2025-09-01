import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../providers/auth_provider.dart';
import '../providers/event_provider.dart';
import '../core/network/api_service.dart';
import '../widgets/event_card.dart';
import 'auth/login_screen.dart';
import 'profile_screen.dart';
import 'staff/check_in_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _searchController = TextEditingController();
  String _searchQuery = '';
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  QRViewController? controller;
  bool _isScanning = false;

  @override
  void initState() {
    super.initState();
    _fetchEvents();
  }

  @override
  void dispose() {
    _searchController.dispose();
    controller?.dispose();
    super.dispose();
  }

  Future<void> _fetchEvents() async {
    await Provider.of<EventProvider>(context, listen: false).fetchEvents();
  }

  void _onQRViewCreated(QRViewController controller) {
    this.controller = controller;
    controller.scannedDataStream.listen((scanData) async {
      if (scanData.code != null) {
        await _handleScannedTicket(scanData.code!);
      }
    });
  }

  Future<void> _handleScannedTicket(String qrData) async {
    try {
      // 解析二维码数据
      final ticketData = _parseTicketData(qrData);
      if (ticketData == null) {
        _showError(AppLocalizations.of(context)!.invalidTicket);
        return;
      }

      // 获取当前时间
      final now = DateTime.now();
      final checkinData = {
        'time': now.toIso8601String(),
        'device': 'Mobile Scanner',
        'location': 'Conference Venue',
      };

      // 调用核销接口
      await ApiService.checksTicket(
        ticketId: ticketData['ticketId'],
        meetingId: ticketData['meetingId'],
        userId: ticketData['userId'],
        checkinData: checkinData.toString(),
      );

      // 显示成功消息
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context)!.ticketVerified),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      _showError(
          AppLocalizations.of(context)!.ticketVerificationFailed(e.toString()));
    }
  }

  Map<String, dynamic>? _parseTicketData(String qrData) {
    try {
      // 这里需要根据实际的二维码数据格式进行解析
      // 示例格式: "TICKET:123:456:789"
      final parts = qrData.split(':');
      if (parts.length >= 4 && parts[0] == 'TICKET') {
        return {
          'ticketId': parts[1],
          'meetingId': int.parse(parts[2]),
          'userId': int.parse(parts[3]),
        };
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  void _showError(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _toggleScanning() {
    setState(() {
      _isScanning = !_isScanning;
    });
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final eventProvider = Provider.of<EventProvider>(context);
    final l10n = AppLocalizations.of(context)!;
    final events = _searchQuery.isEmpty
        ? eventProvider.events
        : eventProvider.searchEvents(_searchQuery);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.appTitle),
        actions: [
          if (authProvider.isStaff)
            IconButton(
              icon: Icon(_isScanning ? Icons.close : Icons.qr_code_scanner),
              onPressed: _toggleScanning,
            ),
          IconButton(
            icon: const Icon(Icons.person),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (ctx) => const ProfileScreen(),
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              authProvider.logout();
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(
                  builder: (ctx) => const LoginScreen(),
                ),
              );
            },
          ),
        ],
      ),
      body: _isScanning
          ? _buildScanner()
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: l10n.searchEvents,
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      contentPadding: const EdgeInsets.symmetric(vertical: 12),
                      suffixIcon: _searchQuery.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear),
                              onPressed: () {
                                _searchController.clear();
                                setState(() {
                                  _searchQuery = '';
                                });
                              },
                            )
                          : null,
                    ),
                    onChanged: (value) {
                      setState(() {
                        _searchQuery = value;
                      });
                    },
                  ),
                ),
                Expanded(
                  child: eventProvider.isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : eventProvider.error != null
                          ? Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    'Error: ${eventProvider.error}',
                                    style: TextStyle(
                                      color:
                                          Theme.of(context).colorScheme.error,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                  const SizedBox(height: 16),
                                  ElevatedButton(
                                    onPressed: _fetchEvents,
                                    child: Text(l10n.retry),
                                  ),
                                ],
                              ),
                            )
                          : events.isEmpty
                              ? Center(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.event_busy,
                                        size: 64,
                                        color: Theme.of(context)
                                            .colorScheme
                                            .onSurface
                                            .withOpacity(0.5),
                                      ),
                                      const SizedBox(height: 16),
                                      Text(
                                        _searchQuery.isEmpty
                                            ? l10n.noEvents
                                            : l10n.noEventsFound(_searchQuery),
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodyLarge
                                            ?.copyWith(
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .onSurface
                                                  .withOpacity(0.5),
                                            ),
                                      ),
                                    ],
                                  ),
                                )
                              : RefreshIndicator(
                                  onRefresh: _fetchEvents,
                                  child: ListView.builder(
                                    padding: const EdgeInsets.all(16),
                                    itemCount: events.length,
                                    itemBuilder: (ctx, index) {
                                      return EventCard(event: events[index]);
                                    },
                                  ),
                                ),
                ),
              ],
            ),
    );
  }

  Widget _buildScanner() {
    return Stack(
      children: [
        QRView(
          key: qrKey,
          onQRViewCreated: _onQRViewCreated,
          overlay: QrScannerOverlayShape(
            borderColor: Theme.of(context).colorScheme.primary,
            borderRadius: 10,
            borderLength: 30,
            borderWidth: 10,
            cutOutSize: MediaQuery.of(context).size.width * 0.8,
          ),
        ),
        Positioned(
          bottom: 16,
          left: 0,
          right: 0,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                icon: const Icon(Icons.flip_camera_android),
                onPressed: () async {
                  await controller?.flipCamera();
                },
              ),
              IconButton(
                icon: const Icon(Icons.flash_on),
                onPressed: () async {
                  await controller?.toggleFlash();
                },
              ),
            ],
          ),
        ),
      ],
    );
  }
}
