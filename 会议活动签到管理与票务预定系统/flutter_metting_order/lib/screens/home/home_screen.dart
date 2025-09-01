import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:carousel_slider/carousel_slider.dart';
import '../../providers/event_provider.dart';
import '../../providers/ticket_provider.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/event_card.dart';
import '../../widgets/ticket_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final eventProvider = Provider.of<EventProvider>(context, listen: false);
    final ticketProvider = Provider.of<TicketProvider>(context, listen: false);
    final authProvider = Provider.of<AuthProvider>(context);

    await Future.wait([
      eventProvider.fetchEvents(),
      ticketProvider
          .fetchUpcomingTickets(int.parse(authProvider.currentUser!.id)),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final eventProvider = Provider.of<EventProvider>(context);
    final ticketProvider = Provider.of<TicketProvider>(context);

    return RefreshIndicator(
      onRefresh: _loadData,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildCarousel(),
          const SizedBox(height: 24),
          _buildUpcomingTickets(l10n, ticketProvider),
          const SizedBox(height: 24),
          _buildRecommendedEvents(l10n, eventProvider),
        ],
      ),
    );
  }

  Widget _buildCarousel() {
    return CarouselSlider(
      options: CarouselOptions(
        height: 200,
        autoPlay: true,
        enlargeCenterPage: true,
        aspectRatio: 16 / 9,
        autoPlayCurve: Curves.fastOutSlowIn,
        enableInfiniteScroll: true,
        autoPlayAnimationDuration: const Duration(milliseconds: 800),
        viewportFraction: 0.8,
      ),
      items: [1, 2, 3].map((i) {
        return Builder(
          builder: (BuildContext context) {
            return Container(
              width: MediaQuery.of(context).size.width,
              margin: const EdgeInsets.symmetric(horizontal: 5.0),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Text(
                  'Banner $i',
                  style: TextStyle(
                    fontSize: 16.0,
                    color: Theme.of(context).colorScheme.onPrimaryContainer,
                  ),
                ),
              ),
            );
          },
        );
      }).toList(),
    );
  }

  Widget _buildUpcomingTickets(AppLocalizations l10n, TicketProvider provider) {
    final eventProvider = Provider.of<EventProvider>(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              l10n.upcomingTickets,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            TextButton(
              onPressed: () {
                // TODO: Navigate to tickets screen
              },
              child: Text(l10n.viewAll),
            ),
          ],
        ),
        const SizedBox(height: 16),
        if (provider.isLoading)
          const Center(child: CircularProgressIndicator())
        else if (provider.upcomingTickets.isEmpty)
          Center(
            child: Text(
              l10n.noUpcomingTickets,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withOpacity(0.5),
                  ),
            ),
          )
        else
          SizedBox(
            height: 180,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: provider.upcomingTickets.length,
              itemBuilder: (context, index) {
                final ticket = provider.upcomingTickets[index];
                final event = eventProvider.findById(ticket.eventId);
                return Padding(
                  padding: const EdgeInsets.only(right: 16),
                  child: TicketCard(
                    ticket: ticket,
                    event: event,
                  ),
                );
              },
            ),
          ),
      ],
    );
  }

  Widget _buildRecommendedEvents(
      AppLocalizations l10n, EventProvider provider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              l10n.recommendedEvents,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            TextButton(
              onPressed: () {
                // TODO: Navigate to events screen
              },
              child: Text(l10n.viewAll),
            ),
          ],
        ),
        const SizedBox(height: 16),
        if (provider.isLoading)
          const Center(child: CircularProgressIndicator())
        else if (provider.events.isEmpty)
          Center(
            child: Text(
              l10n.noRecommendedEvents,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withOpacity(0.5),
                  ),
            ),
          )
        else
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: provider.events.length,
            itemBuilder: (context, index) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: EventCard(event: provider.events[index]),
              );
            },
          ),
      ],
    );
  }
}
