import 'package:path_provider/path_provider.dart';
import 'package:sembast/sembast_io.dart';
import 'package:stacked/stacked_annotations.dart';
import 'dart:async';
import 'package:sembast/sembast.dart';
import 'package:path/path.dart';
import 'package:xstream_gate_pass_app/app/app.locator.dart';
import 'package:xstream_gate_pass_app/app/app.logger.dart';
import 'package:xstream_gate_pass_app/core/app_const.dart';

@InitializableSingleton()
class AppDatabase {
  final log = getLogger('AppDatabase');
  static AppDatabase? _instance;
  static Database? _db;
  Database? get db => _db;

  Future init() async {
    log.i('Load AppDatabase');
    await initSembast();
    log.v('AppDatabase loaded');
  }

  static Future<Database?> initSembast() async {
    final appDir = await getApplicationDocumentsDirectory();
    await appDir.create(recursive: true);
    final databasePath = join(appDir.path, AppConst.internalDatabaseName);
    _db = await databaseFactoryIo.openDatabase(databasePath);
    return _db;
  }

  static Future<AppDatabase> getInstance() async {
    if (_instance == null) {
      _instance = AppDatabase();
    }

    if (_db == null) {
      _db = await initSembast();
    }

    return _instance!;
  }
}
