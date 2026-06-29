import 'dart:io';

import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:xstream_gate_pass_app/core/enums/cms_survey_type.dart';
import 'package:xstream_gate_pass_app/core/models/cms/media/cms_media_upload_item.dart';
import 'package:xstream_gate_pass_app/ui/shared/style/app_colors.dart';
import 'package:xstream_gate_pass_app/ui/views/cms/surveys/detail/cms_survey_detail_viewmodel.dart';

class CmsSurveyDetailView extends StatelessWidget {
  const CmsSurveyDetailView({
    super.key,
    required this.surveyId,
    required this.surveyType,
  });

  final int surveyId;
  final CmsSurveyType surveyType;

  Future<void> _openLocalPath(CmsSurveyDetailViewModel model, String filePath) async {
    try {
      final opened = await launchUrl(
        Uri.file(filePath),
        mode: LaunchMode.externalApplication,
      );
      if (!opened) {
        model.setInlineMessage('The downloaded file is ready, but Windows did not open it automatically.');
      }
    } catch (_) {
      model.setInlineMessage('The downloaded file is ready, but it could not be opened automatically.');
    }
  }

  Future<void> _downloadReport(CmsSurveyDetailViewModel model) async {
    final filePath = await model.downloadReport();
    if (filePath != null && filePath.trim().isNotEmpty) {
      await _openLocalPath(model, filePath);
    }
  }

