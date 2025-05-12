import 'dart:async';
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
  any,
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
}

extension SubjectExtension on Subject {
  String name(BuildContext context) {
    switch (this) {
      case Subject.any:
        return AppLocalizations.of(context)!.subjectAny;
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
    }
  }
}

enum Grade {
  any,
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
  higherEducation,
}

extension GradeExtension on Grade {
  String name(BuildContext context) {
    switch (this) {
      case Grade.any:
        return AppLocalizations.of(context)!.gradeAny;
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
      case Grade.higherEducation:
        return AppLocalizations.of(context)!.gradeHigherEducation;
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
  Subject subject;
  Grade grade;
  bool isImmediate;
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
    required this.isImmediate,
    required this.startTimestamp,
    required this.durationMinutes,
    required this.isPending,
    required this.link,
  });

  void copyFrom(Lesson lesson) {
    orderID = lesson.orderID;
    studentID = lesson.studentID;
    studentName = lesson.studentName;
    studentPhone = lesson.studentPhone;
    teacherID = lesson.teacherID;
    teacherName = lesson.teacherName;
    teacherPhone = lesson.teacherPhone;
    title = lesson.title;
    subject = lesson.subject;
    grade = lesson.grade;
    isImmediate = lesson.isImmediate;
    startTimestamp = lesson.startTimestamp;
    durationMinutes = lesson.durationMinutes;
    isPending = lesson.isPending;
    link = lesson.link;
  }

  static Lesson fromDict(dynamic dictLesson) {
    return Lesson(
      orderID: dictLesson['OrderID'] as int,
      studentID: dictLesson['StudentID'] as int,
      studentName: dictLesson['StudentName'] as String,
      studentPhone: dictLesson['StudentPhone'] as String,
      teacherID: dictLesson['TeacherID'] as int,
      teacherName: dictLesson['TeacherName'] as String,
      teacherPhone: dictLesson['TeacherPhone'] as String,
      title: dictLesson['Title'] as String,
      subject: Subject.values[dictLesson['Subject'] as int],
      grade: Grade.values[dictLesson['Grade'] as int],
      isImmediate: dictLesson['IsImmediate'] as bool,
      startTimestamp: dictLesson['StartTimestamp'] as int,
      durationMinutes: dictLesson['DurationMinutes'] as int,
      isPending: dictLesson['IsPending'] as bool,
      link: dictLesson['Link'] as String,
    );
  }

  static Lesson fromJson(dynamic jsonLesson) {
    var dictLesson = json.decode(jsonLesson);
    return Lesson.fromDict(dictLesson);
  }

  static List<Lesson> fromJsonArray(dynamic jsonList) {
    var dictAppointments = json.decode(jsonList);
    List<Lesson> lessons = dictAppointments.map<Lesson>((dictAppointment) => Lesson.fromDict(dictAppointment)).toList();
    return lessons;
  }

  static String getDurationString(BuildContext context, int durationMinutes) {
    if (durationMinutes >= 60) {
      return AppLocalizations.of(context)!.hours((durationMinutes / 60).toStringAsFixed((durationMinutes % 60 == 0) ? 0 : 1));
    } else {
      return AppLocalizations.of(context)!.minutes(durationMinutes.toString());
    }
  }

  static String getDateTimeString(BuildContext context, int timestamp, {bool is24HourFormat = true, bool showDate = true, bool showTime = true}) {
    DateTime lessonDate = DateTime.fromMillisecondsSinceEpoch(timestamp * 1000);
    String output = '';

    if (showDate) {
      output += '${lessonDate.day}/${lessonDate.month} ';
    }

    if (showTime) {
      if (is24HourFormat) {
        output += '${lessonDate.hour.toString().padLeft(2, '0')}:${lessonDate.minute.toString().padLeft(2, '0')}';
      } else {
        output += '${lessonDate.hour % 12 == 0 ? 12 : lessonDate.hour % 12}:${lessonDate.minute.toString().padLeft(2, '0')} ${lessonDate.hour >= 12 ? 'PM' : 'AM'}';
      }
    }

    return output;
  }
}

class Order {
  int id;
  int orderTimestamp;
  int durationMinutes;
  bool isImmediate;
  int lessonTimestamp;
  int price;
  int status;
  String? receiptURL;

  Order({
    required this.id,
    required this.orderTimestamp,
    required this.durationMinutes,
    required this.isImmediate,
    required this.lessonTimestamp,
    required this.price,
    required this.status,
    this.receiptURL,
  });

