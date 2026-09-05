import 'dart:io';
import 'package:bike_renting_app/bike_station/docking.dart';
import 'package:bike_renting_app/bike_station/supabase_storage_service.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class StationDetailScreen extends StatefulWidget {
  final Map<String, dynamic>? stationData;
  final double? initialLat;
  final double? initialLng;
  final bool isViewOnly;

  const StationDetailScreen({
    super.key,
    this.stationData,
    this.initialLat,
    this.initialLng,
    this.isViewOnly = false,
  });

  @override
  State<StationDetailScreen> createState() => _StationDetailScreenState();
}

class _StationDetailScreenState extends State<StationDetailScreen> {
  final SupabaseClient supabase = Supabase.instance.client;
  final ImagePicker _picker = ImagePicker();
  final SupabaseStorageService _storageService = SupabaseStorageService();

  String stationName = "";
  String stationAddress = "";
  String latLngDesc = "";
  String operatingStatus = "Normal";

  int currentBikes = 0;
  int maxBikes = 20;

  double? latitude;
  double? longitude;

  String? imageUrl;
  XFile? selectedImageFile;

  bool isSaving = false;
  bool showValidationErrors = false;

  bool get isEditMode => widget.stationData != null && !widget.isViewOnly;

  @override
  void initState() {
    super.initState();

    if (widget.stationData != null) {
      final station = widget.stationData!;
      stationName = station['name'] ?? "";
      stationAddress = station['address'] ?? "";
      operatingStatus = station['status'] ?? "Normal";
      imageUrl = station['image_url'] ?? station['photo_url'];

      currentBikes = (station['available_bikes'] as num?)?.toInt() ??
          (station['currentBikes'] as num?)?.toInt() ?? 0;
      maxBikes = (station['capacity'] as num?)?.toInt() ?? 20;

      latitude = (station['latitude'] as num?)?.toDouble() ?? (station['lat'] as num?)?.toDouble();
      longitude = (station['longitude'] as num?)?.toDouble() ?? (station['lng'] as num?)?.toDouble();
    } else {
      currentBikes = 0;
      maxBikes = 20;
      latitude = widget.initialLat;
      longitude = widget.initialLng;
    }

    if (latitude != null && longitude != null) {
      latLngDesc = "Lat: ${latitude!.toStringAsFixed(5)}, Lng: ${longitude!.toStringAsFixed(5)}";
    } else {
      latLngDesc = "Location coordinates not provided";
    }
  }

  Future<void> _pickImage() async {
    if (widget.isViewOnly) return;

    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
      );