  Future<void> _openAttachment(CmsSurveyDetailViewModel model, CmsMediaUploadItem item) async {
    final filePath = await model.downloadAttachment(item);
    if (filePath != null && filePath.trim().isNotEmpty) {
      await _openLocalPath(model, filePath);
    }
  }

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<CmsSurveyDetailViewModel>.reactive(
      viewModelBuilder: () => CmsSurveyDetailViewModel(),
      onViewModelReady: (model) => model.runStartupLogic(
        surveyId: surveyId,
        surveyType: surveyType,
      ),
      builder: (context, model, child) => PopScope(
        canPop: false,
        onPopInvoked: (didPop) {
          if (!didPop) {
            model.goBack();
          }
        },
        child: Scaffold(
          appBar: AppBar(
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_rounded),
              onPressed: model.goBack,
            ),
            title: Text(model.title),
            actions: [
              IconButton(
                tooltip: 'Download report',
                onPressed: model.canDownloadReport && !model.isBusy ? () => _downloadReport(model) : null,
                icon: const Icon(Icons.download_outlined),
              ),
              TextButton.icon(
                onPressed: model.isBusy ? null : model.save,
                icon: const Icon(Icons.save_outlined),
                label: const Text('Save'),
              ),
            ],
          ),
          bottomNavigationBar: SafeArea(
            minimum: const EdgeInsets.fromLTRB(16, 8, 16, 16),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: model.canSendEmail && !model.isBusy ? model.sendEmail : null,
                    icon: const Icon(Icons.email_outlined),
                    label: const Text('Send email'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: FilledButton.icon(
                    style: FilledButton.styleFrom(backgroundColor: kcPrimaryColor),
                    onPressed: model.isBusy ? null : model.save,
                    icon: model.isBusy
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.check_rounded),
                    label: const Text('Save survey'),
                  ),
                ),
              ],
            ),
          ),
          body: model.isBusy && model.survey == null
              ? const Center(child: CircularProgressIndicator())
              : ListView(
                  keyboardDismissBehavior:
                      ScrollViewKeyboardDismissBehavior.onDrag,
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 120),
                  children: [
                    _HeaderCard(model: model),
                    if (model.inlineMessage != null) ...[
                      const SizedBox(height: 12),
                      _InlineMessage(
                        icon: Icons.info_outline,
                        message: model.inlineMessage!,
                        backgroundColor: Colors.blueGrey.withOpacity(0.08),
                        foregroundColor: Colors.blueGrey[800]!,
                        onClose: model.clearMessage,
                      ),
                    ],
                    if (model.loadError != null) ...[
                      const SizedBox(height: 12),
                      _InlineMessage(
                        icon: Icons.sync_problem_outlined,
                        message: model.loadError!,
                        backgroundColor: Colors.red.withOpacity(0.08),
                        foregroundColor: Colors.red[800]!,
                      ),
                    ],
                    const SizedBox(height: 16),
                    _SectionCard(
                      title: 'Details',
                      icon: Icons.edit_note_rounded,
                      children: [
                        TextField(
                          controller: model.conductedByController,
                          decoration: const InputDecoration(
                            labelText: 'Conducted by',
                            border: OutlineInputBorder(),
                          ),
                        ),
                        const SizedBox(height: 12),
                        TextField(
                          controller: model.nameController,
                          decoration: const InputDecoration(
                            labelText: 'Name / title',
                            border: OutlineInputBorder(),
                          ),
                        ),
                        const SizedBox(height: 12),
                        TextField(
                          controller: model.containerNoController,
                          enabled: model.surveyType == CmsSurveyType.gatePass,
                          decoration: InputDecoration(
                            labelText: 'Container number',
                            helperText: model.surveyType == CmsSurveyType.gatePass
                                ? 'Used to resolve gate pass container links.'
                                : 'Container surveys use the selected container context.',
                            border: const OutlineInputBorder(),
                          ),
                        ),
                        const SizedBox(height: 12),
                        TextField(
                          controller: model.descriptionController,
                          minLines: 6,
                          maxLines: 10,
                          decoration: const InputDecoration(
                            labelText: 'Survey details',
                            alignLabelWithHint: true,
                            border: OutlineInputBorder(),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    _SectionCard(
                      title: 'Attachments',
                      icon: Icons.attach_file_rounded,
                      children: [
                        _AttachmentStatusPanel(model: model),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton.icon(
                                onPressed: model.canDownloadReport && !model.isBusy ? () => _downloadReport(model) : null,
                                icon: const Icon(Icons.picture_as_pdf_outlined),
                                label: const Text('Download report'),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: FilledButton.icon(
                                onPressed: model.canAttachDocuments && !model.isDocumentBusy ? model.pickDocument : null,
                                icon: model.isDocumentBusy
                                    ? const SizedBox(
                                        width: 18,
                                        height: 18,
                                        child: CircularProgressIndicator(strokeWidth: 2),
                                      )
                                    : const Icon(Icons.upload_file_outlined),
                                label: const Text('Add document'),
                              ),
                            ),
                          ],
                        ),
                        if (model.attachments.isNotEmpty) ...[
                          const SizedBox(height: 12),
                          ...model.attachments.map(
                            (attachment) => _SurveyAttachmentTile(
                              attachment: attachment,
                              onOpen: attachment.state == CmsMediaUploadState.awaitingSave ? null : () => _openAttachment(model, attachment),
                              onRetry: attachment.state == CmsMediaUploadState.failed ? () => model.retryItem(attachment) : null,
                              onDelete: () => model.deleteAttachment(attachment),
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 16),
                    _SectionCard(
                      title: 'Photos',
                      icon: Icons.photo_camera_outlined,
                      children: [
                        _PhotoStatusPanel(model: model),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: FilledButton.icon(
                                onPressed: model.canAttachPhotos && !model.isPhotoBusy ? model.capturePhoto : null,
                                icon: model.isPhotoBusy
                                    ? const SizedBox(
                                        width: 18,
                                        height: 18,
                                        child: CircularProgressIndicator(strokeWidth: 2),
                                      )
                                    : const Icon(Icons.camera_alt_outlined),
                                label: const Text('Take photo'),
                              ),
                            ),
                            const SizedBox(width: 10),
                            IconButton.outlined(
                              tooltip: 'Pick from gallery',
                              onPressed: model.canAttachPhotos && !model.isPhotoBusy ? model.addPhotoFromGallery : null,
                              icon: const Icon(Icons.photo_library_outlined),
                            ),
                            const SizedBox(width: 6),
                            IconButton.outlined(
                              tooltip: 'Retry uploads',
                              onPressed: model.photos.isNotEmpty && !model.isPhotoBusy ? model.retryPhotoUploads : null,
                              icon: const Icon(Icons.sync_outlined),
                            ),
                          ],
                        ),
                        if (model.photos.isNotEmpty) ...[
                          const SizedBox(height: 12),
                          ...model.photos.map(
                            (photo) => _SurveyPhotoTile(
                              photo: photo,
                              onRetry: photo.state == CmsMediaUploadState.failed ? () => model.retryItem(photo) : null,
                              onDelete: () => model.deletePhoto(photo),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}

class _PhotoStatusPanel extends StatelessWidget {
  const _PhotoStatusPanel({required this.model});

  final CmsSurveyDetailViewModel model;

  @override
  Widget build(BuildContext context) {
    final enabled = model.canAttachPhotos;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: enabled ? Colors.green.withOpacity(0.08) : Colors.amber.withOpacity(0.12),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: enabled ? Colors.green.shade200 : Colors.amber.shade300),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            enabled ? Icons.cloud_upload_outlined : Icons.lock_outline_rounded,
            color: enabled ? Colors.green[700] : Colors.amber[900],
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  enabled ? 'Background upload ready' : 'Save required first',
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 4),
                Text(
                  enabled ? model.photoStatusSummary : 'Photos need a saved survey plus a container/gate pass reference before they can be queued.',
                  style: TextStyle(color: Colors.grey[700], fontSize: 13),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _AttachmentStatusPanel extends StatelessWidget {
  const _AttachmentStatusPanel({required this.model});

  final CmsSurveyDetailViewModel model;

  @override
  Widget build(BuildContext context) {
    final enabled = model.canAttachDocuments;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: enabled ? Colors.teal.withOpacity(0.08) : Colors.amber.withOpacity(0.12),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: enabled ? Colors.teal.shade200 : Colors.amber.shade300),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            enabled ? Icons.upload_file_outlined : Icons.lock_outline_rounded,
            color: enabled ? Colors.teal[700] : Colors.amber[900],
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  enabled ? 'Documents and reports ready' : 'Save required first',
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 4),
                Text(
                  enabled
                      ? model.attachmentStatusSummary
                      : 'Documents need a saved survey plus a container/gate pass reference before they can be queued.',
                  style: TextStyle(color: Colors.grey[700], fontSize: 13),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SurveyPhotoTile extends StatelessWidget {
  const _SurveyPhotoTile({
    required this.photo,
    this.onRetry,
    required this.onDelete,
  });

  final CmsMediaUploadItem photo;
  final VoidCallback? onRetry;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final localPath = photo.localPath;
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: localPath != null && File(localPath).existsSync()
                ? Image.file(
                    File(localPath),
                    width: 58,
                    height: 58,
                    fit: BoxFit.cover,
                  )
                : Container(
                    width: 58,
                    height: 58,
                    color: Colors.grey[200],
                    child: const Icon(Icons.image_outlined),
                  ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  photo.documentFileName ?? photo.name ?? 'Survey photo',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 6),
                _PhotoStateChip(state: photo.state),
                if ((photo.errorMessage ?? '').isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    photo.errorMessage!,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(color: Colors.red[700], fontSize: 12),
                  ),
                ],
              ],
            ),
          ),
          if (onRetry != null)
            IconButton(
              tooltip: 'Retry photo upload',
              onPressed: onRetry,
              icon: const Icon(Icons.sync_outlined),
            ),
          IconButton(
            tooltip: 'Remove photo',
            onPressed: onDelete,
            icon: const Icon(Icons.delete_outline_rounded),
          ),
        ],
      ),
    );
  }
}

class _SurveyAttachmentTile extends StatelessWidget {
  const _SurveyAttachmentTile({
    required this.attachment,
    this.onOpen,
    this.onRetry,
    required this.onDelete,
  });

  final CmsMediaUploadItem attachment;
  final VoidCallback? onOpen;
  final VoidCallback? onRetry;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(_attachmentIcon(attachment), color: Colors.grey[800]),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  attachment.documentFileName ?? attachment.name ?? 'Survey document',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
                if ((attachment.documentFileType ?? '').isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    attachment.documentFileType!,
                    style: TextStyle(color: Colors.grey[700], fontSize: 12),
                  ),
                ],
                const SizedBox(height: 6),
                _PhotoStateChip(state: attachment.state),
                if ((attachment.errorMessage ?? '').isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    attachment.errorMessage!,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(color: Colors.red[700], fontSize: 12),
                  ),
                ],
              ],
            ),
          ),
          if (onOpen != null)
            IconButton(
              tooltip: 'Open document',
              onPressed: onOpen,
              icon: const Icon(Icons.open_in_new_rounded),
            ),
          if (onRetry != null)
            IconButton(
              tooltip: 'Retry document upload',
              onPressed: onRetry,
              icon: const Icon(Icons.sync_outlined),
            ),
          IconButton(
            tooltip: 'Remove document',
            onPressed: onDelete,
            icon: const Icon(Icons.delete_outline_rounded),
          ),
        ],
      ),
    );
  }

  static IconData _attachmentIcon(CmsMediaUploadItem item) {
    final lower = (item.documentFileName ?? item.name ?? '').toLowerCase();
    if (lower.endsWith('.pdf')) {
      return Icons.picture_as_pdf_outlined;
    }
    if (lower.endsWith('.doc') || lower.endsWith('.docx')) {
      return Icons.description_outlined;
    }
    if (lower.endsWith('.xls') || lower.endsWith('.xlsx')) {
      return Icons.table_chart_outlined;
    }
    if (item.isImage) {
      return Icons.image_outlined;
    }
    return Icons.insert_drive_file_outlined;
  }
}

