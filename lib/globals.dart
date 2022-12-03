import 'dart:async';
import 'dart:core';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_iconpicker/flutter_iconpicker.dart';
import 'package:intl/intl.dart';
import 'package:leggo/model/place.dart';

import 'package:url_launcher/url_launcher.dart';

class Globals {
  static int currentIndex = 1;

  //int get currentIndex => currentIndex;
  set setCurrentIndex(int index) => currentIndex = index;
  Globals._internal();
  static final Globals _globals = Globals._internal();
  factory Globals() {
    return _globals;
  }
}

// extension StringExtension on String {
//   String capitalize() {
//     return "${this[0].toUpperCase()}${substring(1).toLowerCase()}";
//   }
// }

String getTodaysDay() {
  DateTime date = DateTime.now();
  String dayOfTheWeek = DateFormat('EEEE').format(date);
  return dayOfTheWeek;
}

String? getTodaysHours(Place place) {
  if (place.hours == null) {
    return null;
  } else {
    String todaysDay = getTodaysDay();
    String todaysHours = place.hours!
        .firstWhere((element) => element.toString().contains(todaysDay));
    if (todaysHours.contains('Closed')) {
      return 'Closed';
    }
    String hoursIsolated = todaysHours.replaceFirst(RegExp('$todaysDay: '), '');
    return hoursIsolated;
  }
}

Future<IconData?> pickIcon(BuildContext context) async {
  IconData? icon =
      await FlutterIconPicker.showIconPicker(context, iconPackModes: [
    Platform.isIOS ? IconPack.cupertino : IconPack.material,
    IconPack.fontAwesomeIcons
  ]);

  return icon;
}

Future<void> launchWebView(Uri url) async {
  if (!await launchUrl(url)) {
    snackbarKey.currentState!.showSnackBar(const SnackBar(
      content: Text('Failed to launch WebView!'),
      backgroundColor: Colors.red,
    ));
  }
}

Future<void> launchCall(Uri phoneNumber) async {
  if (!await launchUrl(phoneNumber)) {
    snackbarKey.currentState!.showSnackBar(const SnackBar(
      content: Text('Error Starting a Call!'),
      backgroundColor: Colors.red,
    ));
  }
}

final GlobalKey<ScaffoldMessengerState> snackbarKey =
    GlobalKey<ScaffoldMessengerState>();

String titleCase(str) {
  var splitStr = str.toLowerCase().split(' ');
  for (var i = 0; i < splitStr.length; i++) {
    // You do not need to check if i is larger than splitStr length, as your for does that for you
    // Assign it back to the array
    splitStr[i] =
        splitStr[i].charAt(0).toUpperCase() + splitStr[i].substring(1);
  }
  // Directly return the joined string
  return splitStr.join(' ');
}

extension StringExtension on String {
  String capitalizeString() {
    return "${this[0].toUpperCase()}${substring(1).toLowerCase()}";
  }
}

String capitalizeAllWord(String value) {
  var result = value[0].toUpperCase();
  for (int i = 1; i < value.length; i++) {
    if (value[i - 1] == " ") {
      result = result + value[i].toUpperCase();
    } else {
      result = result + value[i];
    }
  }
  return result;
}

class LowerCaseTextFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    return TextEditingValue(
        text: newValue.text.toLowerCase(), selection: newValue.selection);
  }
}

class GoRouterRefreshStream extends ChangeNotifier {
  late final StreamSubscription<dynamic> _subscription;

  GoRouterRefreshStream(Stream<dynamic> stream) {
    notifyListeners();
    _subscription = stream.asBroadcastStream().listen(
          (dynamic _) => notifyListeners(),
        );
  }

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}
