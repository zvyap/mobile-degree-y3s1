import 'package:flutter/material.dart';

class TransferBikePage extends StatefulWidget {
  const TransferBikePage({
    super.key,
    required this.bikeId,
  });

  final String bikeId;

  @override
  State<TransferBikePage> createState() => _TransferBikePageState();
}

class _TransferBikePageState extends State<TransferBikePage> {
  String _destinationStation = 'University TARUMT';
  String _transferReason = 'Balance bike availability';
  String _assignedStaff = 'Admin 1';

  bool _moveImmediately = true;

  void showSnackBar(String message) {
    final messenger = ScaffoldMessenger.of(context);

    messenger.clearSnackBars();

    messenger.showSnackBar(
      SnackBar(
        content: Text(message),
      ),
    );
  }
  void _transferBike(){
    showSnackBar("Bike Transferred");
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return ListView(
      padding: const EdgeInsets.fromLTRB(18, 16, 18, 32),
      children: [
        // ============================================================
        // Title
        // ============================================================

        Text(
          'Transfer bike',
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.w800,
          ),
        ),

        const SizedBox(height: 4),

        Text(
          'Move ${widget.bikeId} to another station.',
          style: theme.textTheme.bodySmall?.copyWith(
            color: scheme.onSurface.withValues(alpha: 0.7),
          ),
        ),

        const SizedBox(height: 16),

        // ============================================================
        // Bike card
        // ============================================================

        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: scheme.surfaceContainer,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: scheme.outline.withValues(alpha: 0.8),
            ),
          ),
          child: Row(
            children: [
              // Bike image placeholder
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: scheme.primaryContainer,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  Icons.directions_bike_rounded,
                  color: scheme.onPrimaryContainer,
                  size: 34,
                ),
              ),

              const SizedBox(width: 14),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${widget.bikeId} • Standard Road Bike',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),

                    const SizedBox(height: 5),

                    Text(
                      'Available',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: scheme.onSurface.withValues(alpha: 0.7),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 20),

        // ============================================================
        // Transfer route
        // ============================================================

        Text(
          'Transfer route',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w800,
          ),
        ),

        const SizedBox(height: 10),

        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: scheme.surfaceContainer,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: scheme.outline.withValues(alpha: 0.8),
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Route indicator
              Column(
                children: [
                  Container(
                    width: 18,
                    height: 18,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: scheme.primary,
                        width: 3,
                      ),
                    ),
                  ),

                  const SizedBox(height: 6),

                  ...List.generate(
                    3,
                        (index) => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 2),
                      child: Container(
                        width: 5,
                        height: 5,
                        decoration: BoxDecoration(
                          color: scheme.primary.withValues(alpha: 0.6),
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 6),

                  Container(
                    width: 18,
                    height: 18,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: const Color(0xFF16C995),
                        width: 3,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(width: 14),

              // Route information
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'FROM',
                      style: theme.textTheme.labelSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),

                    const SizedBox(height: 3),

                    Text(
                      'Gurney Paragon',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),

                    const SizedBox(height: 3),

                    Text(
                      '28 / 30 docks occupied',
                      style: theme.textTheme.bodySmall,
                    ),

                    const SizedBox(height: 14),

                    Text(
                      'TO',
                      style: theme.textTheme.labelSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),

                    const SizedBox(height: 3),

                    DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: _destinationStation,
                        isExpanded: true,
                        items: const [
                          DropdownMenuItem(
                            value: 'University TARUMT',
                            child: Text('University TARUMT'),
                          ),
                          DropdownMenuItem(
                            value: 'Folk Valley',
                            child: Text('Folk Valley'),
                          ),
                          DropdownMenuItem(
                            value: 'Central Park Station',
                            child: Text('Central Park Station'),
                          ),
                        ],
                        onChanged: (value) {
                          if (value == null) return;

                          setState(() {
                            _destinationStation = value;
                          });
                        },
                      ),
                    ),

                    Text(
                      '6 / 30 docks occupied',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: const Color(0xFF16C995),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 16),

        // ============================================================
        // Transfer reason
        // ============================================================

        const _FieldLabel('Transfer reason'),

        const SizedBox(height: 6),

        DropdownButtonFormField<String>(
          initialValue: _transferReason,
          isExpanded: true,
          items: const [
            DropdownMenuItem(
              value: 'Balance bike availability',
              child: Text('Balance bike availability'),
            ),
            DropdownMenuItem(
              value: 'Station overcrowded',
              child: Text('Station overcrowded'),
            ),
            DropdownMenuItem(
              value: 'Maintenance requirement',
              child: Text('Maintenance requirement'),
            ),
            DropdownMenuItem(
              value: 'Operational requirement',
              child: Text('Operational requirement'),
            ),
          ],
          onChanged: (value) {
            if (value == null) return;

            setState(() {
              _transferReason = value;
            });
          },
        ),

        const SizedBox(height: 14),

        // ============================================================
        // Assigned staff
        // ============================================================

        const _FieldLabel('Assigned staff'),

        const SizedBox(height: 6),

        DropdownButtonFormField<String>(
          initialValue: _assignedStaff,
          isExpanded: true,
          decoration: const InputDecoration(
            prefixIcon: Icon(
              Icons.person_outline_rounded,
            ),
          ),
          items: const [
            DropdownMenuItem(
              value: 'Admin 1',
              child: Text('Admin 1'),
            ),
            DropdownMenuItem(
              value: 'Staff 1',
              child: Text('Staff 1'),
            ),
            DropdownMenuItem(
              value: 'Staff 2',
              child: Text('Staff 2'),
            ),
          ],
          onChanged: (value) {
            if (value == null) return;

            setState(() {
              _assignedStaff = value;
            });
          },
        ),

        const SizedBox(height: 22),

        // ============================================================
        // Schedule
        // ============================================================

        const _FieldLabel('Schedule'),

        const SizedBox(height: 8),

        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 14,
            vertical: 10,
          ),
          decoration: BoxDecoration(
            color: scheme.surface,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: scheme.outline.withValues(alpha: 0.5),
            ),
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Move immediately',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),

                    const SizedBox(height: 4),

                    Text(
                      'Transfer starts after confirmation',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: scheme.onSurface.withValues(alpha: 0.55),
                      ),
                    ),
                  ],
                ),
              ),

              Switch(
                value: _moveImmediately,
                onChanged: (value) {
                  setState(() {
                    _moveImmediately = value;
                  });
                },
              ),
            ],
          ),
        ),

        const SizedBox(height: 28),

        // ============================================================
        // Schedule status
        // ============================================================

        Center(
          child: Text(
            _moveImmediately
                ? 'Scheduled • Now'
                : 'Scheduled • Select date and time',
            style: theme.textTheme.labelSmall,
          ),
        ),
        FilledButton(
          onPressed: _transferBike,
          child: const Text('Confirm transfer'),
        )
      ],
    );
  }
}

class _FieldLabel extends StatelessWidget {
  const _FieldLabel(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: Theme.of(context).textTheme.labelMedium?.copyWith(
        fontWeight: FontWeight.w700,
      ),
    );
  }
}