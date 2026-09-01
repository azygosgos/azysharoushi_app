import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_ce_flutter/hive_ce_flutter.dart';

import 'app.dart';
import 'constants/hive_boxes.dart';
import 'services/data_loader_service.dart';

Future<void> main() async {
  // Flutterのウィジェットツリーより前に非同期処理をするために必要なおまじない。
  WidgetsFlutterBinding.ensureInitialized();

  // ローカル保存(Hive)の初期化。Web版ではブラウザのIndexedDBが使われる。
  await Hive.initFlutter();
  for (final boxName in HiveBoxes.all) {
    await Hive.openBox(boxName);
  }

  // assets/data/*.json の教材データを、必要であればHiveへ読み込む。
  await DataLoaderService().loadIfNeeded();

  runApp(const ProviderScope(child: SharoushiApp()));
}
