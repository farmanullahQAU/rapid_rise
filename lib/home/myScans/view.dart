import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:rapid_rise/models/components_scan.dart';

import 'controller.dart';

class ScannedDataPage extends StatelessWidget {
  final ScannedDataController controller = Get.put(ScannedDataController());

  ScannedDataPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Scanned Data'),
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return Center(
            child: CircularProgressIndicator(
              color: Theme.of(context).colorScheme.primary,
            ),
          );
        }

        if (controller.scannedData.isEmpty) {
          return Center(
            child: Text(
              'No scanned data available.',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16.0),
          itemCount: controller.scannedData.length,
          itemBuilder: (context, index) {
            final data = controller.scannedData[index];
            return ScannedDataCard(data: data);
          },
        );
      }),
    );
  }
}

class ScannedDataCard extends StatelessWidget {
  final ComponentScan data;

  const ScannedDataCard({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return TweenAnimationBuilder(
      duration: const Duration(milliseconds: 500),
      tween: Tween<double>(begin: 0.0, end: 1.0),
      curve: Curves.easeInOut,
      builder: (context, double value, child) {
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(0, 50 * (1 - value)),
            child: child,
          ),
        );
      },
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        elevation: 4,
        margin: const EdgeInsets.symmetric(vertical: 8),
        color: theme.cardColor,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Scan ID: ${data.scanID}',
                style: theme.textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.primary,
                ),
              ),
              const SizedBox(height: 8),
              _buildRow('Flight ID:', '${data.flightID}', context),
              const SizedBox(height: 8),
              _buildRow('Station:', data.station?.stationDescription ?? "N/A",
                  context),
              const SizedBox(height: 8),
              _buildRow('Lead Time:', '${data.station?.leadTime ?? "N/A"} days',
                  context),
              const SizedBox(height: 8),
              _buildRow(
                'Scan Date:',
                _formatDate(data.scanDate),
                context,
              ),
              const SizedBox(height: 16),
              Align(
                alignment: Alignment.centerRight,
                child: ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: theme.colorScheme.primary,
                    foregroundColor: theme.colorScheme.onPrimary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text('Details'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Helper method to build rows with label and value
  Widget _buildRow(String label, String value, BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      children: [
        Text(
          '$label ',
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.onSurface,
          ),
        ),
        Text(
          value,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurface,
          ),
        ),
      ],
    );
  }

  // Helper method to format the date
  String _formatDate(DateTime dateTime) {
    return "${dateTime.day}-${dateTime.month}-${dateTime.year}";
  }
}
