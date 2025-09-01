import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/event.dart';
import '../../models/ticket.dart';
import '../../providers/ticket_provider.dart';

class CheckInResultScreen extends StatefulWidget {
  final Ticket ticket;
  final Event event;

  const CheckInResultScreen({
    super.key,
    required this.ticket,
    required this.event,
  });

  @override
  State<CheckInResultScreen> createState() => _CheckInResultScreenState();
}

class _CheckInResultScreenState extends State<CheckInResultScreen> {
  bool _isProcessing = false;

  Future<void> _confirmCheckIn() async {
    setState(() {
      _isProcessing = true;
    });

    final ticketProvider = Provider.of<TicketProvider>(context, listen: false);

    try {
      final success = await ticketProvider.checkInTicket(widget.ticket.id);
      if (success && mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Check-in successful!')));
        Navigator.of(context).pop();
        Navigator.of(context).pop();
      } else {
        throw Exception('Failed to check in');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: ${e.toString()}')));
        setState(() {
          _isProcessing = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isValid = widget.ticket.status == TicketStatus.paid;
    final isUsed = widget.ticket.status == TicketStatus.used;

    return Scaffold(
      appBar: AppBar(title: const Text('Check-in Result')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Icon(
              isValid
                  ? Icons.check_circle
                  : isUsed
                      ? Icons.info
                      : Icons.error,
              color: isValid
                  ? Colors.green
                  : isUsed
                      ? Colors.orange
                      : Colors.red,
              size: 64,
            ),
            const SizedBox(height: 16),
            Text(
              isValid
                  ? 'Valid Ticket'
                  : isUsed
                      ? 'Ticket Already Used'
                      : 'Invalid Ticket',
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Text(
                      widget.event.title,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        const Icon(Icons.confirmation_number, size: 16),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Ticket ID: ${widget.ticket.id}',
                            style: const TextStyle(fontSize: 16),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(Icons.calendar_today, size: 16),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            '${widget.event.date.day}/${widget.event.date.month}/${widget.event.date.year}',
                            style: const TextStyle(fontSize: 16),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(Icons.access_time, size: 16),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            '${widget.event.date.hour}:${widget.event.date.minute.toString().padLeft(2, '0')}',
                            style: const TextStyle(fontSize: 16),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(Icons.location_on_outlined, size: 16),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            widget.event.location,
                            style: const TextStyle(fontSize: 16),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: widget.ticket.getStatusColor().withOpacity(0.2),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Text(
                        widget.ticket.getStatusText(),
                        style: TextStyle(
                          color: widget.ticket.getStatusColor(),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    if (isUsed && widget.ticket.checkInTime != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Text(
                          'Checked in at: ${widget.ticket.checkInTime}',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
            const Spacer(),
            if (isValid)
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _isProcessing ? null : _confirmCheckIn,
                  child: _isProcessing
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text(
                          'Confirm Check-in',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              )
            else
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.grey),
                  child: const Text(
                    'Back to Scanner',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
