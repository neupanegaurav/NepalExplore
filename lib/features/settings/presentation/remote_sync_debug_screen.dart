import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nepal_explore/features/map/presentation/providers/map_provider.dart';
import 'package:nepal_explore/features/spots/data/spots_remote_source.dart';

class RemoteSyncDebugScreen extends ConsumerStatefulWidget {
  const RemoteSyncDebugScreen({super.key});

  @override
  ConsumerState<RemoteSyncDebugScreen> createState() =>
      _RemoteSyncDebugScreenState();
}

class _RemoteSyncDebugScreenState extends ConsumerState<RemoteSyncDebugScreen> {
  static const List<String> _priorityColumns = [
    'id',
    'name',
    'category',
    'category_key',
    'status',
    'approval_status',
    'latitude',
    'lat',
    'longitude',
    'lng',
    'lon',
    'is_featured',
    'isFeatured',
    'image_url',
    'imageUrl',
    'updated_at',
    'created_at',
  ];

  late Future<SpotsRemoteSnapshot> _snapshotFuture;

  @override
  void initState() {
    super.initState();
    _snapshotFuture = _loadSnapshot();
  }

  Future<SpotsRemoteSnapshot> _loadSnapshot() {
    return ref.read(remoteSourceProvider).fetchSnapshot();
  }

  void _refresh() {
    setState(() {
      _snapshotFuture = _loadSnapshot();
    });
  }

  String _prettyJson(Object? value) {
    const encoder = JsonEncoder.withIndent('  ');
    return encoder.convert(value);
  }

  List<String> _buildColumns(List<Map<String, dynamic>> rows) {
    final allKeys = <String>{};
    for (final row in rows) {
      allKeys.addAll(row.keys);
    }

    final orderedColumns = <String>[
      ..._priorityColumns.where(allKeys.contains),
      ...allKeys.where((key) => !_priorityColumns.contains(key)).toList()
        ..sort(),
    ];

    return orderedColumns;
  }

  String _formatCellValue(Object? value) {
    if (value == null) {
      return '-';
    }

    if (value is List) {
      if (value.isEmpty) {
        return '[]';
      }
      return value.map((item) => item.toString()).join(', ');
    }

    if (value is Map) {
      return jsonEncode(value);
    }

    if (value is String) {
      final normalized = value.replaceAll('\n', ' ').trim();
      return normalized.isEmpty ? '-' : normalized;
    }

    return value.toString();
  }

  void _showRowDetails(BuildContext context, Map<String, dynamic> row) {
    showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(
            row['name']?.toString() ?? row['id']?.toString() ?? 'Row Details',
          ),
          content: SizedBox(
            width: 680,
            child: SingleChildScrollView(
              child: SelectableText(
                _prettyJson(row),
                style: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(fontFamily: 'monospace'),
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildDataTable(
    BuildContext context,
    ThemeData theme,
    SpotsRemoteSnapshot data,
  ) {
    if (data.rawRows.isEmpty) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Text('No rows were returned by the remote source.'),
        ),
      );
    }

    final columns = _buildColumns(data.rawRows);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: DataTable(
            columnSpacing: 20,
            headingRowColor: WidgetStatePropertyAll(
              theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.65),
            ),
            columns: [
              const DataColumn(label: Text('#')),
              ...columns.map((column) => DataColumn(label: Text(column))),
              const DataColumn(label: Text('Details')),
            ],
            rows: List<DataRow>.generate(data.rawRows.length, (index) {
              final row = data.rawRows[index];
              return DataRow(
                cells: [
                  DataCell(Text('${index + 1}')),
                  ...columns.map((column) {
                    final value = _formatCellValue(row[column]);
                    return DataCell(
                      ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 220),
                        child: Tooltip(
                          message: value,
                          child: SelectableText(
                            value,
                            minLines: 1,
                            maxLines: 2,
                            style: theme.textTheme.bodySmall,
                          ),
                        ),
                      ),
                    );
                  }),
                  DataCell(
                    IconButton(
                      onPressed: () => _showRowDetails(context, row),
                      icon: const Icon(Icons.visibility_outlined),
                      tooltip: 'View row JSON',
                    ),
                  ),
                ],
              );
            }),
          ),
        ),
      ),
    );
  }

  Widget _buildSummaryCard(
    BuildContext context,
    ThemeData theme,
    SpotsRemoteSnapshot data,
    List<String> columns,
    String allRowsJson,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Snapshot Summary', style: theme.textTheme.titleLarge),
            const SizedBox(height: 12),
            SelectableText('Source: ${data.sourceLabel}'),
            const SizedBox(height: 8),
            Text('Raw rows fetched: ${data.rawRows.length}'),
            const SizedBox(height: 4),
            Text('Rows parsed into spots: ${data.spots.length}'),
            const SizedBox(height: 4),
            Text('Columns detected: ${columns.length}'),
            const SizedBox(height: 12),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                OutlinedButton.icon(
                  onPressed: _refresh,
                  icon: const Icon(Icons.refresh),
                  label: const Text('Refresh'),
                ),
                OutlinedButton.icon(
                  onPressed: () async {
                    await Clipboard.setData(ClipboardData(text: allRowsJson));
                    if (!context.mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Copied remote JSON to clipboard.'),
                      ),
                    );
                  },
                  icon: const Icon(Icons.copy_all),
                  label: const Text('Copy All JSON'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTableSection(
    BuildContext context,
    ThemeData theme,
    SpotsRemoteSnapshot data,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Raw Rows Table', style: theme.textTheme.titleLarge),
        const SizedBox(height: 8),
        Text(
          'Scroll sideways to inspect every field. Use the eye button to open full row JSON.',
          style: theme.textTheme.bodyMedium,
        ),
        const SizedBox(height: 8),
        _buildDataTable(context, theme, data),
      ],
    );
  }

  Widget _buildSnapshotContent(
    BuildContext context,
    ThemeData theme,
    SpotsRemoteSnapshot data,
  ) {
    final allRowsJson = _prettyJson(data.rawRows);
    final columns = _buildColumns(data.rawRows);

    return LayoutBuilder(
      builder: (context, constraints) {
        final isTabletLayout = constraints.maxWidth >= 900;

        return RefreshIndicator(
          onRefresh: () async => _refresh(),
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(16),
            children: [
              if (isTabletLayout)
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: 320,
                      child: _buildSummaryCard(
                        context,
                        theme,
                        data,
                        columns,
                        allRowsJson,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(child: _buildTableSection(context, theme, data)),
                  ],
                )
              else ...[
                _buildSummaryCard(context, theme, data, columns, allRowsJson),
                const SizedBox(height: 16),
                _buildTableSection(context, theme, data),
              ],
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Remote Debug Data'),
        actions: [
          IconButton(
            onPressed: _refresh,
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: FutureBuilder<SpotsRemoteSnapshot>(
        future: _snapshotFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Remote fetch failed',
                    style: theme.textTheme.titleLarge?.copyWith(
                      color: theme.colorScheme.error,
                    ),
                  ),
                  const SizedBox(height: 12),
                  SelectableText(
                    snapshot.error.toString(),
                    style: theme.textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 16),
                  FilledButton.icon(
                    onPressed: _refresh,
                    icon: const Icon(Icons.refresh),
                    label: const Text('Try Again'),
                  ),
                ],
              ),
            );
          }

          final data = snapshot.data!;
          return _buildSnapshotContent(context, theme, data);
        },
      ),
    );
  }
}
