import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AddNewStationScreen extends StatefulWidget {
  final Map<String, dynamic>? stationToEdit; // For Edit Mode
  final double? initialLat;                  // For Add Mode (from map long-press)
  final double? initialLng;                  // For Add Mode (from map long-press)

  const AddNewStationScreen({
    super.key,
    this.stationToEdit,
    this.initialLat,
    this.initialLng,
  });

  @override
  State<AddNewStationScreen> createState() => _AddNewStationScreenState();
}

class _AddNewStationScreenState extends State<AddNewStationScreen> {
  final SupabaseClient supabase = Supabase.instance.client;

  // --- Form State Variables ---
  String stationName = "";
  String stationAddress = "";
  String latLngDesc = "";
  String operatingStatus = "Normal";

  int currentBikes = 0;
  int maxBikes = 20;

  double? latitude;
  double? longitude;

  bool isSaving = false;

  bool get isEditMode => widget.stationToEdit != null;

  @override
  void initState() {
    super.initState();

    if (isEditMode) {
      // === EDIT MODE PRE-FILL ===
      final station = widget.stationToEdit!;
      stationName = station['name'] ?? "";
      stationAddress = station['address'] ?? "";
      operatingStatus = station['status'] ?? "Normal";
      currentBikes = station['available_bikes'] ?? station['currentBikes'] ?? 0;
      maxBikes = station['capacity'] ?? station['maxBikes'] ?? 20;

      // Handle numeric type conversions from Supabase
      latitude = (station['latitude'] as num?)?.toDouble() ?? (station['lat'] as num?)?.toDouble();
      longitude = (station['longitude'] as num?)?.toDouble() ?? (station['lng'] as num?)?.toDouble();
    } else {
      // === ADD MODE ===
      latitude = widget.initialLat;
      longitude = widget.initialLng;
    }

    // Format coordinates description
    if (latitude != null && longitude != null) {
      latLngDesc = "Lat: ${latitude!.toStringAsFixed(5)}, Lng: ${longitude!.toStringAsFixed(5)}";
    } else {
      latLngDesc = "Location coordinates not provided";
    }
  }

