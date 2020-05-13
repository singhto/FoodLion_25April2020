import 'package:fluttertoast/fluttertoast.dart';

Future<void> normalToast(String message) async {
  Fluttertoast.showToast(
    msg: message,
    toastLength: Toast.LENGTH_SHORT,
  );
}
