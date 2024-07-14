import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

enum AccountType {
  none,
  customer,
  teacher,
}

class Customer {
  int id;
  String username;
  String phone;
  String password;
  String oneSignalID;
  bool isVerified;
  List<String> currentAppointments;

  Customer({
    required this.id,
    required this.username,
    required this.phone,
    required this.password,
    required this.oneSignalID,
    required this.isVerified,
    required this.currentAppointments,
  });
}

class Teacher {
  int id;
  String username;
  String profileImage;
  String phone;
  String password;
  String oneSignalID;
  List<String> currentAppointments;

  Teacher({
    required this.id,
    required this.username,
    required this.profileImage,
    required this.phone,
    required this.password,
    required this.oneSignalID,
    required this.currentAppointments,
  });

  static Teacher empty = Teacher(
    id: 0,
    username: '',
    profileImage: '',
    phone: '',
    password: '',
    oneSignalID: '',
    currentAppointments: [],
  );
}

class AppState extends ChangeNotifier {
  Uri uri = Uri.http('5.29.135.161:8000', '/handler.php');
  static const int verificationCodeLength = 6;
  late GlobalKey<NavigatorState> navigatorKey;
  late GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey;
  late ThemeData themeData;
  AccountType accountType = AccountType.none;
  Customer? currentCustomer;
  Teacher? currentTeacher;
  String language = 'en';
  bool isLoading = false;

  void showSnackBar(SnackBar snackBar) {
    scaffoldMessengerKey.currentState?.showSnackBar(snackBar);
  }

  void showMsgSnackBar(String msg) {
    showSnackBar(
      SnackBar(
        content: Text(msg),
      ),
    );
  }

  void showErrorSnackBar(String errorMsg) {
    showSnackBar(
      SnackBar(
        content: Text(
          errorMsg,
          style: TextStyle(
            color: themeData.colorScheme.onError,
          ),
        ),
        backgroundColor: themeData.colorScheme.error,
      ),
    );
  }

  void showAlertDialog({required Widget content, bool barrierDismissible = true, List<Widget>? actions}) {
    showDialog<void>(
      context: navigatorKey.currentContext!,
      barrierDismissible: barrierDismissible,
      builder: (BuildContext context) {
        return AlertDialog(
          content: content,
          actions: actions,
        );
      },
    );
  }

  void startLoading() {
    if (isLoading) return;
    isLoading = true;
    showDialog<void>(
      context: navigatorKey.currentContext!,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return const SimpleDialog(
          elevation: 0.0,
          backgroundColor: Colors.transparent,
          children: <Widget>[
            Center(
              child: CircularProgressIndicator(),
            )
          ],
        );
      },
    );
  }

  void stopLoading() {
    if (!isLoading) return;
    isLoading = false;
    navigatorKey.currentState?.pop();
  }

  Future<http.Response> dbRequest({Map<String, String>? body, bool indicateLoading = true}) async {
    if (indicateLoading) {
      startLoading();
    }
    http.Response response;

    try {
      response = await http.post(
        uri,
        body: body,
      );
      if (response.statusCode != 200) {
        showErrorSnackBar('${response.statusCode}: Unexpected Error');
      }
    } on http.ClientException catch (e) {
      response = http.Response(e.message, 504);
      showErrorSnackBar('http.ClientException: ${e.message}');
    } catch (e) {
      response = http.Response(e.toString(), 400);
      showErrorSnackBar('dbRequestUnexpectedException: ${e.toString()}');
    }

    if (indicateLoading) {
      stopLoading();
    }
    return response;
  }

  String getPhoneLocalFormat() {
    String phone = accountType == AccountType.customer ? currentCustomer!.phone : currentTeacher!.phone;
    return phone.length == 10 ? phone : '0${phone.substring(3)}';
  }

  String getPhoneInternationalFormat() {
    String phone = accountType == AccountType.customer ? currentCustomer!.phone : currentTeacher!.phone;
    return phone.length == 10 ? '972${phone.substring(1)}' : phone;
  }

  String getPassword() {
    return accountType == AccountType.customer ? currentCustomer!.password : currentTeacher!.password;
  }
}
