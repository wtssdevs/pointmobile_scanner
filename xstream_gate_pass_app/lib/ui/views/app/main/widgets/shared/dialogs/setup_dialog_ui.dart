import 'package:flutter/widgets.dart';

import 'package:stacked_services/stacked_services.dart';
import 'package:xstream_gate_pass_app/app_config/app.locator.dart';
import 'package:xstream_gate_pass_app/core/enums/dialog_type.dart';
import 'package:xstream_gate_pass_app/ui/views/app/main/widgets/shared/dialogs/types/basic_dialog.dart';


void setupDialogUi() {
  final dialogService = locator<DialogService>();

  final builders = {
    DialogType.basic: (BuildContext context, DialogRequest request, Function(DialogResponse) completer) => BasicDialog(request: request, completer: completer),
    
  };

  dialogService.registerCustomDialogBuilders(builders);
}
