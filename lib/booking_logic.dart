import 'dart:convert';
import 'package:supreme_octo_eureka/app_state.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:supreme_octo_eureka/authentication/auth_logic.dart';

Future<double> testCoupon(
  String couponCode,
  double totalPrice,
  AppState appState,
) async {
  var response = await appState.dbRequest(
    body: {
      'Action': 'TestCoupon',
      'AccountType': 'Customer',
      'Phone': appState.currentCustomer!.phone,
      'CouponCode': couponCode,
      'TotalPrice': totalPrice.toString(),
    },
  );

  if (response.statusCode == 200) {
    try {
      var jsonResponse = json.decode(response.body);
      if (jsonResponse['Result'] == 'SUCCESS') {
        return double.parse(jsonResponse['NewPrice'].toString());
      } else if (jsonResponse['Result'] == 'PHONE_DOESNT_EXIST') {
        logout(appState);
        return -1;
      } else if (jsonResponse['Result'] == 'INVALID_COUPON_CODE') {
        appState.showErrorSnackBar(AppLocalizations.of(appState.rootContext!)!.invalidCouponCode);
        return -1;
      }
      throw jsonResponse['Result'];
    } on FormatException {
      appState.showErrorSnackBar(AppLocalizations.of(appState.rootContext!)!.jsonFormatError);
      return -1;
    } catch (e) {
      appState.showErrorSnackBar(e.toString());
      return -1;
    }
  } else {
    appState.showErrorSnackBar('${response.statusCode}: ${AppLocalizations.of(appState.rootContext!)!.unexpectedError}');
  }
  return -1;
}

Future<String?> createOrderRequest(
  Lesson lesson,
  String couponCode,
  AppState appState,
) async {
  var response = await appState.dbRequest(
    body: {
      'Action': 'CreateOrderRequest',
      'AccountType': 'Customer',
      'Phone': appState.currentCustomer!.phone,
      'Password': appState.currentCustomer!.password,
      'Title': lesson.title,
      'Subject': lesson.subject.index.toString(),
      'Grade': lesson.grade.index.toString(),
      'IsImmediate': lesson.isImmediate.toString(),
      'StartTimestamp': lesson.startTimestamp.toString(),
      'DurationMinutes': lesson.durationMinutes.toString(),
      'CouponCode': couponCode,
    },
  );

  if (response.statusCode == 200) {
    try {
      var jsonResponse = json.decode(response.body);
      if (jsonResponse['Result'] == 'SUCCESS') {
        lesson.orderID = jsonResponse['OrderID'] as int;
        return jsonResponse['PaymentLink'];
      } else if (jsonResponse['Result'] == 'OVERLAPPING_LESSON') {
        appState.showErrorSnackBar(AppLocalizations.of(appState.rootContext!)!.overlappingLessons);
        return null;
      } else if (jsonResponse['Result'] == 'PHONE_DOESNT_EXIST' || jsonResponse['Result'] == 'WRONG_PASSWORD') {
        logout(appState);
        return null;
      }
      throw jsonResponse['Result'];
    } on FormatException {
      appState.showErrorSnackBar(AppLocalizations.of(appState.rootContext!)!.jsonFormatError);
      return null;
    } catch (e) {
      appState.showErrorSnackBar(e.toString());
      return null;
    }
  } else {
    appState.showErrorSnackBar('${response.statusCode}: ${AppLocalizations.of(appState.rootContext!)!.unexpectedError}');
  }

  return null;
}

