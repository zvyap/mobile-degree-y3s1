import 'dart:io';
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

  late TextEditingController _nameController;
  late TextEditingController _codeController;
  late TextEditingController _addressController;
  late TextEditingController _capacityController;

  String _status = 'Normal';
  int _availableBikes = 0;
  String? _imageUrl;
  File? _selectedImageFile;

  bool _isLoading = false;
  bool _isSaving = false;
  bool _showBikesList = false;

  List<Map<String, dynamic>> _stationBikes = [];
  List<Map<String, dynamic>> _filteredBikes = [];
  final TextEditingController _bikeSearchController = TextEditingController();

  /// Generates collision-proof STN-AA-BBBBB station code
  String _generateStationCode(String stationName) {
    final lettersOnly = stationName.replaceAll(RegExp(r'[^a-zA-Z]'), '').toUpperCase();

    String prefix;
    if (lettersOnly.isEmpty) {
      prefix = 'ST';
    } else if (lettersOnly.length == 1) {
      prefix = '${lettersOnly}A';
    } else {
      prefix = lettersOnly.substring(0, 2);
    }

    final nowStr = DateTime.now().toIso8601String() + DateTime.now().microsecondsSinceEpoch.toString();

    int hash = 5381;
    for (int i = 0; i < nowStr.length; i++) {
      hash = ((hash << 5) + hash) + nowStr.codeUnitAt(i);
      hash = hash & 0xFFFFFFFF;
    }

    final hash5 = hash.abs().toRadixString(36).toUpperCase().padLeft(5, '0').substring(0, 5);

    return 'STN-$prefix-$hash5';
  }

  /// 🟢 Helper to delete an old image file from the 'app-uploads' bucket
  Future<void> _deleteOldImage(String imageUrl) async {
    try {
      String storagePath = imageUrl;
      if (imageUrl.startsWith('http')) {
        final Uri uri = Uri.parse(imageUrl);
        final List<String> segments = uri.pathSegments;
        final int bucketIndex = segments.indexOf('app-uploads');
        if (bucketIndex != -1 && bucketIndex < segments.length - 1) {
          storagePath = segments.sublist(bucketIndex + 1).join('/');
        }
      }

      if (storagePath.isNotEmpty) {
        await supabase.storage.from('app-uploads').remove([storagePath]);
      }
    } catch (e) {
      debugPrint("Failed to delete old image from storage: $e");
    }
  }

  @override
  void initState() {
    super.initState();
    final data = widget.stationData ?? {};

    _nameController = TextEditingController(text: data['name']?.toString() ?? '');

    final String initialCode = (data['code'] != null && data['code'].toString().isNotEmpty)
        ? data['code'].toString()
        : _generateStationCode(_nameController.text);

    _codeController = TextEditingController(text: initialCode);

    // Live code update when typing station name for new stations
    if (data['id'] == null) {
      _nameController.addListener(() {
        if (mounted) {
          setState(() {
            _codeController.text = _generateStationCode(_nameController.text);
          });
        }
      });
    }

    _addressController = TextEditingController(text: data['address']?.toString() ?? '');
    _capacityController = TextEditingController(text: (data['capacity'] ?? 20).toString());

    _status = data['status']?.toString() ?? 'Normal';
    _availableBikes = data['available_bikes'] is int ? data['available_bikes'] : 0;
    _imageUrl = data['image_url']?.toString();

    if (data['id'] != null) {
      _fetchStationBikes(data['id'].toString());
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _codeController.dispose();
    _addressController.dispose();
    _capacityController.dispose();
    _bikeSearchController.dispose();
    super.dispose();
  }

  Future<void> _fetchStationBikes(String stationId) async {
    setState(() => _isLoading = true);
    try {
      final dynamic targetId = int.tryParse(stationId) ?? stationId;

      final response = await supabase
          .from('bikes')
          .select()
          .eq('current_station_id', targetId)
          .order('id', ascending: true);

      final fetched = List<Map<String, dynamic>>.from(response);

      if (mounted) {
        setState(() {
          _stationBikes = fetched;
          _filteredBikes = fetched;
          _availableBikes = fetched.length;
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint("Error fetching station bikes: $e");
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _filterBikes(String query) {
    final q = query.trim().toLowerCase();
    setState(() {
      if (q.isEmpty) {
        _filteredBikes = _stationBikes;
      } else {
        _filteredBikes = _stationBikes.where((b) {
          final code = (b['code'] ?? '').toString().toLowerCase();
          final id = (b['id'] ?? '').toString().toLowerCase();
          return code.contains(q) || id.contains(q);
        }).toList();
      }
    });
  }

  Future<void> _pickAndUploadImage() async {
    final XFile? picked = await _picker.pickImage(source: ImageSource.gallery, imageQuality: 80);
    if (picked == null) return;

    setState(() {
      _selectedImageFile = File(picked.path);
    });
  }

  Future<void> _saveStation() async {
    final name = _nameController.text.trim();
    final address = _addressController.text.trim();
    final capacityText = _capacityController.text.trim();

    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Station name cannot be empty.')),
      );
      return;
    }

    if (address.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Station address cannot be empty.')),
      );
      return;
    }

    final capacity = int.tryParse(capacityText);
    if (capacity == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid number for max capacity.')),
      );
      return;
    }

    if (capacity < _availableBikes) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Max capacity ($capacity) cannot be less than current docked bikes ($_availableBikes).',
          ),
        ),
      );
      return;
    }

    setState(() => _isSaving = true);

    try {
      String? finalImageUrl = _imageUrl;

      if (_selectedImageFile != null) {
        // 🟢 If updating an existing picture, delete the old image from the storage bucket
        if (_imageUrl != null && _imageUrl!.isNotEmpty) {
          await _deleteOldImage(_imageUrl!);
        }

        final fileExt = _selectedImageFile!.path.split('.').last;
        final fileName = 'img_${DateTime.now().millisecondsSinceEpoch}.$fileExt';
        final storagePath = 'stations/$fileName';

        await supabase.storage.from('app-uploads').upload(
          storagePath,
          _selectedImageFile!,
        );

        finalImageUrl = supabase.storage.from('app-uploads').getPublicUrl(storagePath);
      }

      final String finalCode = widget.stationData?['id'] == null
          ? _generateStationCode(name)
          : _codeController.text.trim();

      final payload = {
        'name': name,
        'code': finalCode,
        'address': address,
        'capacity': capacity,
        'status': _status,
        if (finalImageUrl != null) 'image_url': finalImageUrl,
      };

      if (widget.stationData?['id'] != null) {
        await supabase.from('stations').update(payload).eq('id', widget.stationData!['id']);
      } else {
        payload['latitude'] = widget.initialLat ?? 0.0;
        payload['longitude'] = widget.initialLng ?? 0.0;
        payload['is_active'] = true;
        await supabase.from('stations').insert(payload);
      }

      if (mounted) {
        setState(() => _isSaving = false);
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isSaving = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to save station: $e')),
        );
      }
    }
  }

  Future<void> _deleteStation() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Remove Station"),
        content: const Text("Are you sure you want to remove this station?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text("Cancel")),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: TextButton.styleFrom(foregroundColor: Colors.redAccent),
            child: const Text("Remove"),
          ),
        ],
      ),
    );

    if (confirm != true || widget.stationData?['id'] == null) return;

    setState(() => _isSaving = true);
    try {
      await supabase.from('stations').update({'is_active': false}).eq('id', widget.stationData!['id']);
      if (mounted) {
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isSaving = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to remove station: $e')),
        );
      }
    }
  }

  void _showStatusPicker() {
    final options = ['Normal', 'Under Maintenance', 'Terminated'];
    showModalBottomSheet(
      context: context,
      builder: (ctx) => Column(
        mainAxisSize: MainAxisSize.min,
        children: options.map((opt) {
          return ListTile(
            title: Text(opt),
            trailing: _status == opt ? const Icon(Icons.check, color: Colors.blue) : null,
            onTap: () {
              setState(() => _status = opt);
              Navigator.pop(ctx);
            },
          );
        }).toList(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final bool isNewStation = widget.stationData?['id'] == null;

    if (_showBikesList) {
      return _buildBikesListView(colorScheme);
    }

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SingleChildScrollView(
        child: Column(
          children: [
            // PHOTO HEADER
            Stack(
              children: [
                Container(
                  height: 200,
                  width: double.infinity,
                  color: colorScheme.surfaceContainerHighest,
                  child: _selectedImageFile != null
                      ? Image.file(_selectedImageFile!, fit: BoxFit.cover)
                      : (_imageUrl != null && _imageUrl!.isNotEmpty
                      ? Image.network(_imageUrl!, fit: BoxFit.cover)
                      : Center(
                    child: Icon(Icons.storefront_rounded, size: 64, color: colorScheme.onSurface.withOpacity(0.3)),
                  )),
                ),
                if (!widget.isViewOnly)
                  Positioned(
                    right: 16,
                    bottom: 16,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black.withOpacity(0.7),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                      ),
                      onPressed: _pickAndUploadImage,
                      icon: const Icon(Icons.edit, size: 16),
                      label: const Text("Change Photo", style: TextStyle(fontSize: 12)),
                    ),
                  ),
              ],
            ),

            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // STATION DETAILS CARD
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: colorScheme.surfaceContainerHighest.withOpacity(0.5),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // NAME FIELD
                        Text("Station Name", style: TextStyle(color: colorScheme.onSurface.withOpacity(0.7), fontSize: 12, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 4),
                        TextField(
                          controller: _nameController,
                          readOnly: widget.isViewOnly,
                          style: TextStyle(color: colorScheme.onSurface, fontWeight: FontWeight.bold, fontSize: 16),
                          decoration: InputDecoration(
                            hintText: "Enter station name...",
                            hintStyle: TextStyle(color: colorScheme.onSurface.withOpacity(0.4), fontSize: 14),
                            isDense: true,
                            border: widget.isViewOnly ? InputBorder.none : const OutlineInputBorder(),
                          ),
                        ),
                        const SizedBox(height: 16),

                        // CODE FIELD
                        Row(
                          children: [
                            Text("Station Code", style: TextStyle(color: colorScheme.onSurface.withOpacity(0.7), fontSize: 12, fontWeight: FontWeight.bold)),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: colorScheme.onSurface.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                "Read-Only",
                                style: TextStyle(color: colorScheme.onSurface.withOpacity(0.5), fontSize: 10),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        TextField(
                          controller: _codeController,
                          readOnly: true,
                          style: TextStyle(color: colorScheme.onSurface.withOpacity(0.8), fontSize: 14, fontWeight: FontWeight.w600),
                          decoration: const InputDecoration(
                            isDense: true,
                            contentPadding: EdgeInsets.symmetric(vertical: 4),
                            border: InputBorder.none,
                          ),
                        ),
                        const SizedBox(height: 16),

                        // ADDRESS FIELD
                        Text("Address", style: TextStyle(color: colorScheme.onSurface.withOpacity(0.7), fontSize: 12, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 4),
                        TextField(
                          controller: _addressController,
                          readOnly: widget.isViewOnly,
                          maxLines: 2,
                          style: TextStyle(color: colorScheme.onSurface, fontSize: 14),
                          decoration: InputDecoration(
                            hintText: "Enter station address...",
                            hintStyle: TextStyle(color: colorScheme.onSurface.withOpacity(0.4), fontSize: 14),
                            isDense: true,
                            border: widget.isViewOnly ? InputBorder.none : const OutlineInputBorder(),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Divider(color: colorScheme.outline.withOpacity(0.3)),
                        const SizedBox(height: 12),

                        // OPERATING STATUS
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text("Operating status", style: TextStyle(color: colorScheme.onSurface, fontWeight: FontWeight.bold, fontSize: 14)),
                            if (!widget.isViewOnly)
                              IconButton(
                                icon: const Icon(Icons.edit_square, size: 20),
                                onPressed: _showStatusPicker,
                              ),
                          ],
                        ),
                        Text(
                          _status,
                          style: TextStyle(
                            color: _status == 'Normal'
                                ? const Color(0xFF10B981)
                                : (_status == 'Under Maintenance' ? const Color(0xFFF97316) : const Color(0xFFDC2626)),
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                          ),
                        ),
                        const SizedBox(height: 16),

                        // DOCKED BIKES
                        Row(
                          children: [
                            Text("Current Docked Bikes", style: TextStyle(color: colorScheme.onSurface.withOpacity(0.7), fontSize: 13)),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: colorScheme.onSurface.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text("Read-Only", style: TextStyle(color: colorScheme.onSurface.withOpacity(0.5), fontSize: 10)),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            Icon(Icons.directions_bike, color: colorScheme.primary, size: 20),
                            const SizedBox(width: 8),
                            Text("$_availableBikes", style: TextStyle(color: colorScheme.onSurface, fontWeight: FontWeight.bold, fontSize: 18)),
                          ],
                        ),
                        const SizedBox(height: 16),

                        // CAPACITY (Digits Only Filter)
                        Text("Max bike per station", style: TextStyle(color: colorScheme.onSurface.withOpacity(0.7), fontSize: 13)),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            Icon(Icons.directions_bike, color: colorScheme.primary, size: 20),
                            const SizedBox(width: 8),
                            Expanded(
                              child: widget.isViewOnly
                                  ? Text(_capacityController.text, style: TextStyle(color: colorScheme.onSurface, fontWeight: FontWeight.bold, fontSize: 18))
                                  : TextField(
                                controller: _capacityController,
                                keyboardType: TextInputType.number,
                                inputFormatters: [
                                  FilteringTextInputFormatter.digitsOnly,
                                ],
                                style: TextStyle(color: colorScheme.onSurface, fontWeight: FontWeight.bold, fontSize: 18),
                                decoration: const InputDecoration(isDense: true, contentPadding: EdgeInsets.zero, border: InputBorder.none),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // BUTTONS
                  if (!widget.isViewOnly) ...[
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF026aa7),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                        ),
                        onPressed: _isSaving ? null : _saveStation,
                        child: _isSaving
                            ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                            : Text(isNewStation ? "Add Station" : "Update Station", style: const TextStyle(fontWeight: FontWeight.bold)),
                      ),
                    ),
                    const SizedBox(height: 12),
                  ],

                  // Only show "View Bikes at Station" when modifying an existing station
                  if (!isNewStation) ...[
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: OutlinedButton.icon(
                        style: OutlinedButton.styleFrom(
                          foregroundColor: colorScheme.primary,
                          side: BorderSide(color: colorScheme.primary, width: 1.5),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                        ),
                        onPressed: () => setState(() => _showBikesList = true),
                        icon: const Icon(Icons.directions_bike, size: 18),
                        label: const Text("View Bikes at Station", style: TextStyle(fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ],

                  if (!widget.isViewOnly && !isNewStation) ...[
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: OutlinedButton.icon(
                        style: OutlinedButton.styleFrom(
                          foregroundColor: const Color(0xFFDC2626),
                          side: const BorderSide(color: Color(0xFFDC2626), width: 1.5),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                        ),
                        onPressed: _isSaving ? null : _deleteStation,
                        icon: const Icon(Icons.delete_outline, size: 18),
                        label: const Text("Remove Station", style: TextStyle(fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBikesListView(ColorScheme colorScheme) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back),
                  onPressed: () => setState(() => _showBikesList = false),
                ),
                Expanded(
                  child: Text(
                    _nameController.text.isNotEmpty ? _nameController.text : 'Station',
                    style: TextStyle(color: colorScheme.onSurface, fontWeight: FontWeight.bold, fontSize: 20),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 2),
            Padding(
              padding: const EdgeInsets.only(left: 48.0),
              child: Row(
                children: [
                  Icon(Icons.location_on_outlined, size: 16, color: colorScheme.primary),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      _addressController.text.isNotEmpty ? _addressController.text : 'No address set',
                      style: TextStyle(color: colorScheme.onSurface.withOpacity(0.6), fontSize: 12),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            TextField(
              controller: _bikeSearchController,
              onChanged: _filterBikes,
              style: TextStyle(color: colorScheme.onSurface, fontSize: 14),
              decoration: InputDecoration(
                hintText: 'Search bikes by code or ID',
                hintStyle: TextStyle(color: colorScheme.onSurface.withOpacity(0.5), fontSize: 13),
                prefixIcon: Icon(Icons.search, color: colorScheme.onSurface.withOpacity(0.5), size: 20),
                filled: true,
                fillColor: colorScheme.surfaceContainerHighest.withOpacity(0.5),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 10),
              ),
            ),

            const SizedBox(height: 16),

            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator.adaptive())
                  : (_filteredBikes.isEmpty
                  ? Center(
                child: Text(
                  "No bikes at this station.",
                  style: TextStyle(color: colorScheme.onSurface.withOpacity(0.5)),
                ),
              )
                  : ListView.builder(
                itemCount: _filteredBikes.length,
                itemBuilder: (context, index) {
                  final bike = _filteredBikes[index];
                  final String code = bike['code']?.toString() ?? 'BR-0000';
                  final String status = bike['status']?.toString() ?? 'Available';
                  final int battery = bike['battery_percent'] is int ? bike['battery_percent'] : 100;

                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: colorScheme.surfaceContainerHighest.withOpacity(0.5),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: colorScheme.surface,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(Icons.directions_bike, color: colorScheme.primary),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                code,
                                style: TextStyle(
                                  color: colorScheme.onSurface,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Row(
                                children: [
                                  Text(
                                    "Status: ${status.toLowerCase()}",
                                    style: TextStyle(
                                      color: status.toLowerCase() == 'available'
                                          ? const Color(0xFF10B981)
                                          : const Color(0xFFF59E0B),
                                      fontWeight: FontWeight.bold,
                                      fontSize: 11,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Icon(Icons.battery_std, size: 12, color: colorScheme.onSurface.withOpacity(0.6)),
                                  Text(
                                    "$battery%",
                                    style: TextStyle(
                                      color: colorScheme.onSurface.withOpacity(0.6),
                                      fontSize: 11,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.remove_red_eye_outlined),
                          onPressed: () {},
                        ),
                      ],
                    ),
                  );
                },
              )),
            ),
          ],
        ),
      ),
    );
  }
}