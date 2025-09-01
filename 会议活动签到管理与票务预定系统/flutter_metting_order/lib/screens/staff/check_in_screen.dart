import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import '../../providers/ticket_provider.dart';
import '../../providers/event_provider.dart';
import 'check_in_result_screen.dart';

class CheckInScreen extends StatefulWidget {
  const CheckInScreen({super.key});

  @override
  State<CheckInScreen> createState() => _CheckInScreenState();
}

class _CheckInScreenState extends State<CheckInScreen> {
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  QRViewController? controller;
  bool _isProcessing = false;

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }

  void _onQRViewCreated(QRViewController controller) {
    this.controller = controller;
    controller.scannedDataStream.listen((scanData) async {
      if (_isProcessing || scanData.code == null) return;

      setState(() {
        _isProcessing = true;
      });

      // Pause scanning
      controller.pauseCamera();

      // Process the QR code (ticket ID or other data)
      await _processQrCode(scanData.code!);
    });
  }

  Future<void> _processQrCode(String qrData) async {
    final ticketProvider = Provider.of<TicketProvider>(context, listen: false);
    final eventProvider = Provider.of<EventProvider>(context, listen: false);

    try {
      // In a real app, you would validate the QR code format
      // and extract the ticket ID or other relevant data

      // For this demo, we'll assume the QR code is the ticket ID
      final ticket = ticketProvider.findById(qrData);

      if (ticket == null) {
        throw Exception('Invalid ticket');
      }

      final event = eventProvider.findById(ticket.eventId);

      if (mounted) {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (ctx) => CheckInResultScreen(ticket: ticket, event: event),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: ${e.toString()}')));

        // Resume scanning after error
        controller?.resumeCamera();
        setState(() {
          _isProcessing = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Scan Ticket')),
      body: Column(
        children: [
          Expanded(
            flex: 5,
            child: QRView(
              key: qrKey,
              onQRViewCreated: _onQRViewCreated,
              overlay: QrScannerOverlayShape(
                borderColor: Theme.of(context).primaryColor,
                borderRadius: 10,
                borderLength: 30,
                borderWidth: 10,
                cutOutSize: 300,
              ),
            ),
          ),
          Expanded(
            flex: 1,
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (_isProcessing)
                    const CircularProgressIndicator()
                  else
                    const Text(
                      'Scan the QR code on the ticket',
                      style: TextStyle(fontSize: 16),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