// TODO: convert to GetLessonDetails
Future<bool> confirmOrder(
  Lesson lesson,
  AppState appState,
) async {
  var response = await appState.dbRequest(
    body: {
      'Action': 'ConfirmOrder',
      'AccountType': 'Customer',
      'Phone': appState.currentCustomer!.phone,
      'Password': appState.currentCustomer!.password,
      'OrderID': lesson.orderID.toString(),
    },
  );

  if (response.statusCode == 200) {
    try {
      var jsonResponse = json.decode(response.body);
      if (jsonResponse['Result'] == 'SUCCESS') {
        appState.addLesson(lesson);
        appState.showMsgSnackBar(AppLocalizations.of(appState.rootContext!)!.lessonBooked);
        return true;
      } else if (jsonResponse['Result'] == 'PHONE_DOESNT_EXIST' || jsonResponse['Result'] == 'WRONG_PASSWORD') {
        logout(appState);
        return false;
      }
      throw jsonResponse['Result'];
    } on FormatException {
      appState.showErrorSnackBar(AppLocalizations.of(appState.rootContext!)!.jsonFormatError);
      return false;
    } catch (e) {
      appState.showErrorSnackBar(e.toString());
      return false;
    }
  } else {
    appState.showErrorSnackBar('${response.statusCode}: ${AppLocalizations.of(appState.rootContext!)!.unexpectedError}');
  }

  return false;
}

Future<bool> cancelLesson(
  Lesson lesson,
  AppState appState,
) async {
  var response = await appState.dbRequest(
    body: {
      'Action': 'CancelLesson',
      'AccountType': 'Customer',
      'Phone': appState.currentCustomer!.phone,
      'Password': appState.currentCustomer!.password,
      'OrderID': lesson.orderID.toString(),
    },
  );

  if (response.statusCode == 200) {
    try {
      var jsonResponse = json.decode(response.body);
      if (jsonResponse['Result'] == 'SUCCESS') {
        appState.removeLesson(lesson.startTimestamp);
        appState.showMsgSnackBar(AppLocalizations.of(appState.rootContext!)!.lessonCancelled);
        return true;
      } else if (jsonResponse['Result'] == 'PHONE_DOESNT_EXIST') {
        logout(appState);
        return false;
      } else if (jsonResponse['Result'] == 'LESSON_ALREADY_STARTED') {
        // appState.showErrorSnackBar(AppLocalizations.of(appState.rootContext!)!.lessonAlreadyStarted); // TODO: localize
        appState.showErrorSnackBar('Cannot cancel a lesson that has already started.');
        return false;
      }
      throw jsonResponse['Result'];
    } on FormatException {
      appState.showErrorSnackBar(AppLocalizations.of(appState.rootContext!)!.jsonFormatError);
      return false;
    } catch (e) {
      appState.showErrorSnackBar(e.toString());
      return false;
    }
  }

  return false;
}

Future<bool> acceptLesson(
  Lesson lesson,
  AppState appState,
) async {
  var response = await appState.dbRequest(
    body: {
      'Action': 'AcceptLesson',
      'AccountType': 'Teacher',
      'Phone': appState.currentTeacher!.phone,
      'Password': appState.currentTeacher!.password,
      'OrderID': lesson.orderID.toString(),
    },
  );

  if (response.statusCode == 200) {
    try {
      var jsonResponse = json.decode(response.body);
      if (jsonResponse['Result'] == 'SUCCESS') {
        if (lesson.isImmediate) {
          lesson.copyFrom(Lesson.fromDict(jsonResponse['Details']));
        } else {
          lesson.teacherName = appState.currentTeacher!.username;
          lesson.teacherID = appState.currentTeacher!.id;
          lesson.isPending = false;
        }
        appState.addLesson(lesson);
        appState.showMsgSnackBar(AppLocalizations.of(appState.rootContext!)!.lessonAccepted);
        return true;
      } else if (jsonResponse['Result'] == 'PHONE_DOESNT_EXIST') {
        logout(appState);
        return false;
      } else if (jsonResponse['Result'] == 'LESSON_DOESNT_EXIST') {
        appState.showErrorSnackBar(AppLocalizations.of(appState.rootContext!)!.lessonDoesNotExist);
        return false;
      } else if (jsonResponse['Result'] == 'LESSON_ALREADY_ACCEPTED') {
        // appState.showErrorSnackBar(AppLocalizations.of(appState.rootContext!)!.lessonAlreadyAccepted); // TODO: localize
        appState.showErrorSnackBar('This lesson has already been accepted by a teacher.');
        return false;
      }
      throw jsonResponse['Result'];
    } on FormatException {
      appState.showErrorSnackBar(AppLocalizations.of(appState.rootContext!)!.jsonFormatError);
      return false;
    } catch (e) {
      appState.showErrorSnackBar(e.toString());
      return false;
    }
  }

  return false;
}

