import 'package:flutter/material.dart';
import '../widgets/bike_qr_modal.dart';

class AddBike extends StatefulWidget {
  const AddBike({super.key});

  @override
  State<AddBike> createState() => _AddBikeState();
}

class _AddBikeState extends State<AddBike> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _bikeIdController = TextEditingController();
  final TextEditingController _rateController = TextEditingController();

  String _selectedModel = 'Standard City Bike';
  String _selectedBikeType = 'Standard';
  String _selectedStation = 'University TARUMT';
  String _selectedCondition = 'Excellent';
  int _currentStep = 0;

  DateTime _purchaseDate = DateTime(2026, 7, 23);

  @override
  void dispose() {
    _bikeIdController.dispose();
    _rateController.dispose();

    super.dispose();
  }

  // ---------------------------------------------------------------------------
  // Snackbar
  // ---------------------------------------------------------------------------

  void showSnackBar(String message) {
    final messenger = ScaffoldMessenger.of(context);

    messenger.clearSnackBars();

    messenger.showSnackBar(
      SnackBar(
        content: Text(message),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Date picker
  // ---------------------------------------------------------------------------

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

  // ---------------------------------------------------------------------------
  // Next
  // ---------------------------------------------------------------------------

  void _goToNextStep(int nextStep) {

      // Later this will move to Step 2.
      if( nextStep == 1){
        if (_formKey.currentState?.validate() ?? false) {
          setState(() {
            _currentStep = 1;
          });
          showSnackBar("Page 1 Completed");
        }

      }else if(nextStep == 2){

        setState(() {
          _currentStep =2 ;
        });
        showSnackBar("Page 2 Completed");
      }


  }

  @override
  Widget build(BuildContext context) {
    return switch (_currentStep) {
      0 => _buildStepOne(context),
      1 => _buildStepTwo(context),
      2 => _buildStepThree(context),
      _ => _buildStepOne(context),
    };

  }

  // -------------------------------------------------------------------
  // AddBike(Step 1)
  // -------------------------------------------------------------------

  Widget _buildStepOne(BuildContext context){
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Form(
      key: _formKey,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(
          18,
          16,
          18,
          32,
        ),
        children: [
          // -------------------------------------------------------------------
          // Title
          // -------------------------------------------------------------------

          Text(
            'Add new bike',
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w800,
            ),
          ),

          const SizedBox(height: 8),

          // -------------------------------------------------------------------
          // Step indicator
          // -------------------------------------------------------------------

          Text(
            'Step 1 of 3 • Basic information',
            style: theme.textTheme.bodySmall?.copyWith(
              color: scheme.onSurface.withValues(alpha: 0.75),
            ),
          ),

          const SizedBox(height: 10),

          ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: LinearProgressIndicator(
              value: 1 / 3,
              minHeight: 6,
              backgroundColor: scheme.surfaceContainerHighest,
            ),
          ),

          const SizedBox(height: 20),

          // -------------------------------------------------------------------
          // Bike photo
          // -------------------------------------------------------------------

          const _FieldLabel('Bike photo'),

          const SizedBox(height: 6),

          _BikePhotoUpload(
            onChooseFile: () {
              // Add actual image picker later.
              showSnackBar('Bike photo picker will be added later');
            },
          ),

          const SizedBox(height: 16),

          // -------------------------------------------------------------------
          // Bike ID + Model
          // -------------------------------------------------------------------

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
                        value: 'Standard City Bike',
                        child: Text('Standard City Bike'),
                      ),
                      DropdownMenuItem(
                        value: 'Standard Road Bike',
                        child: Text('Standard Road Bike'),
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

          // -------------------------------------------------------------------
          // Bike type + Rate
          // -------------------------------------------------------------------

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
                    keyboardType: const TextInputType.numberWithOptions(
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
                        return 'Rate must be above 0';
                      }

                      return null;
                    },
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),

          // -------------------------------------------------------------------
          // Initial station
          // -------------------------------------------------------------------

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

          // -------------------------------------------------------------------
          // Purchase date + Condition
          // -------------------------------------------------------------------

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

          const SizedBox(height: 18),

          // -------------------------------------------------------------------
          // QR information
          // -------------------------------------------------------------------

          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 11,
            ),
            decoration: BoxDecoration(
              color: scheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.info_rounded,
                  color: scheme.primary,
                  size: 22,
                ),

                const SizedBox(width: 10),

                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'A QR code will be generated automatically.',
                        style: theme.textTheme.bodySmall?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),

                      const SizedBox(height: 2),

                      Text(
                        'You can print and attach it after saving.',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: scheme.onSurface.withValues(
                            alpha: 0.60,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 28),

          // -------------------------------------------------------------------
          // Next button
          // -------------------------------------------------------------------

          Align(
            alignment: Alignment.centerRight,
            child: SizedBox(
              width: 125,
              height: 48,
              child: FilledButton(
                onPressed: () {
                  _goToNextStep(1);
                },
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Next',
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    SizedBox(width: 8),
                    Icon(
                      Icons.chevron_right_rounded,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );

  }


  // -------------------------------------------------------------------
  // AddBike(Step 2)
  // -------------------------------------------------------------------

  Widget _buildStepTwo(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return ListView(
      padding: const EdgeInsets.fromLTRB(18, 16, 18, 32),
      children: [
        // -------------------------------------------------------------
        // Title
        // -------------------------------------------------------------
        Text(
          'Add new bike',
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.w800,
          ),
        ),

        const SizedBox(height: 8),

        // -------------------------------------------------------------
        // Step indicator
        // -------------------------------------------------------------
        Text(
          'Step 2 of 3 • QR code',
          style: theme.textTheme.bodySmall?.copyWith(
            color: scheme.onSurface.withValues(alpha: 0.75),
          ),
        ),

        const SizedBox(height: 10),

        ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: LinearProgressIndicator(
            value: 2 / 3,
            minHeight: 6,
            backgroundColor: scheme.surfaceContainerHighest,
          ),
        ),

        const SizedBox(height: 20),

        Text(
          'Bike QR Code',
          style: theme.textTheme.labelMedium?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),

        const SizedBox(height: 30),

        // -------------------------------------------------------------
        // QR code placeholder
        // -------------------------------------------------------------
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: scheme.surface,
            border: Border.all(
              color: scheme.outline.withValues(alpha: 0.3),
            ),
          ),
          child: Column(
            children: [
              // Bike QR identifier
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'QR: ${_bikeIdController.text.isEmpty ? 'BR-XXXX' : _bikeIdController.text}',
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),

                  IconButton(
                    onPressed: () {
                      final code = _bikeIdController.text.trim();
                      BikeQrModal.show(
                        context,
                        bikeCode: code.isEmpty ? 'BR-NEW' : code,
                        qrToken: code.isEmpty ? 'BR-NEW' : code,
                      );
                    },
                    icon: const Icon(
                      Icons.open_in_full_rounded,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              // -------------------------------------------------------
              // QR PLACEHOLDER
              // -------------------------------------------------------
              AspectRatio(
                aspectRatio: 1,
                child: Container(
                  decoration: BoxDecoration(
                    color: scheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.qr_code_2_rounded,
                        size: 160,
                        color: scheme.onSurface.withValues(
                          alpha: 0.75,
                        ),
                      ),

                      const SizedBox(height: 12),

                      Text(
                        'QR Code Placeholder',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),

                      const SizedBox(height: 4),

                      Text(
                        'QR generation will be implemented later',
                        textAlign: TextAlign.center,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: scheme.onSurface.withValues(
                            alpha: 0.6,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 12),

              // -------------------------------------------------------
              // Download
              // -------------------------------------------------------
              Align(
                alignment: Alignment.centerRight,
                child: IconButton(
                  onPressed: () {
                    final code = _bikeIdController.text.trim();
                    BikeQrModal.show(
                      context,
                      bikeCode: code.isEmpty ? 'BR-NEW' : code,
                      qrToken: code.isEmpty ? 'BR-NEW' : code,
                    );
                  },
                  icon: const Icon(
                    Icons.download_outlined,
                    size: 30,
                  ),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 100),

        // -------------------------------------------------------------
        // Back + Next
        // -------------------------------------------------------------
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            SizedBox(
              width: 125,
              height: 48,
              child: FilledButton(
                style: FilledButton.styleFrom(
                  backgroundColor: scheme.error,
                  foregroundColor: scheme.onError,
                ),
                onPressed: () {
                  setState(() {
                    _currentStep = 0;
                  });
                },
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.chevron_left_rounded,
                    ),
                    SizedBox(width: 6),
                    Text(
                      'Back',
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            SizedBox(
              width: 125,
              height: 48,
              child: FilledButton(
                onPressed: () {
                 _goToNextStep(2);
                },
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Next',
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    SizedBox(width: 6),
                    Icon(
                      Icons.chevron_right_rounded,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  // -------------------------------------------------------------------
  // AddBike(Step 3)
  // -------------------------------------------------------------------

  Widget _buildStepThree(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return ListView(
      padding: const EdgeInsets.fromLTRB(18, 16, 18, 32),
      children: [
        // -------------------------------------------------------------
        // Title
        // -------------------------------------------------------------
        Text(
          'Add new bike',
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.w800,
          ),
        ),

        const SizedBox(height: 8),

        // -------------------------------------------------------------
        // Step indicator
        // -------------------------------------------------------------
        Text(
          'Step 3 of 3 • Review information',
          style: theme.textTheme.bodySmall?.copyWith(
            color: scheme.onSurface.withValues(alpha: 0.75),
          ),
        ),

        const SizedBox(height: 10),

        ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: LinearProgressIndicator(
            value: 1,
            minHeight: 6,
            backgroundColor: scheme.surfaceContainerHighest,
          ),
        ),

        const SizedBox(height: 20),

        // -------------------------------------------------------------
        // Bike photo
        // -------------------------------------------------------------
        Text(
          'Bike photo',
          style: theme.textTheme.labelMedium?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),

        const SizedBox(height: 8),

        // Photo placeholder
        Container(
          width: 125,
          height: 110,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: scheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: scheme.outline.withValues(alpha: 0.5),
            ),
          ),
          child: Icon(
            Icons.directions_bike_rounded,
            size: 72,
            color: scheme.primary,
          ),
        ),

        const SizedBox(height: 28),

        // -------------------------------------------------------------
        // Review information card
        // -------------------------------------------------------------
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: scheme.surfaceContainer,
            borderRadius: BorderRadius.circular(4),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _reviewRow(
                context,
                label: 'Bike ID:',
                value: _bikeIdController.text,
              ),

              const SizedBox(height: 12),

              _reviewRow(
                context,
                label: 'Model:',
                value: _selectedModel,
              ),

              const SizedBox(height: 12),

              _reviewRow(
                context,
                label: 'Bike type:',
                value: _selectedBikeType,
              ),

              const SizedBox(height: 12),

              _reviewRow(
                context,
                label: 'Rate Per Hour:',
                value: 'RM ${_rateController.text}',
              ),

              const SizedBox(height: 12),

              _reviewRow(
                context,
                label: 'Initial station:',
                value: _selectedStation,
              ),

              const SizedBox(height: 12),

              _reviewRow(
                context,
                label: 'Purchase date:',
                value: _formatDate(_purchaseDate),
              ),

              const SizedBox(height: 28),

              Text(
                'Generated QR Code:',
                style: theme.textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),

              const SizedBox(height: 14),

              // ---------------------------------------------------------
              // QR placeholder
              // ---------------------------------------------------------
              Center(
                child: Column(
                  children: [
                    Text(
                      'QR: ${_bikeIdController.text.isEmpty ? 'BR-XXXX' : _bikeIdController.text}',
                      style: theme.textTheme.labelSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),

                    const SizedBox(height: 4),

                    Container(
                      width: 105,
                      height: 105,
                      alignment: Alignment.center,
                      color: Colors.white,
                      child: const Icon(
                        Icons.qr_code_2_rounded,
                        size: 90,
                        color: Colors.black,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),
            ],
          ),
        ),

        const SizedBox(height: 40),

        // -------------------------------------------------------------
        // Back + Add
        // -------------------------------------------------------------
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            SizedBox(
              width: 125,
              height: 48,
              child: FilledButton(
                style: FilledButton.styleFrom(
                  backgroundColor: scheme.error,
                  foregroundColor: scheme.onError,
                ),
                onPressed: () {
                  setState(() {
                    _currentStep = 1;
                  });
                },
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.chevron_left_rounded,
                    ),
                    SizedBox(width: 6),
                    Text(
                      'Back',
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            SizedBox(
              width: 125,
              height: 48,
              child: FilledButton(
                onPressed: _addBike,
                child: const Text(
                  'Add',
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  void _addBike() {
    showSnackBar('Bike added successfully');
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

  Widget _reviewRow(
      BuildContext context, {
        required String label,
        required String value,
      }) {
    final theme = Theme.of(context);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),

        const SizedBox(width: 8),

        Expanded(
          child: Text(
            value,
            style: theme.textTheme.bodyMedium,
          ),
        ),
      ],
    );
  }

}

// ============================================================================
// Field label + field
// ============================================================================

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

// ============================================================================
// Photo upload placeholder
// ============================================================================



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
          // Image placeholder
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: scheme.primaryContainer,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              Icons.photo_camera_outlined,
              color: scheme.onPrimaryContainer,
              size: 36,
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
                    color: scheme.onSurface.withValues(alpha: 0.65),
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