class _PhotoStateChip extends StatelessWidget {
  const _PhotoStateChip({required this.state});

  final CmsMediaUploadState state;

  @override
  Widget build(BuildContext context) {
    final color = switch (state) {
      CmsMediaUploadState.uploaded => Colors.green,
      CmsMediaUploadState.failed => Colors.red,
      CmsMediaUploadState.uploading => Colors.blue,
      CmsMediaUploadState.queued => Colors.orange,
      CmsMediaUploadState.awaitingSave => Colors.amber,
      CmsMediaUploadState.local => Colors.blueGrey,
    };

    final label = switch (state) {
      CmsMediaUploadState.awaitingSave => 'Waiting for save',
      CmsMediaUploadState.local => 'Local',
      CmsMediaUploadState.queued => 'Queued',
      CmsMediaUploadState.uploading => 'Uploading',
      CmsMediaUploadState.uploaded => 'Uploaded',
      CmsMediaUploadState.failed => 'Retry needed',
    };

    return Chip(
      label: Text(label),
      visualDensity: VisualDensity.compact,
      backgroundColor: color.withOpacity(0.12),
      labelStyle: TextStyle(color: color.shade800, fontSize: 12),
      side: BorderSide(color: color.withOpacity(0.28)),
    );
  }
}

class _HeaderCard extends StatelessWidget {
  const _HeaderCard({required this.model});