Future<bool> rejectLesson(
  Lesson lesson,
  AppState appState,
) async {
  var response = await appState.dbRequest(
    body: {
      'Action': 'RejectLesson',
      'AccountType': 'Teacher',
      'Phone': appState.currentTeacher!.phone,
      'Password': appState.currentTeacher!.password,
      'OrderID': lesson.orderID.toString(),
    },
  );

  if (response.statusCode == 200) {
    try {
      var jsonResponse = json.decode(response.body);
      if (jsonResponse['Result'] == 'SUCCESS') {
        appState.removeLesson(lesson.startTimestamp, studentID: lesson.studentID);
        appState.showMsgSnackBar(AppLocalizations.of(appState.rootContext!)!.lessonCancelled);
        return true;
      } else if (jsonResponse['Result'] == 'PHONE_DOESNT_EXIST') {
        logout(appState);
        return false;
      } else if (jsonResponse['Result'] == 'LESSON_DOESNT_EXIST') {
        appState.removeLesson(lesson.startTimestamp, studentID: lesson.studentID);
        appState.showErrorSnackBar(AppLocalizations.of(appState.rootContext!)!.lessonDoesNotExist);
        return false;
      } else if (jsonResponse['Result'] == 'LESSON_ALREADY_STARTED') {
        // appState.showErrorSnackBar(AppLocalizations.of(appState.rootContext!)!.lessonAlreadyStarted); // TODO: localize
        appState.showErrorSnackBar('Cannot cancel a lesson that has already started.');
        return false;
      }
      throw jsonResponse['Result'];
    } on FormatException {
      appState.showErrorSnackBar(AppLocalizations.of(appState.rootContext!)!.jsonFormatError);
      return false;
    } catch (e) {
      appState.showErrorSnackBar(e.toString());
      return false;
    }
  }

  return false;
}

// if link is available, update the lesson link and start timestamp in the app state and return true
// if link is not available, return false
Future<bool> getLiveLessonLink(int orderID, AppState appState, {bool isBackground = false}) async {
  var response = await appState.dbRequest(
    body: {
      'Action': 'GetLiveLessonLink',
      'OrderID': orderID.toString(),
    },
    indicateLoading: !isBackground,
  );

  if (response.statusCode == 200) {
    try {
      var jsonResponse = json.decode(response.body);
      if (jsonResponse['Result'] == 'SUCCESS') {
        appState.copyLessonFrom(Lesson.fromDict(jsonResponse['Details']));
        return true;
      } else if (jsonResponse['Result'] == 'LESSON_DOESNT_EXIST') {
        if (!isBackground) appState.showErrorSnackBar(AppLocalizations.of(appState.rootContext!)!.lessonDoesNotExist);
        return false;
      } else if (jsonResponse['Result'] == 'LINK_NOT_READY') {
        // if (!isBackground) appState.showErrorSnackBar(AppLocalizations.of(appState.rootContext!)!.lessonLinkNotReady); // TODO: localize
        if (!isBackground) appState.showErrorSnackBar('We are assigning a teacher to your lesson. Please wait.');
        return false;
      }
      throw jsonResponse['Result'];
    } on FormatException {
      appState.showErrorSnackBar(AppLocalizations.of(appState.rootContext!)!.jsonFormatError);
      return false;
    } catch (e) {
      appState.showErrorSnackBar(e.toString());
      return false;
    }
  }

  return false;
}
