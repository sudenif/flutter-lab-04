import 'dart:ui';

import 'package:flutter/material.dart';

import 'app/lab_stage.dart';
import 'app/router/router.dart';
import 'di/di.dart';
import 'recipe_app.dart';

Future<void> bootstrap(LabStage stage) async {
  WidgetsFlutterBinding.ensureInitialized();
  await setupLocator();
  FlutterError.onError = (details) {
    FlutterError.presentError(details);
    talker.handle(details.exception, details.stack);
  };
  PlatformDispatcher.instance.onError = (error, stack) {
    talker.handle(error, stack);
    return true;
  };
  runApp(RecipeApp(router: createRouter(stage)));
}
