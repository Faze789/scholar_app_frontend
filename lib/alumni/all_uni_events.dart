import 'dart:math';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

class AllUniEventsScreen extends StatefulWidget {
  final Map<String, dynamic> alumniData;
  const AllUniEventsScreen({super.key, required this.alumniData});
  @override
  State<AllUniEventsScreen> createState() => _AllUniEventsScreenState();
}

class _AllUniEventsScreenState extends State<AllUniEventsScreen> {
  Map<String, List<Map<String, dynamic>>> eventsByUni = {};
  Map<String, List<Map<String, dynamic>>> filteredEventsByUni = {};
  bool loading = true;
  String searchQuery = '';
  bool _isLaunchingUrl = false;
  final TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    fetchAllEvents();
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  String _generateDemo2026Date(int index) {
    final random = Random(index);
    final month = random.nextBool() ? 1 : 2;
    final day = random.nextInt(month == 1 ? 31 : 28) + 1;
    return '2026-${month.toString().padLeft(2, '0')}-${day.toString().padLeft(2, '0')}';
  }

  Future<void> fetchAllEvents() async {
    try {
      final comsatsRes = await http.get(Uri.parse("http://192.168.100.121:5000/api/comsats_events"));
      final neduetRes = await http.get(Uri.parse("http://192.168.100.121:5000/api/neduet_events"));
      final uetRes = await http.get(Uri.parse("http://192.168.100.121:5000/api/uet_taxila_events"));

      if (comsatsRes.statusCode == 200 && neduetRes.statusCode == 200 && uetRes.statusCode == 200) {
        final comsatsJson = json.decode(comsatsRes.body) as Map<String, dynamic>;
        final neduetJson = json.decode(neduetRes.body) as Map<String, dynamic>;
        final uetJson = json.decode(uetRes.body) as Map<String, dynamic>;

        final comsatsEvents = (comsatsJson['events'] as List<dynamic>)
            .asMap()
            .map((index, e) {
              final item = e as Map<String, dynamic>;
              String link = item['link']?.toString() ?? '';
              if (link.isEmpty || !link.startsWith('http')) {
                link = 'https://comsats.edu.pk/alumni/allevents.aspx';
              }
              if (index < 2) {
                return MapEntry(index, {
                  ...item,
                  'date': _generateDemo2026Date(index),
                  'link': link,
                  'canApply': true,
                });
              }
              return MapEntry(index, {
                ...item,
                'link': link,
                'canApply': false,
              });
            })
            .values
            .toList();

        final neduetEvents = (neduetJson['events'] as List<dynamic>)
            .asMap()
            .map((index, e) {
              final item = e as Map<String, dynamic>;
              if (index < 2) {
                return MapEntry(index, {
                  ...item,
                  'date': _generateDemo2026Date(index + 100),
                  'link': 'https://www.neduet.edu.pk/content/events?page=3',
                  'canApply': true,
                });
              }
              return MapEntry(index, {
                ...item,
                'link': 'https://www.neduet.edu.pk/content/events?page=3',
                'canApply': false,
              });
            })
            .values
            .toList();

        final uetEvents = (uetJson['events'] as List<dynamic>)
            .asMap()
            .map((index, e) {
              final item = e as Map<String, dynamic>;
              String link = item['link']?.toString() ?? '';
              if (link.isEmpty || !link.startsWith('http')) {
                link = 'https://www.uettaxila.edu.pk';
              }
              if (index < 3) {
                return MapEntry(index, {
                  ...item,
                  'date': _generateDemo2026Date(index + 200),
                  'link': link,
                  'canApply': true,
                });
              }
              return MapEntry(index, {
                ...item,
                'link': link,
                'canApply': false,
              });
            })
            .values
            .toList();

        setState(() {
          eventsByUni = {
            'COMSATS': _sortAndGroupEvents(comsatsEvents),
            'NED UET': _sortAndGroupEvents(neduetEvents),
            'UET Taxila': _sortAndGroupEvents(uetEvents),
          };
          filteredEventsByUni = Map.from(eventsByUni);
          loading = false;
        });
      } else {
        throw Exception("Failed to fetch events");
      }
    } catch (e) {
      setState(() => loading = false);
      debugPrint("Error fetching events: $e");
    }
  }