  // --- SAVE / UPDATE SUPABASE BACKEND LOGIC ---
  Future<void> _saveStationToSupabase() async {
    // 1. Basic Form Validation
    if (stationName.trim().isEmpty) {
      _showSnackBar("Please enter a station name.");
      return;
    }
    if (stationAddress.trim().isEmpty) {
      _showSnackBar("Please enter a station address.");
      return;
    }
    if (latitude == null || longitude == null) {
      _showSnackBar("Missing location coordinates.");
      return;
    }

    setState(() => isSaving = true);

    try {
      final payload = {
        'name': stationName.trim(),
        'address': stationAddress.trim(),
        'latitude': latitude,
        'longitude': longitude,
        'capacity': maxBikes,
        'available_bikes': currentBikes,
        'status': operatingStatus,
        'is_active': operatingStatus != "Terminated",
        'updated_at': DateTime.now().toIso8601String(),
      };

      if (isEditMode) {
        // UPDATE existing record in Supabase
        final stationId = widget.stationToEdit!['id'];
        await supabase.from('stations').update(payload).eq('id', stationId);
        _showSnackBar("Station updated successfully!");
      } else {
        // INSERT new record into Supabase (Auto-generate unique code)
        payload['code'] = 'ST-${DateTime.now().millisecondsSinceEpoch.toString().substring(5)}';
        await supabase.from('stations').insert(payload);
        _showSnackBar("New station added successfully!");
      }

      if (mounted) {
        Navigator.pop(context, true); // Return true to trigger parent screen refresh
      }
    } catch (e) {
      _showSnackBar("Failed to save station: $e");
    } finally {
      if (mounted) setState(() => isSaving = false);
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            // 1. PHOTO UPLOAD HEADER AREA
            Container(
              height: 180,
              width: double.infinity,
              color: colorScheme.surfaceContainerHighest,
              child: Stack(
                children: [
                  Center(
                    child: Text(
                      "Click here to upload a photo",
                      style: TextStyle(
                        color: colorScheme.onSurface.withOpacity(0.5),
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Positioned(
                    top: 16,
                    left: 16,
                    child: CircleAvatar(
                      backgroundColor: colorScheme.surface,
                      child: IconButton(
                        icon: Icon(Icons.arrow_back, color: colorScheme.onSurface),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 2. STATION NAME ROW
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Station name",
                                style: TextStyle(color: colorScheme.onSurface.withOpacity(0.6), fontSize: 13),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                stationName.isEmpty ? "Enter station name" : stationName,
                                style: TextStyle(
                                  color: stationName.isEmpty ? colorScheme.onSurface.withOpacity(0.4) : colorScheme.onSurface,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          icon: Icon(Icons.edit_square, color: colorScheme.onSurface.withOpacity(0.7)),
                          onPressed: () => _showSingleInputDialog("Station name", stationName, (val) => setState(() => stationName = val)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // 3. ADDRESS ROW
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(Icons.location_on_outlined, color: colorScheme.primary),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                stationAddress.isEmpty ? "Enter Station Address" : stationAddress,
                                style: TextStyle(
                                  color: stationAddress.isEmpty ? colorScheme.onSurface.withOpacity(0.4) : colorScheme.onSurface,
                                  fontSize: 14,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                latLngDesc,
                                style: TextStyle(color: colorScheme.onSurface.withOpacity(0.5), fontSize: 12),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          icon: Icon(Icons.edit_square, color: colorScheme.onSurface.withOpacity(0.7)),
                          onPressed: () => _showSingleInputDialog("Station Address", stationAddress, (val) => setState(() => stationAddress = val)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // 4. DETAILS CARD
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: colorScheme.surfaceContainerHighest,
                        border: Border.all(color: colorScheme.outline),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text("Operating status", style: TextStyle(color: colorScheme.onSurface, fontSize: 14, fontWeight: FontWeight.bold)),
                                  const SizedBox(height: 4),
                                  Text(
                                    operatingStatus,
                                    style: TextStyle(
                                      color: operatingStatus == "Normal" ? colorScheme.secondary : colorScheme.tertiary,
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                              IconButton(
                                icon: Icon(Icons.edit_square, color: colorScheme.onSurface.withOpacity(0.7)),
                                padding: EdgeInsets.zero,
                                constraints: const BoxConstraints(),
                                onPressed: _showDetailsDialog,
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),
                          Text("Current bike available", style: TextStyle(color: colorScheme.onSurface, fontSize: 14, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Icon(Icons.directions_bike, color: colorScheme.primary),
                              const SizedBox(width: 8),
                              Text("$currentBikes", style: TextStyle(color: colorScheme.onSurface, fontSize: 20, fontWeight: FontWeight.bold)),
                            ],
                          ),
                          const SizedBox(height: 20),
                          Text("Max bike per station", style: TextStyle(color: colorScheme.onSurface, fontSize: 14, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Icon(Icons.directions_bike, color: colorScheme.primary),
                              const SizedBox(width: 8),
                              Text("$maxBikes", style: TextStyle(color: colorScheme.onSurface, fontSize: 20, fontWeight: FontWeight.bold)),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 40),

                    // 5. MAIN SAVE / UPDATE BUTTON
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: isSaving
                          ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2.5,
                        ),
                      )
                          : Text(
                        isEditMode ? "Update Station" : "Save Station",
                        style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // DIALOG GENERATORS
  void _showSingleInputDialog(String title, String initialValue, Function(String) onSave) {
    TextEditingController controller = TextEditingController(text: initialValue);
    final colorScheme = Theme.of(context).colorScheme;

    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: colorScheme.surfaceContainerHighest,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Align(
                alignment: Alignment.topRight,
                child: GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Icon(Icons.close, color: colorScheme.onSurface),
                ),
              ),
              TextField(
                controller: controller,
                maxLength: title == "Station name" ? 100 : 200,
                style: TextStyle(color: colorScheme.onSurface),
                decoration: InputDecoration(
                  hintText: "Enter $title",
                  hintStyle: TextStyle(color: colorScheme.onSurface.withOpacity(0.5)),
                  enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: colorScheme.outline)),
                  focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: colorScheme.primary)),
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                height: 45,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: colorScheme.primary,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
                  ),
                  onPressed: () {
                    onSave(controller.text);
                    Navigator.pop(context);
                  },
                  child: const Text("Save", style: TextStyle(color: Colors.white)),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  void _showDetailsDialog() {
    final colorScheme = Theme.of(context).colorScheme;
    String tempStatus = operatingStatus;
    int tempCurrent = currentBikes;
    int tempMax = maxBikes;

    TextEditingController currentCtrl = TextEditingController(text: tempCurrent.toString());
    TextEditingController maxCtrl = TextEditingController(text: tempMax.toString());

    void updateTextField(TextEditingController ctrl, int val) {
      ctrl.value = TextEditingValue(
        text: val.toString(),
        selection: TextSelection.collapsed(offset: val.toString().length),
      );
    }

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) {
          void updateCurrent(int val) {
            if (val > tempMax) val = tempMax;
            if (val < 0) val = 0;
            setDialogState(() => tempCurrent = val);
            updateTextField(currentCtrl, val);
          }

          void updateMax(int val) {
            if (val < tempCurrent) val = tempCurrent;
            if (val < 0) val = 0;
            setDialogState(() => tempMax = val);
            updateTextField(maxCtrl, val);
          }

          return Dialog(
            backgroundColor: colorScheme.surfaceContainerHighest,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Align(
                    alignment: Alignment.topRight,
                    child: GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Icon(Icons.close, color: colorScheme.onSurface),
                    ),
                  ),
                  Text("Operating status", style: TextStyle(color: colorScheme.onSurface, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _statusChip("Normal", colorScheme.secondary, tempStatus, () => setDialogState(() => tempStatus = "Normal")),
                      _statusChip("Under Maintenance", colorScheme.tertiary, tempStatus, () => setDialogState(() => tempStatus = "Under Maintenance")),
                      _statusChip("Terminated", const Color(0xFFDC2626), tempStatus, () => setDialogState(() => tempStatus = "Terminated")),
                    ],
                  ),
                  const SizedBox(height: 20),

                  Text("Current bike available", style: TextStyle(color: colorScheme.onSurface, fontWeight: FontWeight.bold)),
                  _bikeStepper(
                    controller: currentCtrl,
                    colorScheme: colorScheme,
                    onIncrement: () => updateCurrent(tempCurrent + 1),
                    onDecrement: () => updateCurrent(tempCurrent - 1),
                    onChanged: (val) => updateCurrent(int.tryParse(val) ?? 0),
                  ),
                  const SizedBox(height: 20),

                  Text("Max bike per station", style: TextStyle(color: colorScheme.onSurface, fontWeight: FontWeight.bold)),
                  _bikeStepper(
                    controller: maxCtrl,
                    colorScheme: colorScheme,
                    onIncrement: () => updateMax(tempMax + 1),
                    onDecrement: () => updateMax(tempMax - 1),
                    onChanged: (val) => updateMax(int.tryParse(val) ?? 0),
                  ),

                  const SizedBox(height: 30),
                  SizedBox(
                    width: double.infinity,
                    height: 45,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: colorScheme.primary,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
                      ),
                      onPressed: () {
                        setState(() {
                          operatingStatus = tempStatus;
                          currentBikes = tempCurrent;
                          maxBikes = tempMax;
                        });
                        Navigator.pop(context);
                      },
                      child: const Text("Save", style: TextStyle(color: Colors.white)),
                    ),
                  )
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _statusChip(String label, Color color, String currentStatus, VoidCallback onTap) {
    bool isSelected = currentStatus == label;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(12),
          border: isSelected ? Border.all(color: Colors.white, width: 2) : null,
        ),
        child: Text(label, style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
      ),
    );
  }

  Widget _bikeStepper({
    required TextEditingController controller,
    required ColorScheme colorScheme,
    required VoidCallback onIncrement,
    required VoidCallback onDecrement,
    required Function(String) onChanged,
  }) {
    return Row(
      children: [
        Icon(Icons.directions_bike, color: colorScheme.onSurface),
        const SizedBox(width: 8),
        SizedBox(
          width: 60,
          child: TextField(
            controller: controller,
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            style: TextStyle(color: colorScheme.onSurface, fontSize: 24, fontWeight: FontWeight.bold),
            decoration: const InputDecoration(border: InputBorder.none, isDense: true, contentPadding: EdgeInsets.zero),
            onChanged: onChanged,
          ),
        ),
        Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            GestureDetector(onTap: onIncrement, child: Icon(Icons.arrow_drop_up, color: colorScheme.onSurface, size: 28)),
            GestureDetector(onTap: onDecrement, child: Icon(Icons.arrow_drop_down, color: colorScheme.onSurface, size: 28)),
          ],
        )
      ],
    );
  }
}