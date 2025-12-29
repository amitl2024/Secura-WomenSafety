import 'dart:io';

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:pdf/pdf.dart' as pdf;
import 'package:share_plus/share_plus.dart';
import 'package:ai_women_safety/data/services/report_service.dart';
import 'package:ai_women_safety/data/models/report_model.dart';
import 'package:ai_women_safety/utils/logger_util.dart';

class IncidentReportPage extends StatefulWidget {
  const IncidentReportPage({super.key});

  @override
  State<IncidentReportPage> createState() => _IncidentReportPageState();
}

class _IncidentReportPageState extends State<IncidentReportPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();
  DateTime _dateTime = DateTime.now();
  bool _anonymized = false;
  String? _tag; // harassment, stalking, theft, other
  Position? _position;
  final List<XFile> _media = [];

  @override
  void dispose() {
    _titleController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Incident Report'),
        backgroundColor: const Color(0xFFE91E63),
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _buildSectionCard(
                title: 'Details',
                child: Column(
                  children: [
                    TextFormField(
                      controller: _titleController,
                      decoration: const InputDecoration(
                        labelText: 'Title (optional)',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _notesController,
                      minLines: 4,
                      maxLines: 8,
                      decoration: const InputDecoration(
                        labelText: 'What happened? (notes)',
                        border: OutlineInputBorder(),
                      ),
                      validator:
                          (v) =>
                              (v == null || v.trim().isEmpty)
                                  ? 'Please add notes'
                                  : null,
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: InputDecorator(
                            decoration: const InputDecoration(
                              labelText: 'Date & time',
                              border: OutlineInputBorder(),
                            ),
                            child: Text(
                              DateFormat('yyyy-MM-dd HH:mm').format(_dateTime),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        ElevatedButton(
                          onPressed: _pickDateTime,
                          child: const Text('Change'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              _buildSectionCard(
                title: 'Category',
                child: DropdownButtonFormField<String>(
                  value: _tag,
                  items: const [
                    DropdownMenuItem(
                      value: 'harassment',
                      child: Text('Harassment'),
                    ),
                    DropdownMenuItem(
                      value: 'stalking',
                      child: Text('Stalking'),
                    ),
                    DropdownMenuItem(value: 'theft', child: Text('Theft')),
                    DropdownMenuItem(value: 'other', child: Text('Other')),
                  ],
                  onChanged: (v) => setState(() => _tag = v),
                  decoration: const InputDecoration(
                    labelText: 'Select tag',
                    border: OutlineInputBorder(),
                  ),
                  validator: (v) => v == null ? 'Please choose a tag' : null,
                ),
              ),
              const SizedBox(height: 12),
              _buildSectionCard(
                title: 'Location',
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: InputDecorator(
                            decoration: const InputDecoration(
                              labelText: 'Coordinates',
                              border: OutlineInputBorder(),
                            ),
                            child: Text(
                              _position == null
                                  ? 'Not captured'
                                  : '${_position!.latitude.toStringAsFixed(6)}, ${_position!.longitude.toStringAsFixed(6)}',
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        ElevatedButton(
                          onPressed: _captureLocation,
                          child: const Text('Capture'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Tip: Move to an open space for better GPS accuracy.',
                      style: TextStyle(color: Colors.black54, fontSize: 12),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              _buildSectionCard(
                title: 'Media (photos/videos)',
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        ..._media.map(
                          (x) => Stack(
                            alignment: Alignment.topRight,
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.file(
                                  File(x.path),
                                  width: 100,
                                  height: 100,
                                  fit: BoxFit.cover,
                                ),
                              ),
                              GestureDetector(
                                onTap: () => setState(() => _media.remove(x)),
                                child: Container(
                                  margin: const EdgeInsets.all(4),
                                  decoration: BoxDecoration(
                                    color: Colors.black.withValues(alpha: 0.6),
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.close,
                                    color: Colors.white,
                                    size: 16,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        GestureDetector(
                          onTap: _pickMedia,
                          child: Container(
                            width: 100,
                            height: 100,
                            decoration: BoxDecoration(
                              color: Colors.grey[200],
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.grey[300]!),
                            ),
                            child: const Icon(
                              Icons.add_a_photo,
                              color: Colors.black54,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Avoid risky confrontation to capture media. Your safety first.',
                      style: TextStyle(color: Colors.black54, fontSize: 12),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              _buildSectionCard(
                title: 'Privacy',
                child: SwitchListTile.adaptive(
                  value: _anonymized,
                  onChanged: (v) => setState(() => _anonymized = v),
                  title: const Text(
                    'Submit anonymized (hide name/email/phone)',
                  ),
                  contentPadding: EdgeInsets.zero,
                ),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _previewPdf,
                      icon: const Icon(Icons.picture_as_pdf),
                      label: const Text('Preview PDF'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _exportAndSharePdf,
                      icon: const Icon(Icons.share),
                      label: const Text('Export & Share'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFE91E63),
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              ElevatedButton.icon(
                onPressed: _submitToDatabase,
                icon: const Icon(Icons.save),
                label: const Text('Report'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF6366F1),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                // Make the button full width
                // We'll add full width through padding in the style
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionCard({required String title, required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2D3748),
            ),
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }

  Future<void> _pickDateTime() async {
    final d = await showDatePicker(
      context: context,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      initialDate: _dateTime,
    );
    if (d == null) return;

    // Check if widget is still mounted before using context again
    if (!mounted) return;

    final t = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_dateTime),
    );
    if (t == null) return;
    setState(
      () => _dateTime = DateTime(d.year, d.month, d.day, t.hour, t.minute),
    );
  }

  Future<void> _captureLocation() async {
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Enable location services to capture location'),
          ),
        );
      }
      return;
    }
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Location permission denied')),
          );
        }
        return;
      }
    }
    if (permission == LocationPermission.deniedForever) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Location permission permanently denied'),
          ),
        );
      }
      return;
    }
    final Position pos = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
    setState(() => _position = pos);
  }

  Future<void> _pickMedia() async {
    final ImagePicker picker = ImagePicker();
    final List<XFile> files = await picker.pickMultiImage(imageQuality: 80);
    if (files.isNotEmpty) {
      setState(() => _media.addAll(files));
    }
  }

  Future<pw.Document> _buildPdfDoc() async {
    final doc = pw.Document();
    final dateStr = DateFormat('yyyy-MM-dd HH:mm').format(_dateTime);

    final List<pw.Widget> mediaWidgets = [];
    for (final x in _media.take(6)) {
      try {
        final bytes = await File(x.path).readAsBytes();
        final img = pw.Image(pw.MemoryImage(bytes));
        mediaWidgets.add(
          pw.Container(
            width: 160,
            height: 120,
            decoration: pw.BoxDecoration(
              border: pw.Border.all(color: pdf.PdfColors.grey400),
            ),
            child: img,
          ),
        );
      } catch (_) {}
    }

    doc.addPage(
      pw.MultiPage(
        build:
            (ctx) => [
              pw.Text(
                'Incident Report',
                style: pw.TextStyle(
                  fontSize: 22,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.SizedBox(height: 12),
              pw.Text('Category: ${_tag ?? '-'}'),
              pw.Text('Date & time: $dateStr'),
              pw.Text(
                'Location: ${_position != null ? '${_position!.latitude.toStringAsFixed(6)}, ${_position!.longitude.toStringAsFixed(6)}' : '-'}',
              ),
              pw.Text('Anonymized: ${_anonymized ? 'Yes' : 'No'}'),
              pw.SizedBox(height: 12),
              if (_titleController.text.trim().isNotEmpty)
                pw.Text('Title: ${_titleController.text.trim()}'),
              pw.Text('Notes:'),
              pw.Container(
                padding: const pw.EdgeInsets.all(8),
                decoration: pw.BoxDecoration(border: pw.Border.all()),
                child: pw.Text(_notesController.text.trim()),
              ),
              pw.SizedBox(height: 12),
              if (mediaWidgets.isNotEmpty) pw.Text('Media evidence:'),
              if (mediaWidgets.isNotEmpty)
                pw.Wrap(spacing: 8, runSpacing: 8, children: mediaWidgets),
            ],
      ),
    );
    return doc;
  }

  Future<void> _previewPdf() async {
    // Printing package removed due to dependency conflict.
    // Fallback: directly export & share the PDF.
    await _exportAndSharePdf();
  }

  Future<void> _exportAndSharePdf() async {
    if (!_formValid()) return;
    final doc = await _buildPdfDoc();
    final bytes = await doc.save();
    final dir = await getTemporaryDirectory();
    final path =
        '${dir.path}/incident_${DateTime.now().millisecondsSinceEpoch}.pdf';
    final file = File(path);
    await file.writeAsBytes(bytes, flush: true);
    await Share.shareXFiles([XFile(file.path)], text: 'Incident report');
  }

  bool _formValid() {
    final ok = _formKey.currentState?.validate() ?? false;
    if (!ok) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please complete required fields')),
      );
    }
    return ok;
  }

  Future<void> _submitToDatabase() async {
    if (!_formValid()) return;

    // Show loading indicator
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    bool success = false;
    String? errorMessage;

    try {
      // Convert XFile list to File list for upload
      final List<File> imageFiles =
          _media.map((xFile) => File(xFile.path)).toList();

      // Create report object
      final report = ReportModel(
        id: null,
        title:
            _titleController.text.trim().isEmpty
                ? 'Untitled Report'
                : _titleController.text.trim(),
        description: _notesController.text.trim(),
        category: _tag ?? 'other',
        status: 'pending',
        isAnonymous: _anonymized,
        userName: _anonymized ? '' : 'Current User',
        userEmail: _anonymized ? '' : '',
        timestamp: _dateTime,
        userId: _anonymized ? '' : '',
        location:
            _position != null
                ? '${_position!.latitude.toStringAsFixed(6)}, ${_position!.longitude.toStringAsFixed(6)}'
                : null,
        latitude: _position?.latitude,
        longitude: _position?.longitude,
        imageUrls: [],
        adminNotes: null,
      );

      // Submit report with images to Firebase and Supabase with a 45-second timeout
      final result = await ReportService()
          .submitReport(
            title: report.title,
            description: report.description,
            isAnonymous: report.isAnonymous,
            images: imageFiles,
            category: report.category,
            location: report.location,
            latitude: report.latitude,
            longitude: report.longitude,
          )
          .timeout(const Duration(seconds: 45));

      success = result != null;
      if (!success) {
        errorMessage = "Failed to save report to backend";
      }
    } on TimeoutException {
      errorMessage =
          "Request timed out. Please check your internet connection.";
    } catch (e, stackTrace) {
      AppLogger.error("Report submission error", e, stackTrace);
      errorMessage = "Error: $e";
    } finally {
      // Ensure dialog is closed regardless of outcome
      if (mounted) {
        Navigator.of(context, rootNavigator: true).pop();
      }
    }

    // Show result message
    if (mounted) {
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Report submitted successfully!'),
            backgroundColor: Colors.green,
          ),
        );

        // Reset form
        _formKey.currentState?.reset();
        _titleController.clear();
        _notesController.clear();
        setState(() {
          _tag = null;
          _media.clear();
          _position = null;
          _anonymized = false;
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage ?? 'Unknown error occurred'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 4),
          ),
        );
      }
    }
  }
}