  List<Map<String, dynamic>> _sortAndGroupEvents(List<Map<String, dynamic>> events) {
    events.sort((a, b) {
      final aDate = DateTime.tryParse(a['date'] ?? '') ?? DateTime.now();
      final bDate = DateTime.tryParse(b['date'] ?? '') ?? DateTime.now();
      return bDate.compareTo(aDate);
    });
    return events;
  }

  void _filterEvents(String query) {
    setState(() {
      searchQuery = query.toLowerCase();
      if (searchQuery.isEmpty) {
        filteredEventsByUni = Map.from(eventsByUni);
      } else {
        filteredEventsByUni = {};
        eventsByUni.forEach((uniName, events) {
          if (uniName.toLowerCase().contains(searchQuery)) {
            filteredEventsByUni[uniName] = events;
          }
        });
      }
    });
  }

  Color _getUniColor(String uniName) {
    switch (uniName) {
      case 'COMSATS':
        return Colors.deepPurple;
      case 'NED UET':
        return Colors.teal;
      case 'UET Taxila':
        return Colors.indigo;
      default:
        return Colors.blue;
    }
  }

  IconData _getUniIcon(String uniName) {
    switch (uniName) {
      case 'COMSATS':
        return Icons.school;
      case 'NED UET':
        return Icons.engineering;
      case 'UET Taxila':
        return Icons.architecture;
      default:
        return Icons.account_balance;
    }
  }

Future<void> _launchURL(String url) async {
  if (url.isEmpty) {
    _showSnackBar("No link available for this event");
    return;
  }

  String finalUrl = url;

  if (url.contains("comsats") || url.contains("COMSATS")) {
    finalUrl = "https://ww2.comsats.edu.pk/alumni/allevents.aspx";
  } else if (url.contains("uettaxila") || url.contains("uet") || url.contains("UET")) {
    finalUrl = "https://www.uettaxila.edu.pk/Events/All";
  } else if (url.contains("neduet") || url.contains("NED")) {
    finalUrl = "https://www.neduet.edu.pk/content/events?page=1";
  }

  setState(() => _isLaunchingUrl = true);

  try {
    final Uri uri = Uri.parse(finalUrl);
    final bool launched = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!launched) _showUrlOptions(finalUrl);
  } catch (e) {
    _showUrlOptions(finalUrl);
  } finally {
    if (mounted) setState(() => _isLaunchingUrl = false);
  }
}


  void _showUrlOptions(String url) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          const Text("Open Link", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          Text("Select how you want to open the link:", style: TextStyle(color: Colors.grey.shade600)),
          const SizedBox(height: 20),
          Row(children: [
            Expanded(
              child: ElevatedButton.icon(
                icon: const Icon(Icons.content_copy),
                label: const Text("Copy Link"),
                onPressed: () {
                  Navigator.pop(context);
                  _copyToClipboard(url);
                  _showSnackBar("Link copied to clipboard");
                },
                style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 15), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: ElevatedButton.icon(
                icon: const Icon(Icons.open_in_browser),
                label: const Text("Try Again"),
                onPressed: () {
                  Navigator.pop(context);
                  _launchURLDirect(url);
                },
                style: ElevatedButton.styleFrom(backgroundColor: Colors.deepPurple, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 15), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
              ),
            ),
          ]),
          const SizedBox(height: 10),
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel", style: TextStyle(fontSize: 16))),
        ]),
      ),
    );
  }

  Future<void> _launchURLDirect(String url) async {
    try {
      final Uri uri = Uri.parse(url);
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (e) {
      _showSnackBar("Failed to open link. Please copy and open manually.");
    }
  }

  void _copyToClipboard(String text) {
    Clipboard.setData(ClipboardData(text: text));
  }

  void _showSnackBar(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 3),
        backgroundColor: Colors.deepPurple,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ));
    }
  }

  bool _isValidUrl(String? url) {
    if (url == null || url.isEmpty) return false;
    try {
      final uri = Uri.parse(url);
      return uri.scheme.isNotEmpty && uri.host.isNotEmpty;
    } catch (e) {
      return false;
    }
  }

  void _navigateToApplyScreen(Map<String, dynamic> event) {
    context.go('/apply-alumni', extra: {
      'alumniData': widget.alumniData,
      'eventTitle': event['title'] ?? 'No Title',
      'eventDate': event['date'] ?? 'No Date',
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        actions: [
          IconButton(
            onPressed: () => context.go('/events-applied', extra: widget.alumniData),
            icon: const Icon(Icons.event, color: Colors.white),
            tooltip: 'Applied Events',
          ),
        ],
        elevation: 0,
        title: const Text("University Events", style: TextStyle(fontWeight: FontWeight.w700, color: Colors.white, fontSize: 22)),
        backgroundColor: Colors.deepPurple.shade700,
        centerTitle: true,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(colors: [Colors.deepPurple.shade700, Colors.deepPurple.shade400], begin: Alignment.topLeft, end: Alignment.bottomRight),
          ),
        ),
      ),
      body: Stack(
        children: [
          Column(
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                color: Colors.white,
                child: TextField(
                  controller: searchController,
                  onChanged: _filterEvents,
                  decoration: InputDecoration(
                    hintText: 'Search university...',
                    prefixIcon: Icon(Icons.search, color: Colors.grey.shade500),
                    suffixIcon: searchQuery.isNotEmpty
                        ? IconButton(icon: Icon(Icons.clear, color: Colors.grey.shade500), onPressed: () {
                            searchController.clear();
                            _filterEvents('');
                          })
                        : null,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: Colors.grey.shade200)),
                    enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: Colors.grey.shade200)),
                    focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: Colors.deepPurple.shade400, width: 2)),
                    filled: true,
                    fillColor: Colors.grey.shade50,
                    contentPadding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                ),
              ),
              Expanded(
                child: loading
                    ? Center(child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(Colors.deepPurple.shade400)))
                    : filteredEventsByUni.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.search_off, size: 80, color: Colors.grey.shade300),
                                const SizedBox(height: 16),
                                Text(
                                  searchQuery.isEmpty ? "No events found" : "No universities match your search",
                                  style: TextStyle(fontSize: 18, color: Colors.grey.shade600, fontWeight: FontWeight.w500),
                                ),
                              ],
                            ),
                          )
                        : ListView.builder(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            itemCount: filteredEventsByUni.length,
                            itemBuilder: (context, index) {
                              final uniName = filteredEventsByUni.keys.elementAt(index);
                              final events = filteredEventsByUni[uniName]!;
                              final uniColor = _getUniColor(uniName);
                              final uniIcon = _getUniIcon(uniName);
                              final now = DateTime.now();
                              final upcomingEvents = events.where((e) => (DateTime.tryParse(e['date'] ?? '') ?? now).isAfter(now)).toList();
                              final pastEvents = events.where((e) => (DateTime.tryParse(e['date'] ?? '') ?? now).isBefore(now) || (DateTime.tryParse(e['date'] ?? '') ?? now).isAtSameMomentAs(now)).toList();
                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(colors: [uniColor, uniColor.withOpacity(0.8)], begin: Alignment.topLeft, end: Alignment.bottomRight),
                                      borderRadius: BorderRadius.circular(16),
                                      boxShadow: [BoxShadow(color: uniColor.withOpacity(0.3), blurRadius: 10, offset: const Offset(0, 4))],
                                    ),
                                    child: Row(
                                      children: [
                                        CircleAvatar(backgroundColor: Colors.white.withOpacity(0.2), radius: 20, child: Icon(uniIcon, color: Colors.white, size: 24)),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: Text(uniName, style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
                                        ),
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                          decoration: BoxDecoration(color: Colors.white.withOpacity(0.3), borderRadius: BorderRadius.circular(20)),
                                          child: Text('${events.length} ${events.length == 1 ? 'Event' : 'Events'}', style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600)),
                                        ),
                                      ],
                                    ),
                                  ),
                                  if (events.isEmpty)
                                    Padding(
                                      padding: const EdgeInsets.all(16),
                                      child: Center(child: Text("No events available for $uniName", style: TextStyle(color: Colors.grey.shade600, fontSize: 16, fontWeight: FontWeight.w500))),
                                    )
                                  else ...[
                                    if (upcomingEvents.isNotEmpty) ...[
                                      Padding(
                                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                        child: Row(children: [
                                          Icon(Icons.upcoming, color: uniColor, size: 22),
                                          const SizedBox(width: 8),
                                          Text("Upcoming Events", style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: uniColor)),
                                        ]),
                                      ),
                                      ...upcomingEvents.map((event) => _buildEventCard(event, uniColor, true)),
                                    ],
                                    if (pastEvents.isNotEmpty) ...[
                                      Padding(
                                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                        child: Text("Past Events", style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: Colors.grey.shade700)),
                                      ),
                                      ...pastEvents.map((event) => _buildEventCard(event, uniColor, false)),
                                    ],
                                  ],
                                  const SizedBox(height: 16),
                                ],
                              );
                            },
                          ),
              ),
            ],
          ),
          if (_isLaunchingUrl)
            Container(
              color: Colors.black.withOpacity(0.6),
              child: Center(child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(Colors.deepPurple.shade400))),
            ),
        ],
      ),
    );
  }

  Widget _buildEventCard(Map<String, dynamic> event, Color uniColor, bool isUpcoming) {
    final hasLink = _isValidUrl(event['link']);
    final canApply = event['canApply'] == true && isUpcoming;
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: isUpcoming ? Border.all(color: uniColor.withOpacity(0.5), width: 1.5) : Border.all(color: Colors.grey.shade200, width: 1),
        boxShadow: [BoxShadow(color: isUpcoming ? uniColor.withOpacity(0.15) : Colors.grey.shade200, blurRadius: 12, offset: const Offset(0, 4))],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: hasLink ? () => _launchURL(event['link']) : null,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CircleAvatar(backgroundColor: isUpcoming ? uniColor.withOpacity(0.1) : Colors.grey.shade100, radius: 24, child: Icon(isUpcoming ? Icons.event_available : Icons.event, color: isUpcoming ? uniColor : Colors.grey.shade600, size: 24)),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Text(event['title'] ?? "No Title", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: isUpcoming ? uniColor : Colors.grey.shade800)),
                              ),
                              if (isUpcoming && canApply)
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                  decoration: BoxDecoration(color: Colors.green.shade400, borderRadius: BorderRadius.circular(16), boxShadow: [BoxShadow(color: Colors.green.shade200.withOpacity(0.5), blurRadius: 4, offset: const Offset(0, 2))]),
                                  child: const Text("NEW", style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
                                ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Row(children: [
                            Icon(Icons.calendar_today, size: 16, color: isUpcoming ? uniColor : Colors.grey.shade600),
                            const SizedBox(width: 6),
                            Text(event['date'] ?? "No Date", style: TextStyle(color: isUpcoming ? uniColor : Colors.grey.shade600, fontSize: 14, fontWeight: FontWeight.w600)),
                          ]),
                        ],
                      ),
                    ),
                  ],
                ),
                if (event['description'] != null && event['description'].toString().isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(color: isUpcoming ? uniColor.withOpacity(0.05) : Colors.grey.shade50, borderRadius: BorderRadius.circular(12)),
                    child: Text(event['description'], style: TextStyle(fontSize: 14, color: Colors.grey.shade800, height: 1.5), maxLines: 3, overflow: TextOverflow.ellipsis),
                  ),
                ],
                if (event['location'] != null && event['location'].toString().isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Row(children: [
                    Icon(Icons.location_on, size: 16, color: Colors.grey.shade600),
                    const SizedBox(width: 6),
                    Expanded(child: Text(event['location'], style: TextStyle(color: Colors.grey.shade700, fontSize: 14, fontWeight: FontWeight.w500), maxLines: 1, overflow: TextOverflow.ellipsis)),
                  ]),
                ],
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    if (isUpcoming && canApply) ...[
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () => _navigateToApplyScreen(event),
                          icon: const Icon(Icons.send, size: 18),
                          label: const Text("Apply Now", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                          style: ElevatedButton.styleFrom(backgroundColor: uniColor, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)), elevation: 3),
                        ),
                      ),
                      if (hasLink) const SizedBox(width: 8),
                    ],
                    if (hasLink)
                      ElevatedButton.icon(
                        onPressed: () => _launchURL(event['link']),
                        icon: const Icon(Icons.open_in_new, size: 18),
                        label: Text(isUpcoming ? "Details" : "View Event", style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.white, foregroundColor: uniColor, side: BorderSide(color: uniColor.withOpacity(0.5)), padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)), elevation: 0),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}