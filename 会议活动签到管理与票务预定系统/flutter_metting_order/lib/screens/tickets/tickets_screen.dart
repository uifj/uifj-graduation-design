import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../../providers/ticket_provider.dart';
import '../../providers/event_provider.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/ticket_card.dart';

class TicketsScreen extends StatefulWidget {
  const TicketsScreen({super.key});

  @override
  State<TicketsScreen> createState() => _TicketsScreenState();
}

class _TicketsScreenState extends State<TicketsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadTickets();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadTickets() async {
    final authProvider = Provider.of<AuthProvider>(context);

    await Provider.of<TicketProvider>(context, listen: false)
        .fetchUpcomingTickets(int.parse(authProvider.currentUser!.id));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final ticketProvider = Provider.of<TicketProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.tickets),
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(text: l10n.all),
            Tab(text: l10n.upcoming),
            Tab(text: l10n.past),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildTicketList(ticketProvider, l10n),
          _buildTicketList(ticketProvider, l10n),
          _buildTicketList(ticketProvider, l10n),
        ],
      ),
    );
  }

  Widget _buildTicketList(TicketProvider provider, AppLocalizations l10n) {
    final eventProvider = Provider.of<EventProvider>(context);
    return RefreshIndicator(
      onRefresh: _loadTickets,
      child: provider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : provider.error != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Error: ${provider.error}',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.error,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _loadTickets,
                        child: Text(l10n.retry),
                      ),
                    ],
                  ),
                )
              : provider.upcomingTickets.isEmpty
                  ? Center(
                      child: Text(
                        l10n.noTickets,
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              color: Theme.of(context)
                                  .colorScheme
                                  .onSurface
                                  .withOpacity(0.5),
                            ),
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: provider.upcomingTickets.length,
                      itemBuilder: (context, index) {
                        final ticket = provider.upcomingTickets[index];
                        final event = eventProvider.findById(ticket.eventId);
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 16),
                          child: TicketCard(
                            ticket: ticket,
                            event: event,
                          ),
                        );
                      },
                    ),
    );
  }
}
