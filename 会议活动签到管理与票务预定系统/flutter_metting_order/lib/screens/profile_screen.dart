import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../providers/auth_provider.dart';
import '../providers/ticket_provider.dart';
import '../providers/event_provider.dart';
import '../providers/settings_provider.dart';
import '../widgets/ticket_card.dart';
import '../models/ticket.dart';
import 'profile_detail_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen>
    with SingleTickerProviderStateMixin {
  bool _isLoading = false;
  late TabController _tabController;
  final _refreshKey = GlobalKey<RefreshIndicatorState>();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _fetchUserTickets();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _fetchUserTickets() async {
    if (!mounted) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      if (authProvider.currentUser != null) {
        await Provider.of<TicketProvider>(context, listen: false)
            .fetchUserTickets(authProvider.currentUser!.id);
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            Provider.of<SettingsProvider>(context, listen: false)
                .getLocalizedText(
              'Failed to load tickets',
              '加载票务失败',
            ),
          ),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final ticketProvider = Provider.of<TicketProvider>(context);
    final eventProvider = Provider.of<EventProvider>(context);
    final settingsProvider = Provider.of<SettingsProvider>(context);
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    if (authProvider.currentUser == null) {
      return Scaffold(
        appBar: AppBar(
          title: Text(l10n.profile),
          elevation: 0,
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.person_off_outlined,
                size: 64,
                color: theme.colorScheme.onSurface.withOpacity(0.5),
              ),
              const SizedBox(height: 16),
              Text(
                l10n.signInRequired,
                style: theme.textTheme.titleMedium?.copyWith(
                  color: theme.colorScheme.onSurface.withOpacity(0.5),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.profile),
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(
              settingsProvider.isDarkMode ? Icons.light_mode : Icons.dark_mode,
              color: theme.colorScheme.onSurface,
            ),
            onPressed: () => settingsProvider.toggleTheme(),
          ),
          IconButton(
            icon: Text(
              settingsProvider.isEnglish ? '中' : 'EN',
              style: theme.textTheme.titleMedium?.copyWith(
                color: theme.colorScheme.onSurface,
              ),
            ),
            onPressed: () => settingsProvider.toggleLanguage(),
          ),
          IconButton(
            icon: Icon(
              Icons.settings,
              color: theme.colorScheme.onSurface,
            ),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (ctx) => const ProfileDetailScreen(),
                ),
              );
            },
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(text: l10n.all),
            Tab(text: l10n.upcoming),
            Tab(text: l10n.past),
          ],
        ),
      ),
      body: RefreshIndicator(
        key: _refreshKey,
        onRefresh: _fetchUserTickets,
        child: Column(
          children: [
            _buildProfileHeader(context, authProvider, theme),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildTicketList(
                    ticketProvider.tickets,
                    eventProvider,
                    theme,
                    l10n,
                  ),
                  _buildTicketList(
                    _filterUpcomingTickets(
                        ticketProvider.tickets, eventProvider),
                    eventProvider,
                    theme,
                    l10n,
                  ),
                  _buildTicketList(
                    _filterPastTickets(ticketProvider.tickets, eventProvider),
                    eventProvider,
                    theme,
                    l10n,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileHeader(
    BuildContext context,
    AuthProvider authProvider,
    ThemeData theme,
  ) {
    return Card(
      margin: const EdgeInsets.all(16),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Hero(
              tag: 'profile_avatar',
              child: CircleAvatar(
                radius: 40,
                backgroundColor: theme.colorScheme.primary,
                child: Text(
                  authProvider.currentUser!.name[0].toUpperCase(),
                  style: TextStyle(
                    fontSize: 32,
                    color: theme.colorScheme.onPrimary,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    authProvider.currentUser!.name,
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    authProvider.currentUser!.email,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: theme.colorScheme.onSurface.withOpacity(0.7),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: authProvider.isStaff
                          ? theme.colorScheme.primary.withOpacity(0.1)
                          : theme.colorScheme.secondary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      Provider.of<SettingsProvider>(context, listen: false)
                          .getLocalizedText(
                        authProvider.isStaff ? 'Staff' : 'Attendee',
                        authProvider.isStaff ? '工作人员' : '参会者',
                      ),
                      style: TextStyle(
                        color: authProvider.isStaff
                            ? theme.colorScheme.primary
                            : theme.colorScheme.secondary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTicketList(
    List<Ticket> tickets,
    EventProvider eventProvider,
    ThemeData theme,
    AppLocalizations l10n,
  ) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (tickets.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.confirmation_number_outlined,
              size: 64,
              color: theme.colorScheme.onSurface.withOpacity(0.5),
            ),
            const SizedBox(height: 16),
            Text(
              l10n.noTickets,
              style: theme.textTheme.titleMedium?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.5),
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: tickets.length,
      itemBuilder: (ctx, index) {
        final ticket = tickets[index];
        final event = eventProvider.findById(ticket.eventId);
        return TicketCard(
          ticket: ticket,
          event: event,
        );
      },
    );
  }

  List<Ticket> _filterUpcomingTickets(
    List<Ticket> tickets,
    EventProvider eventProvider,
  ) {
    final now = DateTime.now();
    return tickets.where((ticket) {
      final event = eventProvider.findById(ticket.eventId);
      return event.date.isAfter(now);
    }).toList();
  }

  List<Ticket> _filterPastTickets(
    List<Ticket> tickets,
    EventProvider eventProvider,
  ) {
    final now = DateTime.now();
    return tickets.where((ticket) {
      final event = eventProvider.findById(ticket.eventId);
      return event.date.isBefore(now);
    }).toList();
  }
}
