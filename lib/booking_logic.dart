import 'dart:convert';
import 'package:supreme_octo_eureka/app_state.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

Future<String?> createOrderRequest(
  Lesson lesson,
  AppState appState,
) async {
  var response = await appState.dbRequest(
    body: {
      'Action': 'CreateOrderRequest',
      'AccountType': 'Customer',
      'Phone': appState.currentCustomer!.phone,
      'Password': appState.currentCustomer!.password,
      'Title': lesson.title,
      'StartTimestamp': lesson.startTimestamp.toString(),
      'DurationMinutes': lesson.durationMinutes.toString(),
      'Language': 'ENG', // TODO: language
    },
  );

  if (response.statusCode == 200) {
    try {
      var jsonResponse = json.decode(response.body);
      if (jsonResponse['Result'] == 'SUCCESS') {
        lesson.orderID = jsonResponse['OrderID'] as int;
        return jsonResponse['PaymentLink'];
      } else if (jsonResponse['Result'] == 'PHONE_DOESNT_EXIST' || jsonResponse['Result'] == 'WRONG_PASSWORD') {
        // TODO: logout
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
        // TODO: logout
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
        // TODO: logout
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
  String link,
  AppState appState,
) async {
  var response = await appState.dbRequest(
    body: {
      'Action': 'AcceptLesson',
      'AccountType': 'Teacher',
      'Phone': appState.currentTeacher!.phone,
      'Password': appState.currentTeacher!.password,
      'OrderID': lesson.orderID.toString(),
      'Link': link,
    },
  );

  if (response.statusCode == 200) {
    try {
      var jsonResponse = json.decode(response.body);
      if (jsonResponse['Result'] == 'SUCCESS') {
        lesson.teacherName = appState.currentTeacher!.username;
        lesson.teacherID = appState.currentTeacher!.id;
        lesson.link = link;
        lesson.isPending = false;
        appState.addLesson(lesson);
        appState.showMsgSnackBar(AppLocalizations.of(appState.rootContext!)!.lessonAccepted);
        return true;
      } else if (jsonResponse['Result'] == 'PHONE_DOESNT_EXIST') {
        // TODO: logout
        return false;
      } else if (jsonResponse['Result'] == 'LESSON_DOESNT_EXIST') {
        appState.showErrorSnackBar(AppLocalizations.of(appState.rootContext!)!.lessonDoesNotExist);
        // TODO: refresh lessons
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

Future<bool> editLessonLink(
  Lesson lesson,
  String newLink,
  AppState appState,
) async {
  var response = await appState.dbRequest(
    body: {
      'Action': 'EditLessonLink',
      'AccountType': 'Teacher',
      'Phone': appState.currentTeacher!.phone,
      'Password': appState.currentTeacher!.password,
      'OrderID': lesson.orderID.toString(),
      'NewLink': newLink,
    },
  );

  if (response.statusCode == 200) {
    try {
      var jsonResponse = json.decode(response.body);
      if (jsonResponse['Result'] == 'SUCCESS') {
        lesson.link = newLink;
        appState.updateLessonLink(lesson.startTimestamp, newLink);
        appState.showMsgSnackBar(AppLocalizations.of(appState.rootContext!)!.linkUpdated);
        return true;
      } else if (jsonResponse['Result'] == 'PHONE_DOESNT_EXIST' || jsonResponse['Result'] == 'WRONG_PASSWORD') {
        // TODO: logout
        return false;
      } else if (jsonResponse['Result'] == 'LESSON_DOESNT_EXIST') {
        appState.showErrorSnackBar(AppLocalizations.of(appState.rootContext!)!.lessonDoesNotExist);
        // TODO: refresh lessons
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
        // TODO: logout
        return false;
      } else if (jsonResponse['Result'] == 'LESSON_DOESNT_EXIST') {
        appState.removeLesson(lesson.startTimestamp, studentID: lesson.studentID);
        appState.showErrorSnackBar(AppLocalizations.of(appState.rootContext!)!.lessonDoesNotExist);
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
