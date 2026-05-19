// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// StackedBottomsheetGenerator
// **************************************************************************

import 'package:stacked_services/stacked_services.dart';

import 'app.locator.dart';
import '../ui/bottom_sheets/cms_inspection_line_editor/cms_inspection_line_editor_sheet.dart';
import '../ui/bottom_sheets/gate_access_pre_booking/gate_access_pre_booking_sheet.dart';
import '../ui/bottom_sheets/gate_access_visitor/gate_access_visitor_sheet.dart';
import '../ui/bottom_sheets/manual_entry_selection/manual_entry_selection_sheet.dart';
import '../ui/bottom_sheets/notice/notice_sheet.dart';

enum BottomSheetType {
  notice,
  gateAccessVisitor,
  gateAccessPreBooking,
  manualEntrySelection,
  cmsInspectionLineEditor,
}

void setupBottomSheetUi() {
  final bottomsheetService = locator<BottomSheetService>();

  final Map<BottomSheetType, SheetBuilder> builders = {
    BottomSheetType.notice: (context, request, completer) =>
        NoticeSheet(request: request, completer: completer),
    BottomSheetType.gateAccessVisitor: (context, request, completer) =>
        GateAccessVisitorSheet(request: request, completer: completer),
    BottomSheetType.gateAccessPreBooking: (context, request, completer) =>
        GateAccessPreBookingSheet(request: request, completer: completer),
    BottomSheetType.manualEntrySelection: (context, request, completer) =>
        ManualEntrySelectionSheet(request: request, completer: completer),
    BottomSheetType.cmsInspectionLineEditor: (context, request, completer) =>
        CmsInspectionLineEditorSheet(request: request, completer: completer),
  };

  bottomsheetService.setCustomSheetBuilders(builders);
}