  static List<Order> fromJsonArray(dynamic jsonList) {
    var jsonOrders = json.decode(jsonList);
    List<Order> orders = [];
    for (var jsonOrder in jsonOrders) {
      orders.add(Order(
        id: jsonOrder['OrderID'] as int,
        orderTimestamp: jsonOrder['OrderTimestamp'] as int,
        durationMinutes: jsonOrder['DurationMinutes'] as int,
        isImmediate: jsonOrder['IsImmediate'] as bool,
        lessonTimestamp: jsonOrder['LessonTimestamp'] as int,
        price: jsonOrder['Price'] as int,
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
  Uri uri = Uri.https('api.darrisni.com', '/prod/handler.php');
  static const int verificationCodeLength = 6;
  late GlobalKey<NavigatorState> navigatorKey;
  late GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey;
  late ThemeData themeData;
  AccountType accountType = AccountType.none;
  Customer? currentCustomer;
  Teacher? currentTeacher;
  String language = 'en';
  int loadingCount = 0; // the number of loading events that are currently active

  // get the root scaffold context
  BuildContext? get rootContext => scaffoldMessengerKey.currentContext!;

  // Version for the lessons list to notify the UI when it changes
  int _lessonsListVersion = 0;
  int get lessonsListVersion => _lessonsListVersion;
  set lessonsListVersion(int version) {
    if (_lessonsListVersion != version) {
      _lessonsListVersion = version;
      notifyListeners();
    }
  }

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
    loadingCount++;
    if (loadingCount > 1) return; // don't show loading dialog if already showing
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
    loadingCount--;
    if (loadingCount > 0) return; // don't close dialog if still loading
    if (loadingCount < 0) throw Exception('Loading count is negative!');
    navigatorKey.currentState?.pop();
  }

  Future<http.Response> dbRequest({Map<String, String>? body, bool indicateLoading = true, int timeout = 10}) async {
    if (indicateLoading) {
      startLoading();
    }
    http.Response response;

    try {
      response = await http
          .post(
            uri,
            body: body,
          )
          .timeout(Duration(seconds: timeout));
      if (response.statusCode != 200) {
        showErrorSnackBar('${response.statusCode}: ${AppLocalizations.of(rootContext!)!.unexpectedError}');
      }
    } on TimeoutException catch (e) {
      response = http.Response(e.toString(), 408);
      // showErrorSnackBar('${AppLocalizations.of(rootContext!)!.timeoutException}: ${e.message}'); // TODO: localize
      showErrorSnackBar('Request timed out. Please try again later.');
    } on http.ClientException catch (e) {
      response = http.Response(e.message, 504);
      showErrorSnackBar('${AppLocalizations.of(rootContext!)!.clientException}: ${e.message}');
    } catch (e) {
      response = http.Response(e.toString(), 400);
      showErrorSnackBar('${AppLocalizations.of(rootContext!)!.unexpectedException}: ${e.toString()}');
    }

    print('==================================');
    print('Request: $body');
    print('----------------------------------');
    print('Response: ${response.body}');
    print('==================================');

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

  double getLessonPrice(int durationMinutes) {
    return durationMinutes * 1; // rate per minute
  }

  void addLesson(Lesson lesson) {
    if (accountType == AccountType.customer) {
      currentCustomer!.currentAppointments.add(lesson);
    } else {
      currentTeacher!.currentAppointments.add(lesson);
    }
    lessonsListVersion++;
  }

  void copyLessonFrom(Lesson source) {
    if (accountType == AccountType.customer) {
      for (var i = 0; i < currentCustomer!.currentAppointments.length; i++) {
        if (currentCustomer!.currentAppointments[i].orderID == source.orderID) {
          currentCustomer!.currentAppointments[i].copyFrom(source);
          break;
        }
      }
    } else {
      for (var i = 0; i < currentTeacher!.currentAppointments.length; i++) {
        if (currentTeacher!.currentAppointments[i].orderID == source.orderID) {
          currentTeacher!.currentAppointments[i].copyFrom(source);
          break;
        }
      }
    }
    lessonsListVersion++;
  }

  void removeLesson(int startTimestamp, {int studentID = 0}) {
    if (accountType == AccountType.customer) {
      currentCustomer!.currentAppointments.removeWhere((lesson) => lesson.startTimestamp == startTimestamp);
    } else {
      currentTeacher!.currentAppointments.removeWhere((lesson) => lesson.startTimestamp == startTimestamp && lesson.studentID == studentID);
    }
    lessonsListVersion++;
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
