import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

enum AccountType {
  none,
  customer,
  teacher,
}

class Lesson {
  int studentID;
  String studentName;
  String studentPhone;
  int teacherID;
  String teacherName;
  String teacherPhone;
  String title;
  int startTimestamp;
  int durationMinutes;
  bool isPending;
  String link;

  Lesson({
    required this.studentID,
    required this.studentName,
    required this.studentPhone,
    required this.teacherID,
    required this.teacherName,
    required this.teacherPhone,
    required this.title,
    required this.startTimestamp,
    required this.durationMinutes,
    required this.isPending,
    required this.link,
  });
}

class Customer {
  int id;
  String username;
  String phone;
  String password;
  String oneSignalID;
  bool isVerified;
  List<Lesson> currentAppointments;

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
  String phone;
  String password;
  String oneSignalID;
  List<Lesson> currentAppointments;

  Teacher({
    required this.id,
    required this.username,
    required this.phone,
    required this.password,
    required this.oneSignalID,
    required this.currentAppointments,
  });

  static Teacher empty = Teacher(
    id: 0,
    username: '',
    phone: '',
    password: '',
    oneSignalID: '',
    currentAppointments: [],
  );
}

class AppState extends ChangeNotifier {
  Uri uri = Uri.http('5.29.135.161:8000', '/supreme-octo-eureka-backend/handler.php');
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

  void showAlertDialog({
    required Widget content,
    bool barrierDismissible = true,
    List<Widget>? actions,
  }) {
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

  void showInputDialog({
    required String message,
    required Function(String) onSubmit,
    bool barrierDismissible = true,
  }) {
    TextEditingController controller = TextEditingController();

    showAlertDialog(
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(message),
          TextField(
            controller: controller,
          ),
        ],
      ),
      barrierDismissible: barrierDismissible,
      actions: [
        TextButton(
          onPressed: () {
            onSubmit(controller.text);
            Navigator.of(navigatorKey.currentContext!).pop();
          },
          child: const Icon(Icons.send),
        ),
      ],
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

  void addLesson(Lesson lesson) {
    if (accountType == AccountType.customer) {
      currentCustomer!.currentAppointments = List.from(currentCustomer!.currentAppointments)..add(lesson);
    } else {
      currentTeacher!.currentAppointments = List.from(currentTeacher!.currentAppointments)..add(lesson);
    }
    notifyListeners();
  }

  void removeLesson(int startTimestamp, {int studentID = 0}) {
    if (accountType == AccountType.customer) {
      currentCustomer!.currentAppointments = currentCustomer!.currentAppointments.where((lesson) => lesson.startTimestamp != startTimestamp).toList();
    } else {
      currentTeacher!.currentAppointments = currentTeacher!.currentAppointments.where((lesson) => lesson.startTimestamp != startTimestamp || lesson.studentID != studentID).toList();
    }
    notifyListeners();
  }
}
