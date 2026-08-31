import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Required for input formatting (digits only)

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
  // --- UI Colors ---
  final Color bgColor = const Color(0xFF10141D);
  final Color cardColor = const Color(0xFF19202E);
  final Color primaryBlue = const Color(0xFF4358F5);
  final Color textGrey = const Color(0xFFA0A5B1);



  // --- State Variables ---
  // Initialized as empty so placeholders show up by default
  String stationName = "";
  String stationAddress = "";
  String latLngDesc = "Lat: 5.4643, Lng: 100.2841";
  String operatingStatus = "Normal";

  int currentBikes = 16;
  int maxBikes = 20;

  double? latitude;
  double? longitude;

  @override
  void initState() {
    super.initState();

    if (widget.stationToEdit != null) {
      // === EDIT MODE ===
      stationName = widget.stationToEdit!['name'] ?? "";
      stationAddress = widget.stationToEdit!['address'] ?? "";
      operatingStatus = widget.stationToEdit!['status'] ?? "Normal";
      currentBikes = widget.stationToEdit!['currentBikes'] ?? 0;
      maxBikes = widget.stationToEdit!['maxBikes'] ?? 20;
      latitude = widget.stationToEdit!['lat'];
      longitude = widget.stationToEdit!['lng'];
    } else {
      // === ADD MODE ===
      // Capture the coordinates passed from the map's long-press
      latitude = widget.initialLat;
      longitude = widget.initialLng;
    }

    // Dynamically generate the description text for the UI
    if (latitude != null && longitude != null) {
      // toStringAsFixed(5) keeps the coordinates visually clean on the screen
      latLngDesc = "Lat: ${latitude!.toStringAsFixed(5)}, Lng: ${longitude!.toStringAsFixed(5)}";
    } else {
      latLngDesc = "Location coordinates not provided";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: Column(
          children: [
            // 1. PHOTO UPLOAD AREA
            Container(
              height: 200,
              width: double.infinity,
              color: Colors.white,
              child: Stack(
                children: [
                  const Center(
                    child: Text(
                      "Click here to upload a photo",
                      style: TextStyle(color: Colors.grey, fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ),
                  Positioned(
                    top: 16,
                    left: 16,
                    child: CircleAvatar(
                      backgroundColor: bgColor,
                      child: IconButton(
                        icon: const Icon(Icons.arrow_back, color: Colors.white),
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
                    // 2. STATION NAME ROW (With Placeholder Logic)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("Station name", style: TextStyle(color: textGrey, fontSize: 14)),
                              const SizedBox(height: 4),
                              Text(
                                  stationName.isEmpty ? "Enter station name" : stationName,
                                  style: TextStyle(
                                      color: stationName.isEmpty ? textGrey : Colors.white,
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold
                                  )
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.edit_square, color: Colors.white70),
                          onPressed: () => _showSingleInputDialog("Station name", stationName, (val) => setState(() => stationName = val)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // 3. ADDRESS ROW (With Placeholder Logic)
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.location_on_outlined, color: Colors.white),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                  stationAddress.isEmpty ? "Enter Station Address" : stationAddress,
                                  style: TextStyle(
                                      color: stationAddress.isEmpty ? textGrey : Colors.white,
                                      fontSize: 14
                                  )
                              ),
                              const SizedBox(height: 4),
                              Text(latLngDesc, style: TextStyle(color: textGrey, fontSize: 12)),
                            ],
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.edit_square, color: Colors.white70),
                          onPressed: () => _showSingleInputDialog("Station Address", stationAddress, (val) => setState(() => stationAddress = val)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // 4. DETAILS CARD
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.transparent,
                        border: Border.all(color: Colors.white24),
                        borderRadius: BorderRadius.circular(12),
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
                                  const Text("Operating status", style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold)),
                                  const SizedBox(height: 4),
                                  Text(
                                    operatingStatus,
                                    style: TextStyle(
                                      color: operatingStatus == "Normal" ? Colors.green : Colors.orange,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                              IconButton(
                                icon: const Icon(Icons.edit_square, color: Colors.white70),
                                padding: EdgeInsets.zero,
                                constraints: const BoxConstraints(),
                                onPressed: _showDetailsDialog,
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),
                          const Text("Current bike available", style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              const Icon(Icons.directions_bike, color: Colors.white),
                              const SizedBox(width: 8),
                              Text("$currentBikes", style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                            ],
                          ),
                          const SizedBox(height: 20),
                          const Text("Max bike per station", style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              const Icon(Icons.directions_bike, color: Colors.white),
                              const SizedBox(width: 8),
                              Text("$maxBikes", style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 40),

                    // 5. MAIN SAVE BUTTON
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primaryBlue,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
                        ),
                        onPressed: () {
                          // TODO: Save to backend
                        },
                        child: const Text("Save station", style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
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

  // ==========================================
  // DIALOG GENERATORS
  // ==========================================

  void _showSingleInputDialog(String title, String initialValue, Function(String) onSave) {
    TextEditingController controller = TextEditingController(text: initialValue);

    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: cardColor,
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
                  child: const Icon(Icons.close, color: Colors.white),
                ),
              ),
              TextField(
                controller: controller,
                maxLength: title == "Station name" ? 100 : 200,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: "Enter $title",
                  hintStyle: TextStyle(color: textGrey),
                  enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: textGrey)),
                  focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: primaryBlue)),
                  counterStyle: TextStyle(color: textGrey),
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                height: 45,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: primaryBlue, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25))),
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
    String tempStatus = operatingStatus;
    int tempCurrent = currentBikes;
    int tempMax = maxBikes;

    // Controllers to handle the manual text input
    TextEditingController currentCtrl = TextEditingController(text: tempCurrent.toString());
    TextEditingController maxCtrl = TextEditingController(text: tempMax.toString());

    // Helper to keep cursor at the end when the value is clamped
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

            // Rule 2 Check: Current cannot be more than Max
            void updateCurrent(int val) {
              if (val > tempMax) val = tempMax;
              if (val < 0) val = 0;
              setDialogState(() => tempCurrent = val);
              updateTextField(currentCtrl, val);
            }

            // Rule 2 Check: Max cannot be lower than Current
            void updateMax(int val) {
              if (val < tempCurrent) val = tempCurrent;
              if (val < 0) val = 0;
              setDialogState(() => tempMax = val);
              updateTextField(maxCtrl, val);
            }

            return Dialog(
              backgroundColor: cardColor,
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
                        child: const Icon(Icons.close, color: Colors.white),
                      ),
                    ),
                    const Text("Operating status", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        _statusChip("Normal", Colors.green, tempStatus, () => setDialogState(() => tempStatus = "Normal")),
                        _statusChip("Under Maintenance", Colors.orange, tempStatus, () => setDialogState(() => tempStatus = "Under Maintenance")),
                        _statusChip("Terminated", Colors.red, tempStatus, () => setDialogState(() => tempStatus = "Terminated")),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // Current Bikes Input / Stepper
                    const Text("Current bike available", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    _bikeStepper(
                        controller: currentCtrl,
                        onIncrement: () => updateCurrent(tempCurrent + 1),
                        onDecrement: () => updateCurrent(tempCurrent - 1),
                        onChanged: (val) {
                          int parsed = int.tryParse(val) ?? 0;
                          updateCurrent(parsed);
                        }
                    ),
                    const SizedBox(height: 20),

                    // Max Bikes Input / Stepper
                    const Text("Max bike per station", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    _bikeStepper(
                        controller: maxCtrl,
                        onIncrement: () => updateMax(tempMax + 1),
                        onDecrement: () => updateMax(tempMax - 1),
                        onChanged: (val) {
                          int parsed = int.tryParse(val) ?? 0;
                          updateMax(parsed);
                        }
                    ),

                    const SizedBox(height: 30),
                    SizedBox(
                      width: double.infinity,
                      height: 45,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(backgroundColor: primaryBlue, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25))),
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
          }
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

  // --- Rule 3: Inputtable TextField Stepper Component ---
  Widget _bikeStepper({
    required TextEditingController controller,
    required VoidCallback onIncrement,
    required VoidCallback onDecrement,
    required Function(String) onChanged,
  }) {
    return Row(
      children: [
        const Icon(Icons.directions_bike, color: Colors.white),
        const SizedBox(width: 8),
        SizedBox(
          width: 60, // Restrict width so it behaves like a label
          child: TextField(
            controller: controller,
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly], // Only accept numbers
            style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
            decoration: const InputDecoration(
              border: InputBorder.none,
              isDense: true,
              contentPadding: EdgeInsets.zero,
            ),
            onChanged: onChanged,
          ),
        ),
        Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            GestureDetector(onTap: onIncrement, child: const Icon(Icons.arrow_drop_up, color: Colors.white, size: 28)),
            GestureDetector(onTap: onDecrement, child: const Icon(Icons.arrow_drop_down, color: Colors.white, size: 28)),
          ],
        )
      ],
    );
  }
}