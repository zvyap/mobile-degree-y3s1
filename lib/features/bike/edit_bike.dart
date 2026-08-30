import 'package:flutter/material.dart';

class EditBikePage extends StatefulWidget {
  const EditBikePage({
    super.key,
    required this.bikeId,
  });

  final String bikeId;

  @override
  State<EditBikePage> createState() => _EditBikePageState();
}

class _EditBikePageState extends State<EditBikePage> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _bikeIdController;
  late final TextEditingController _rateController;

  String _selectedModel = 'City Bike';
  String _selectedBikeType = 'Standard';
  String _selectedStation = 'University TARUMT';
  String _selectedCondition = 'Excellent';

  DateTime _purchaseDate = DateTime(2026, 7, 23);

  bool _regenerateQr = false;

  @override
  void initState() {
    super.initState();

    // Existing bike data
    _bikeIdController = TextEditingController(
      text: widget.bikeId,
    );

    _rateController = TextEditingController(
      text: '1.00',
    );
  }

  @override
  void dispose() {
    _bikeIdController.dispose();
    _rateController.dispose();

    super.dispose();
  }

  void showSnackBar(String message) {
    final messenger = ScaffoldMessenger.of(context);

    messenger.clearSnackBars();

    messenger.showSnackBar(
      SnackBar(
        content: Text(message),
      ),
    );
  }

  Future<void> _selectPurchaseDate() async {
    final selectedDate = await showDatePicker(
      context: context,
      initialDate: _purchaseDate,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );

    if (selectedDate != null) {
      setState(() {
        _purchaseDate = selectedDate;
      });
    }
  }

  void _updateBike() {
    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }

    // TODO: Update bike in database later.

    showSnackBar('Bike updated successfully');

    // You can enable this later after the update succeeds:
    //
    // Navigator.of(context).pop();
  }

  String _formatDate(DateTime date) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];

    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Form(
      key: _formKey,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(18, 16, 18, 32),
        children: [
          // =========================================================
          // Title
          // =========================================================

          Text(
            'Edit Bike',
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w800,
            ),
          ),

          const SizedBox(height: 48),

          // =========================================================
          // Bike Photo
          // =========================================================

          const _FieldLabel('Bike photo'),

          const SizedBox(height: 6),

          _BikePhotoUpload(
            onChooseFile: () {
              showSnackBar(
                'Image picker will be implemented later',
              );
            },
          ),

          const SizedBox(height: 16),

          // =========================================================
          // Bike ID + Model
          // =========================================================

          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: _FormSection(
                  label: 'Bike ID',
                  child: TextFormField(
                    controller: _bikeIdController,
                    decoration: const InputDecoration(
                      hintText: 'BR-',
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Enter bike ID';
                      }

                      return null;
                    },
                  ),
                ),
              ),

              const SizedBox(width: 12),

              Expanded(
                child: _FormSection(
                  label: 'Model',
                  child: DropdownButtonFormField<String>(
                    initialValue: _selectedModel,
                    isExpanded: true,
                    items: const [
                      DropdownMenuItem(
                        value: 'City Bike',
                        child: Text('City Bike'),
                      ),
                      DropdownMenuItem(
                        value: 'Road Bike',
                        child: Text('Road Bike'),
                      ),
                      DropdownMenuItem(
                        value: 'Mountain Bike',
                        child: Text('Mountain Bike'),
                      ),
                    ],
                    onChanged: (value) {
                      if (value == null) return;

                      setState(() {
                        _selectedModel = value;
                      });
                    },
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),

          // =========================================================
          // Bike Type + Rate Per Hour
          // =========================================================

          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: _FormSection(
                  label: 'Bike type',
                  child: DropdownButtonFormField<String>(
                    initialValue: _selectedBikeType,
                    isExpanded: true,
                    items: const [
                      DropdownMenuItem(
                        value: 'Standard',
                        child: Text('Standard'),
                      ),
                      DropdownMenuItem(
                        value: 'Electric',
                        child: Text('Electric'),
                      ),
                      DropdownMenuItem(
                        value: 'Mountain',
                        child: Text('Mountain'),
                      ),
                    ],
                    onChanged: (value) {
                      if (value == null) return;

                      setState(() {
                        _selectedBikeType = value;
                      });
                    },
                  ),
                ),
              ),

              const SizedBox(width: 12),

              Expanded(
                child: _FormSection(
                  label: 'Rate Per Hour',
                  child: TextFormField(
                    controller: _rateController,
                    keyboardType:
                    const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    decoration: const InputDecoration(
                      prefixText: 'RM ',
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Enter rate';
                      }

                      final rate = double.tryParse(value);

                      if (rate == null) {
                        return 'Invalid rate';
                      }

                      if (rate <= 0) {
                        return 'Invalid rate';
                      }

                      return null;
                    },
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),

          // =========================================================
          // Station
          // =========================================================

          _FormSection(
            label: 'Initial station',
            child: DropdownButtonFormField<String>(
              initialValue: _selectedStation,
              isExpanded: true,
              decoration: const InputDecoration(
                prefixIcon: Icon(
                  Icons.location_on_outlined,
                ),
              ),
              items: const [
                DropdownMenuItem(
                  value: 'University TARUMT',
                  child: Text('University TARUMT'),
                ),
                DropdownMenuItem(
                  value: 'Gurney Paragon',
                  child: Text('Gurney Paragon'),
                ),
                DropdownMenuItem(
                  value: 'Folk Valley',
                  child: Text('Folk Valley'),
                ),
              ],
              onChanged: (value) {
                if (value == null) return;

                setState(() {
                  _selectedStation = value;
                });
              },
            ),
          ),

          const SizedBox(height: 14),

          // =========================================================
          // Purchase Date + Initial Condition
          // =========================================================

          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: _FormSection(
                  label: 'Purchase date',
                  child: InkWell(
                    borderRadius: BorderRadius.circular(12),
                    onTap: _selectPurchaseDate,
                    child: InputDecorator(
                      decoration: const InputDecoration(
                        prefixIcon: Icon(
                          Icons.calendar_month_outlined,
                        ),
                      ),
                      child: Text(
                        _formatDate(_purchaseDate),
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(width: 12),

              Expanded(
                child: _FormSection(
                  label: 'Initial condition',
                  child: DropdownButtonFormField<String>(
                    initialValue: _selectedCondition,
                    isExpanded: true,
                    items: const [
                      DropdownMenuItem(
                        value: 'Excellent',
                        child: Text('Excellent'),
                      ),
                      DropdownMenuItem(
                        value: 'Good',
                        child: Text('Good'),
                      ),
                      DropdownMenuItem(
                        value: 'Fair',
                        child: Text('Fair'),
                      ),
                      DropdownMenuItem(
                        value: 'Poor',
                        child: Text('Poor'),
                      ),
                    ],
                    onChanged: (value) {
                      if (value == null) return;

                      setState(() {
                        _selectedCondition = value;
                      });
                    },
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 42),

          // =========================================================
          // Regenerate QR
          // =========================================================

          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Checkbox(
                value: _regenerateQr,
                onChanged: (value) {
                  setState(() {
                    _regenerateQr = value ?? false;
                  });
                },
              ),

              const Text(
                'Regenerate QR',
              ),

              const SizedBox(width: 5),

              Container(
                width: 25,
                height: 25,
                color: Colors.white,
                child: const Icon(
                  Icons.qr_code_2_rounded,
                  color: Colors.black,
                  size: 24,
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),

          // =========================================================
          // Update Button
          // =========================================================

          SizedBox(
            width: double.infinity,
            height: 48,
            child: FilledButton(
              onPressed: _updateBike,
              style: FilledButton.styleFrom(
                backgroundColor:
                scheme.primary.withValues(alpha: 0.18),
                foregroundColor: scheme.primary,
                side: BorderSide(
                  color: scheme.primary,
                ),
              ),
              child: const Text(
                'Update',
                style: TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: 16,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// =============================================================================
// FORM SECTION
// =============================================================================

class _FormSection extends StatelessWidget {
  const _FormSection({
    required this.label,
    required this.child,
  });

  final String label;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _FieldLabel(label),
        const SizedBox(height: 6),
        child,
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

// =============================================================================
// PHOTO UPLOAD
// =============================================================================

class _BikePhotoUpload extends StatelessWidget {
  const _BikePhotoUpload({
    required this.onChooseFile,
  });

  final VoidCallback onChooseFile;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: scheme.surfaceContainer,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: scheme.outline.withValues(alpha: 0.7),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: scheme.primaryContainer,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              Icons.photo_camera_outlined,
              size: 36,
              color: scheme.onPrimaryContainer,
            ),
          ),

          const SizedBox(width: 16),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Upload a clear bike photo',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),

                const SizedBox(height: 4),

                Text(
                  'PNG or JPG • Max 5 MB',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: scheme.onSurface.withValues(
                      alpha: 0.65,
                    ),
                  ),
                ),

                const SizedBox(height: 10),

                OutlinedButton(
                  onPressed: onChooseFile,
                  child: const Text('Choose file'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}