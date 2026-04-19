import 'package:flutter/material.dart';
import '../../services/storage_service.dart';
import '../../models/check_in.dart';
import 'package:intl/intl.dart'; // Run 'flutter pub add intl' for date formatting
import 'package:url_launcher/url_launcher.dart';

Future<void> _openInMaps(double lat, double lng) async {
  // The 'q' parameter drops a pin at the specific coordinates
  final String googleMapsUrl =
      "https://www.google.com/maps/search/?api=1&query=$lat,$lng";
  final Uri uri = Uri.parse(googleMapsUrl);

  if (await canLaunchUrl(uri)) {
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  } else {
    throw 'Could not launch maps';
  }
}

// ... keep your imports and _openInMaps function at the top ...

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Check-In History"),
        backgroundColor: Colors.green.shade800,
      ),
      // This FutureBuilder waits for the data to load from the disk
      body: FutureBuilder<List<CheckIn>>(
        future: StorageService.getHistory(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final history = snapshot.data ?? [];

          if (history.isEmpty) {
            return const Center(child: Text("No check-ins yet."));
          }

          // THIS IS THE LISTVIEW.BUILDER
          return ListView.builder(
            itemCount: history.length,

            // Ensure you kept: import 'package:intl/intl.dart'; at the top
            itemBuilder: (context, index) {
              final item = history[index];

              // Format the date into something readable like "Mar 29, 07:55 PM"
              String formattedTime = DateFormat(
                'MMM dd, hh:mm a',
              ).format(item.timestamp);

              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ListTile(
                  leading: const CircleAvatar(
                    backgroundColor: Colors.green,
                    child: Icon(
                      Icons.verified_user,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                  title: Text(
                    item.qrData,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  subtitle: Padding(
                    padding: const EdgeInsets.only(top: 4.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "📍 ${item.lat.toStringAsFixed(4)}, ${item.lng.toStringAsFixed(4)}",
                        ),
                        const SizedBox(height: 2),
                        Text(
                          "🕒 $formattedTime",
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  trailing: const Icon(
                    Icons.arrow_forward_ios,
                    size: 14,
                    color: Colors.grey,
                  ),
                  onTap: () => _openInMaps(item.lat, item.lng),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
