import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

enum AccountType {
  none,
  customer,
  teacher,
}

enum Subject {
  math,
  english,
  hebrew,
  arabic,
  history,
  geography,
  physics,
  chemistry,
  biology,
  computerScience,
  other,
}

extension SubjectExtension on Subject {
  String name(BuildContext context) {
    switch (this) {
      case Subject.math:
        return AppLocalizations.of(context)!.subjectMath;
      case Subject.english:
        return AppLocalizations.of(context)!.subjectEnglish;
      case Subject.hebrew:
        return AppLocalizations.of(context)!.subjectHebrew;
      case Subject.arabic:
        return AppLocalizations.of(context)!.subjectArabic;
      case Subject.history:
        return AppLocalizations.of(context)!.subjectHistory;
      case Subject.geography:
        return AppLocalizations.of(context)!.subjectGeography;
      case Subject.physics:
        return AppLocalizations.of(context)!.subjectPhysics;
      case Subject.chemistry:
        return AppLocalizations.of(context)!.subjectChemistry;
      case Subject.biology:
        return AppLocalizations.of(context)!.subjectBiology;
      case Subject.computerScience:
        return AppLocalizations.of(context)!.subjectComputerScience;
      case Subject.other:
        return AppLocalizations.of(context)!.subjectOther;
    }
  }
}

enum Grade {
  first,
  second,
  third,
  fourth,
  fifth,
  sixth,
  seventh,
  eighth,
  ninth,
  tenth,
  eleventh,
  twelfth,
  other,
}

extension GradeExtension on Grade {
  String name(BuildContext context) {
    switch (this) {
      case Grade.first:
        return AppLocalizations.of(context)!.gradeFirst;
      case Grade.second:
        return AppLocalizations.of(context)!.gradeSecond;
      case Grade.third:
        return AppLocalizations.of(context)!.gradeThird;
      case Grade.fourth:
        return AppLocalizations.of(context)!.gradeFourth;
      case Grade.fifth:
        return AppLocalizations.of(context)!.gradeFifth;
      case Grade.sixth:
        return AppLocalizations.of(context)!.gradeSixth;
      case Grade.seventh:
        return AppLocalizations.of(context)!.gradeSeventh;
      case Grade.eighth:
        return AppLocalizations.of(context)!.gradeEighth;
      case Grade.ninth:
        return AppLocalizations.of(context)!.gradeNinth;
      case Grade.tenth:
        return AppLocalizations.of(context)!.gradeTenth;
      case Grade.eleventh:
        return AppLocalizations.of(context)!.gradeEleventh;
      case Grade.twelfth:
        return AppLocalizations.of(context)!.gradeTwelfth;
      case Grade.other:
        return AppLocalizations.of(context)!.gradeOther;
    }
  }
}

class Lesson {
  int orderID;
  int studentID;
  String studentName;
  String studentPhone;
  int teacherID;
  String teacherName;
  String teacherPhone;
  String title;
  Subject subject = Subject.other;
  Grade grade;
  int startTimestamp;
  int durationMinutes;
  bool isPending;
  String link;

  Lesson({
    required this.orderID,
    required this.studentID,
    required this.studentName,
    required this.studentPhone,
    required this.teacherID,
    required this.teacherName,
    required this.teacherPhone,
    required this.title,
    required this.subject,
    required this.grade,
    required this.startTimestamp,
    required this.durationMinutes,
    required this.isPending,
    required this.link,
  });

  static List<Lesson> fromJsonArray(dynamic jsonList) {
    var jsonAppointments = json.decode(jsonList);
    List<Lesson> lessons = [];
    for (var jsonAppointment in jsonAppointments) {
      lessons.add(Lesson(
        orderID: jsonAppointment['OrderID'] as int,
        studentID: jsonAppointment['StudentID'] as int,
        studentName: jsonAppointment['StudentName'] as String,
        studentPhone: jsonAppointment['StudentPhone'] as String,
        teacherID: jsonAppointment['TeacherID'] as int,
        teacherName: jsonAppointment['TeacherName'] as String,
        teacherPhone: jsonAppointment['TeacherPhone'] as String,
        title: jsonAppointment['Title'] as String,
        subject: Subject.values[jsonAppointment['Subject'] as int],
        grade: Grade.values[jsonAppointment['Grade'] as int],
        startTimestamp: jsonAppointment['StartTimestamp'] as int,
        durationMinutes: jsonAppointment['DurationMinutes'] as int,
        isPending: jsonAppointment['IsPending'] as bool,
        link: jsonAppointment['Link'] as String,
      ));
    }
    return lessons;
  }
}