  final CmsSurveyDetailViewModel model;

  @override
  Widget build(BuildContext context) {
    final color = model.surveyType == CmsSurveyType.gatePass ? Colors.deepOrange : kcPrimaryColor;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.22)),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: color.withOpacity(0.14),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(
              model.surveyType == CmsSurveyType.gatePass ? Icons.local_shipping_outlined : Icons.inventory_2_outlined,
              color: color,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  model.surveyType.displayName,
                  style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 4),
                Text(
                  model.isNew ? 'Online save required in this phase.' : 'Saved survey #${model.survey?.id}.',
                  style: TextStyle(color: Colors.grey[700], fontSize: 13),
                ),
              ],
            ),
          ),
          if (model.isDirty)
            const Chip(
              label: Text('Unsaved'),
              visualDensity: VisualDensity.compact,
            ),
        ],
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({
    required this.title,
    required this.icon,
    required this.children,
  });

  final String title;
  final IconData icon;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(color: Colors.grey.shade300),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: kcPrimaryColor),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                ),
              ],
            ),
            const SizedBox(height: 14),
            ...children,
          ],
        ),
      ),
    );
  }
}

class _InlineMessage extends StatelessWidget {
  const _InlineMessage({
    required this.icon,
    required this.message,
    required this.backgroundColor,
    required this.foregroundColor,
    this.onClose,
  });

  final IconData icon;
  final String message;
  final Color backgroundColor;
  final Color foregroundColor;
  final VoidCallback? onClose;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Icon(icon, color: foregroundColor, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              message,
              style: TextStyle(color: foregroundColor, fontSize: 13),
            ),
          ),
          if (onClose != null)
            IconButton(
              visualDensity: VisualDensity.compact,
              icon: Icon(Icons.close_rounded, color: foregroundColor),
              onPressed: onClose,
            ),
        ],
      ),
    );
  }
}
