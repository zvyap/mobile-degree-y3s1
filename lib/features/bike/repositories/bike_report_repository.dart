import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:typed_data';
import '../models/bike_report.dart';

class BikeReportRepository {
  final SupabaseClient _supabase;

  BikeReportRepository({
    SupabaseClient? supabase,
  }) : _supabase = supabase ?? Supabase.instance.client;



  // ===========================================================================
  // CREATE REPORT
  // ===========================================================================

  Future<int> createReport({
    required int bikeId,
    required String category,
    required String description,
  }) async {
    final user =
        _supabase.auth.currentUser;

    if (user == null) {
      throw Exception(
        'You must be signed in to submit a report.',
      );
    }

    final response =
    await _supabase
        .from('bike_reports')
        .insert({
      'bike_id': bikeId,
      'reporter_id': user.id,
      'category': category,
      'description':
      description.trim(),
    })
        .select('id')
        .single();

    return response['id'] as int;
  }

  // ===========================================================================
  // GET ALL REPORTS
  // Admin sees all reports because of RLS.
  // Rider only sees their own reports.
  // ===========================================================================

  Future<List<BikeReport>> getReports() async {
    final response = await _supabase
        .from('bike_reports')
        .select('''
          id,
          bike_id,
          reporter_id,
          category,
          description,
          status,
          review_note,
          reviewed_by,
          reviewed_at,
          created_at,
          updated_at,
          bikes (
          code,
          stations (
            name
          )
        )
        ''')
        .order(
      'created_at',
      ascending: false,
    );

    return response
        .map<BikeReport>(
          (json) => BikeReport.fromJson(json),
    )
        .toList();
  }

  // ===========================================================================
  // GET PENDING REPORTS
  // ===========================================================================

  Future<List<BikeReport>> getPendingReports() async {
    final response = await _supabase
        .from('bike_reports')
        .select('''
          id,
          bike_id,
          reporter_id,
          category,
          description,
          status,
          review_note,
          reviewed_by,
          reviewed_at,
          created_at,
          updated_at,
          bikes (
              code,
  stations (
    name
  )
          )
        ''')
        .eq('status', 'pending')
        .order(
      'created_at',
      ascending: false,
    );

    return response
        .map<BikeReport>(
          (json) => BikeReport.fromJson(json),
    )
        .toList();
  }

  // ===========================================================================
  // GET SINGLE REPORT
  // ===========================================================================

  Future<BikeReport> getReport(
      int reportId,
      ) async {
    final response = await _supabase
        .from('bike_reports')
        .select('''
          id,
          bike_id,
          reporter_id,
          category,
          description,
          status,
          review_note,
          reviewed_by,
          reviewed_at,
          created_at,
          updated_at,
          bikes (
            code,
          stations (
            name
          )
          )
        ''')
        .eq('id', reportId)
        .single();

    return BikeReport.fromJson(response);
  }

  // ===========================================================================
  // APPROVE REPORT
  // ===========================================================================

  Future<void> approveReport({
    required int reportId,
    String? reviewNote,
  }) async {
    final user = _supabase.auth.currentUser;

    if (user == null) {
      throw Exception('User is not authenticated');
    }

    await _supabase
        .from('bike_reports')
        .update({
      'status': 'approved',
      'review_note': reviewNote?.trim(),
      'reviewed_by': user.id,
      'reviewed_at':
      DateTime.now().toUtc().toIso8601String(),
    })
        .eq('id', reportId);
  }

  // ===========================================================================
  // REJECT REPORT
  // ===========================================================================

  Future<void> rejectReport({
    required int reportId,
    String? reviewNote,
  }) async {
    final user = _supabase.auth.currentUser;

    if (user == null) {
      throw Exception('User is not authenticated');
    }

    await _supabase
        .from('bike_reports')
        .update({
      'status': 'rejected',
      'review_note': reviewNote?.trim(),
      'reviewed_by': user.id,
      'reviewed_at':
      DateTime.now().toUtc().toIso8601String(),
    })
        .eq('id', reportId);
  }

  Future<List<BikeReport>> getReportsForBike(
      int bikeId,
      ) async {
    final response = await _supabase
        .from('bike_reports')
        .select('''
        id,
        bike_id,
        reporter_id,
        category,
        description,
        status,
        review_note,
        reviewed_by,
        reviewed_at,
        created_at,
        updated_at,
        bikes (
          code,
          stations (
            name
          )
        )
      ''')
        .eq('bike_id', bikeId)
        .order(
      'created_at',
      ascending: false,
    );

    return response
        .map<BikeReport>(
          (json) => BikeReport.fromJson(json),
    )
        .toList();
  }

  Future<void> uploadReportPhoto({
    required int reportId,
    required Uint8List webpBytes,
  }) async {
    final user =
        _supabase.auth.currentUser;

    if (user == null) {
      throw Exception(
        'You must be signed in to upload a photo.',
      );
    }

    final path =
        '${user.id}/$reportId/report.webp';

    await _supabase.storage
        .from('bike-report-photos')
        .uploadBinary(
      path,
      webpBytes,
      fileOptions:
      const FileOptions(
        contentType:
        'image/webp',
        upsert:
        true,
      ),
    );
  }

}