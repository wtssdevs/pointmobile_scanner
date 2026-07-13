import 'package:stacked/stacked_annotations.dart';
import 'package:stacked_services/stacked_services.dart';

final customLocator = StackedLocator.instance;

void setupExtraLocator() {
  customLocator.registerLazySingleton(() => SnackbarService());
}