      if (pickedFile != null) {
        setState(() {
          selectedImageFile = pickedFile;
        });
      }
    } catch (e) {
      _showSnackBar("Failed to select image: $e");
    }
  }

  Future<String?> _uploadImageToSupabase() async {
    if (selectedImageFile == null) return imageUrl;

    try {
      final String? oldImageUrl = imageUrl;

      final dynamic input = kIsWeb
          ? await selectedImageFile!.readAsBytes()
          : File(selectedImageFile!.path);

      final String? publicUrl = await _storageService.uploadWebpImage(
        imageInput: input,
        bucketName: 'app-uploads',
        folderPath: 'stations',
        quality: 80,
      );

      if (publicUrl != null && oldImageUrl != null && oldImageUrl.isNotEmpty) {
        try {
          await _storageService.deleteImage(
            bucketName: 'app-uploads',
            pathOrUrl: oldImageUrl,
          );
        } catch (deleteError) {
          debugPrint("Old image deletion error: $deleteError");
        }
      }

      return publicUrl ?? imageUrl;
    } catch (e) {
      debugPrint("Storage Upload Error: $e");
      _showSnackBar("Image upload failed: $e");
      return imageUrl;
    }
  }

  String _generateStationCode(String name) {
    final String prefix = name.trim().length >= 2
        ? name.trim().substring(0, 2).toUpperCase()
        : 'ST';
    final String timestamp = DateTime.now().millisecondsSinceEpoch.toString().substring(8);
    return 'STN-$prefix-$timestamp';
  }

  Future<void> _saveStationToSupabase() async {
    final nameEmpty = stationName.trim().isEmpty;
    final addressEmpty = stationAddress.trim().isEmpty;
    final coordsMissing = latitude == null || longitude == null;

    if (nameEmpty || addressEmpty || coordsMissing) {
      setState(() => showValidationErrors = true);
      _showSnackBar("Please fill in all required station details.");
      return;
    }

    final int minAllowedCapacity = currentBikes > 0 ? currentBikes : 1;
    if (maxBikes < minAllowedCapacity) {
      _showSnackBar("Max capacity ($maxBikes) cannot be less than available bikes ($currentBikes).");
      return;
    }

    setState(() => isSaving = true);

    try {
      final String? finalImageUrl = await _uploadImageToSupabase();

      final payload = {
        'name': stationName.trim(),
        'address': stationAddress.trim(),
        'latitude': latitude,
        'longitude': longitude,
        'capacity': maxBikes,
        'status': operatingStatus,
        'is_active': true,
        'image_url': finalImageUrl,
        'updated_at': DateTime.now().toIso8601String(),
      };

      if (isEditMode) {
        final stationId = widget.stationData!['id'];
        await supabase.from('stations').update(payload).eq('id', stationId);
        _showSnackBar("Station updated successfully!");
      } else {
        payload['code'] = _generateStationCode(stationName);
        await supabase.from('stations').insert(payload);
        _showSnackBar("New station added successfully!");
      }

      if (mounted) {
        Navigator.of(context).pop(true);
      }
    } catch (e) {
      _showSnackBar("Failed to save station: $e");
    } finally {
      if (mounted) setState(() => isSaving = false);
    }
  }

  Future<void> _removeStationFromSupabase() async {
    if (widget.stationData == null || widget.stationData!['id'] == null) return;

    final colorScheme = Theme.of(context).colorScheme;
    const destructiveColor = Color(0xFFDC2626);

    final bool? confirmed = await showDialog<bool>(
      context: context,
      useRootNavigator: true,
      builder: (dialogContext) => Dialog(
        backgroundColor: colorScheme.surfaceContainerHighest,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                "Are you sure to remove\n${stationName.trim().isEmpty ? 'this station' : stationName}?",
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: colorScheme.onSurface,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                "This action is irreversible, are you sure to continue?",
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: destructiveColor,
                  fontSize: 12,
                  fontStyle: FontStyle.italic,
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 44,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: destructiveColor,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
                  ),
                  onPressed: () => Navigator.of(dialogContext).pop(true),
                  child: const Text(
                    "Remove Location",
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                height: 44,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: colorScheme.surface,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
                  ),
                  onPressed: () => Navigator.of(dialogContext).pop(false),
                  child: Text(
                    "Cancel",
                    style: TextStyle(color: colorScheme.onSurface, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );

    if (confirmed != true) return;

    setState(() => isSaving = true);

    try {
      final stationId = widget.stationData!['id'];

      await supabase.from('stations').update({
        'is_active': false,
        'status': 'Terminated',
        'updated_at': DateTime.now().toIso8601String(),
      }).eq('id', stationId);

      _showSnackBar("Station removed successfully!");

      if (mounted) {
        Navigator.of(context).pop(true);
      }
    } catch (e) {
      _showSnackBar("Failed to remove station: $e");
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
    const errorColor = Color(0xFFDC2626);

    final bool nameHasError = showValidationErrors && stationName.trim().isEmpty;
    final bool addressHasError = showValidationErrors && stationAddress.trim().isEmpty;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            GestureDetector(
              onTap: _pickImage,
              child: Container(
                height: 180,
                width: double.infinity,
                color: colorScheme.surfaceContainerHighest,
                child: Stack(
                  children: [
                    if (selectedImageFile != null)
                      Positioned.fill(
                        child: kIsWeb
                            ? Image.network(selectedImageFile!.path, fit: BoxFit.cover)
                            : Image.file(File(selectedImageFile!.path), fit: BoxFit.cover),
                      )
                    else if (imageUrl != null && imageUrl!.isNotEmpty)
                      Positioned.fill(
                        child: Image.network(
                          imageUrl!,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) => Center(
                            child: Icon(Icons.broken_image, color: colorScheme.onSurface.withValues(alpha: 0.5)),
                          ),
                        ),
                      )
                    else
                      Center(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.add_a_photo, color: colorScheme.onSurface.withValues(alpha: 0.5), size: 20),
                            const SizedBox(width: 8),
                            Text(
                              widget.isViewOnly ? "No Station Photo" : "Click here to upload a photo",
                              style: TextStyle(
                                color: colorScheme.onSurface.withValues(alpha: 0.5),
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    Positioned(
                      top: 16,
                      left: 16,
                      child: CircleAvatar(
                        backgroundColor: colorScheme.surface.withValues(alpha: 0.8),
                        child: IconButton(
                          icon: Icon(Icons.arrow_back, color: colorScheme.onSurface),
                          onPressed: () => Navigator.of(context).pop(),
                        ),
                      ),
                    ),
                    if (!widget.isViewOnly && (selectedImageFile != null || (imageUrl != null && imageUrl!.isNotEmpty)))
                      Positioned(
                        bottom: 12,
                        right: 12,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.6),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Row(
                            children: [
                              Icon(Icons.edit, color: Colors.white, size: 14),
                              SizedBox(width: 4),
                              Text("Change Photo", style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold)),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: nameHasError ? const EdgeInsets.all(12) : EdgeInsets.zero,
                      decoration: nameHasError
                          ? BoxDecoration(
                        border: Border.all(color: errorColor, width: 1.5),
                        borderRadius: BorderRadius.circular(12),
                      )
                          : null,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Station name",
                                  style: TextStyle(
                                    color: nameHasError ? errorColor : colorScheme.onSurface.withValues(alpha: 0.6),
                                    fontSize: 13,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  stationName.trim().isEmpty ? "Enter station name *" : stationName,
                                  style: TextStyle(
                                    color: stationName.trim().isEmpty
                                        ? (nameHasError ? errorColor : colorScheme.onSurface.withValues(alpha: 0.4))
                                        : colorScheme.onSurface,
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          if (!widget.isViewOnly)
                            IconButton(
                              icon: Icon(Icons.edit_square, color: nameHasError ? errorColor : colorScheme.onSurface.withValues(alpha: 0.7)),
                              onPressed: () => _showSingleInputDialog(
                                "Station name",
                                stationName,
                                    (val) => setState(() {
                                  stationName = val;
                                  if (stationName.trim().isNotEmpty) showValidationErrors = false;
                                }),
                              ),
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    Container(
                      padding: addressHasError ? const EdgeInsets.all(12) : EdgeInsets.zero,
                      decoration: addressHasError
                          ? BoxDecoration(
                        border: Border.all(color: errorColor, width: 1.5),
                        borderRadius: BorderRadius.circular(12),
                      )
                          : null,
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(Icons.location_on_outlined, color: addressHasError ? errorColor : colorScheme.primary),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  stationAddress.trim().isEmpty ? "Enter Station Address *" : stationAddress,
                                  style: TextStyle(
                                    color: stationAddress.trim().isEmpty
                                        ? (addressHasError ? errorColor : colorScheme.onSurface.withValues(alpha: 0.4))
                                        : colorScheme.onSurface,
                                    fontSize: 14,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  latLngDesc,
                                  style: TextStyle(color: colorScheme.onSurface.withValues(alpha: 0.5), fontSize: 12),
                                ),
                              ],
                            ),
                          ),
                          if (!widget.isViewOnly)
                            IconButton(
                              icon: Icon(Icons.edit_square, color: addressHasError ? errorColor : colorScheme.onSurface.withValues(alpha: 0.7)),
                              onPressed: () => _showSingleInputDialog(
                                "Station Address",
                                stationAddress,
                                    (val) => setState(() {
                                  stationAddress = val;
                                  if (stationAddress.trim().isNotEmpty) showValidationErrors = false;
                                }),
                              ),
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

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
                              if (!widget.isViewOnly)
                                IconButton(
                                  icon: Icon(Icons.edit_square, color: colorScheme.onSurface.withValues(alpha: 0.7)),
                                  padding: EdgeInsets.zero,
                                  constraints: const BoxConstraints(),
                                  onPressed: _showDetailsDialog,
                                ),
                            ],
                          ),
                          const SizedBox(height: 20),

                          Row(
                            children: [
                              Text("Current bike available", style: TextStyle(color: colorScheme.onSurface.withValues(alpha: 0.7), fontSize: 13)),
                              const SizedBox(width: 6),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: colorScheme.onSurface.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text("Read-Only", style: TextStyle(color: colorScheme.onSurface.withValues(alpha: 0.5), fontSize: 10, fontWeight: FontWeight.bold)),
                              ),
                            ],
                          ),
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

                    // 🟢 ADMIN ONLY ACTIONS
                    if (!widget.isViewOnly) ...[
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: colorScheme.primary,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
                          ),
                          onPressed: isSaving ? null : _saveStationToSupabase,
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
                      ),
                      if (isEditMode) ...[
                        const SizedBox(height: 12),
                        // 🟢 View Bikes at Station is only accessible by Admin
                        SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: OutlinedButton.icon(
                            style: OutlinedButton.styleFrom(
                              foregroundColor: colorScheme.primary,
                              side: BorderSide(color: colorScheme.primary, width: 1.5),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
                            ),
                            icon: const Icon(Icons.directions_bike_rounded),
                            label: const Text(
                              "View Bikes at Station",
                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => StationBikesScreen(
                                    stationData: widget.stationData,
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                        const SizedBox(height: 12),
                        SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: OutlinedButton.icon(
                            style: OutlinedButton.styleFrom(
                              foregroundColor: errorColor,
                              side: const BorderSide(color: errorColor, width: 1.5),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
                            ),
                            icon: const Icon(Icons.delete_outline, color: errorColor),
                            label: const Text(
                              "Remove Station",
                              style: TextStyle(color: errorColor, fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                            onPressed: isSaving ? null : _removeStationFromSupabase,
                          ),
                        ),
                      ],
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showSingleInputDialog(String title, String initialValue, Function(String) onSave) async {
    final TextEditingController controller = TextEditingController(text: initialValue);
    final colorScheme = Theme.of(context).colorScheme;
    const errorColor = Color(0xFFDC2626);
    String? localError;

    await showDialog(
      context: context,
      useRootNavigator: true,
      builder: (dialogContext) => StatefulBuilder(
        builder: (dialogContext, setDialogState) {
          return Dialog(
            backgroundColor: colorScheme.surfaceContainerHighest,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Align(
                      alignment: Alignment.topRight,
                      child: GestureDetector(
                        onTap: () => Navigator.of(dialogContext, rootNavigator: true).pop(),
                        child: Icon(Icons.close, color: colorScheme.onSurface),
                      ),
                    ),
                    Text("Edit $title", style: TextStyle(color: colorScheme.onSurface, fontWeight: FontWeight.bold, fontSize: 16)),
                    const SizedBox(height: 12),
                    TextField(
                      controller: controller,
                      maxLength: title == "Station name" ? 100 : 200,
                      style: TextStyle(color: colorScheme.onSurface),
                      decoration: InputDecoration(
                        hintText: "Enter $title",
                        hintStyle: TextStyle(color: colorScheme.onSurface.withValues(alpha: 0.5)),
                        errorText: localError,
                        errorStyle: const TextStyle(color: errorColor, fontWeight: FontWeight.w600),
                        enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: localError != null ? errorColor : colorScheme.outline)),
                        focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: localError != null ? errorColor : colorScheme.primary)),
                      ),
                      onChanged: (val) {
                        if (localError != null && val.trim().isNotEmpty) {
                          setDialogState(() => localError = null);
                        }
                      },
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
                          final String trimmedValue = controller.text.trim();
                          if (trimmedValue.isEmpty) {
                            setDialogState(() => localError = "$title cannot be empty.");
                            return;
                          }
                          onSave(trimmedValue);
                          Navigator.of(dialogContext, rootNavigator: true).pop();
                        },
                        child: const Text("Save", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                      ),
                    )
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  void _showDetailsDialog() async {
    final colorScheme = Theme.of(context).colorScheme;
    String tempStatus = operatingStatus;
    int tempMax = maxBikes;

    final TextEditingController maxCtrl = TextEditingController(text: tempMax.toString());

    void updateTextField(TextEditingController ctrl, int val) {
      ctrl.value = TextEditingValue(
        text: val.toString(),
        selection: TextSelection.collapsed(offset: val.toString().length),
      );
    }

    await showDialog(
      context: context,
      useRootNavigator: true,
      builder: (dialogContext) => StatefulBuilder(
        builder: (dialogContext, setDialogState) {
          final int minCapacity = currentBikes > 0 ? currentBikes : 1;

          void updateMax(int val) {
            if (val < minCapacity) {
              val = minCapacity;
            }
            setDialogState(() => tempMax = val);
            updateTextField(maxCtrl, val);
          }

          return Dialog(
            backgroundColor: colorScheme.surfaceContainerHighest,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Align(
                      alignment: Alignment.topRight,
                      child: GestureDetector(
                        onTap: () => Navigator.of(dialogContext, rootNavigator: true).pop(),
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

                    Text("Current bike available", style: TextStyle(color: colorScheme.onSurface.withValues(alpha: 0.6), fontSize: 13)),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Icon(Icons.directions_bike, color: colorScheme.onSurface.withValues(alpha: 0.5)),
                        const SizedBox(width: 8),
                        Text("$currentBikes", style: TextStyle(color: colorScheme.onSurface.withValues(alpha: 0.7), fontSize: 20, fontWeight: FontWeight.bold)),
                        const SizedBox(width: 8),
                        Text("(Read-Only)", style: TextStyle(color: colorScheme.onSurface.withValues(alpha: 0.4), fontSize: 11, fontStyle: FontStyle.italic)),
                      ],
                    ),
                    const SizedBox(height: 20),

                    Text("Max bike per station", style: TextStyle(color: colorScheme.onSurface, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 2),
                    Text(
                      currentBikes > 0
                          ? "Cannot be lower than available bikes ($currentBikes)"
                          : "Minimum capacity is 1",
                      style: TextStyle(color: colorScheme.onSurface.withValues(alpha: 0.5), fontSize: 11),
                    ),
                    const SizedBox(height: 8),
                    _bikeStepper(
                      controller: maxCtrl,
                      colorScheme: colorScheme,
                      onIncrement: () => updateMax(tempMax + 1),
                      onDecrement: () => updateMax(tempMax - 1),
                      onChanged: (val) => updateMax(int.tryParse(val) ?? minCapacity),
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
                            maxBikes = tempMax;
                          });
                          Navigator.of(dialogContext, rootNavigator: true).pop();
                        },
                        child: const Text("Save", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                      ),
                    )
                  ],
                ),
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