class Order {
  int id;
  int timestamp;
  int durationMinutes;
  int status;
  String? receiptURL;

  Order({
    required this.id,
    required this.timestamp,
    required this.durationMinutes,
    required this.status,
    this.receiptURL,
  });

  static List<Order> fromJsonArray(dynamic jsonList) {
    var jsonOrders = json.decode(jsonList);
    List<Order> orders = [];
    for (var jsonOrder in jsonOrders) {
      orders.add(Order(
        id: jsonOrder['OrderID'] as int,
        timestamp: jsonOrder['OrderTimestamp'] as int,
        durationMinutes: jsonOrder['DurationMinutes'] as int,
        status: jsonOrder['Status'] as int,
        receiptURL: jsonOrder['ReceiptURL'] as String?,
      ));
    }
    return orders;
  }
}

class Customer {
  int id;
  String username;
  String phone;
  String password;
  List<Lesson> currentAppointments;
  List<Order> orders;

  Customer({
    required this.id,
    required this.username,
    required this.phone,
    required this.password,
    required this.currentAppointments,
    required this.orders,
  });
}

class Teacher {
  int id;
  String username;
  String phone;
  String password;
  List<Lesson> currentAppointments;

  Teacher({
    required this.id,
    required this.username,
    required this.phone,
    required this.password,
    required this.currentAppointments,
  });

  static Teacher empty = Teacher(
    id: 0,
    username: '',
    phone: '',
    password: '',
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

  // get the root scaffold context
  BuildContext? get rootContext => scaffoldMessengerKey.currentContext!;

  // Version for the lessons list to notify the UI when it changes
  int _lessonsVersion = 0;
  int get lessonsListVersion => _lessonsVersion;

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
            color: themeData.colorScheme.onErrorContainer,
          ),
        ),
        backgroundColor: themeData.colorScheme.errorContainer,
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
            Navigator.of(navigatorKey.currentContext!).pop();
            onSubmit(controller.text);
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
        showErrorSnackBar('${response.statusCode}: ${AppLocalizations.of(rootContext!)!.unexpectedError}');
      }
    } on http.ClientException catch (e) {
      response = http.Response(e.message, 504);
      showErrorSnackBar('${AppLocalizations.of(rootContext!)!.clientException}: ${e.message}');
    } catch (e) {
      response = http.Response(e.toString(), 400);
      showErrorSnackBar('${AppLocalizations.of(rootContext!)!.unexpectedException}: ${e.toString()}');
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
      currentCustomer!.currentAppointments.add(lesson);
    } else {
      currentTeacher!.currentAppointments.add(lesson);
    }
    _lessonsVersion++;
    notifyListeners();
  }

  void updateLessonLink(int startTimestamp, String newLink) {
    if (accountType == AccountType.customer) {
      for (var lesson in currentCustomer!.currentAppointments) {
        if (lesson.startTimestamp == startTimestamp) {
          lesson.link = newLink;
          break;
        }
      }
    } else {
      for (var lesson in currentTeacher!.currentAppointments) {
        if (lesson.startTimestamp == startTimestamp) {
          lesson.link = newLink;
          break;
        }
      }
    }
    _lessonsVersion++;
    notifyListeners();
  }

  void removeLesson(int startTimestamp, {int studentID = 0}) {
    if (accountType == AccountType.customer) {
      currentCustomer!.currentAppointments.removeWhere((lesson) => lesson.startTimestamp == startTimestamp);
    } else {
      currentTeacher!.currentAppointments.removeWhere((lesson) => lesson.startTimestamp == startTimestamp && lesson.studentID == studentID);
    }
    _lessonsVersion++;
    notifyListeners();
  }

  void updateProfile(String newUsername) {
    if (accountType == AccountType.customer) {
      currentCustomer!.username = newUsername;
    } else {
      currentTeacher!.username = newUsername;
    }
    notifyListeners();
  }
}
