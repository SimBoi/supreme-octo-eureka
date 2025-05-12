import 'dart:convert';
import 'dart:developer';
import 'package:flutter/foundation.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:supreme_octo_eureka/app_state.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

Future<bool> loadSavedCredentials(AppState appState) async {
  final prefs = await SharedPreferences.getInstance();
  var phone = prefs.getString('phone') ?? '';
  var password = prefs.getString('password') ?? '';
  if (phone == '' || password == '') {
    return false;
  } else {
    var result = await login(phone, password, appState);
    if (result == false) {
      await saveCredentials('', '');
    }
    return result;
  }
}

Future<void> saveCredentials(String newPhone, String newPassword) async {
  final prefs = await SharedPreferences.getInstance();
  prefs.setString('phone', newPhone);
  prefs.setString('password', newPassword);
}

Future<String> getAccountType(String phone, AppState appState) async {
  appState.startLoading();
  var result = await _getAccountType(phone, appState);
  appState.stopLoading();
  return result;
}

Future<String> _getAccountType(String phone, AppState appState) async {
  if (phone == '') {
    appState.showErrorSnackBar(AppLocalizations.of(appState.rootContext!)!.phoneRequired);
    return 'ERROR';
  }

  // convert phone from the format 05XXXXXXXX to the format 9725XXXXXXXX
  if (phone.length == 10 && phone.startsWith('05')) {
    phone = '972${phone.substring(1)}';
  } else if (phone.length != 12 || !phone.startsWith('9725')) {
    appState.showErrorSnackBar(AppLocalizations.of(appState.rootContext!)!.invalidPhone);
    return 'ERROR';
  }

  var response = await appState.dbRequest(
    body: {
      'Action': 'GetAccountType',
      'Phone': phone,
    },
  );

  if (response.statusCode == 200) {
    try {
      var jsonResponse = json.decode(response.body);
      if (jsonResponse['Result'] == 'CUSTOMER') {
        return 'Customer';
      } else if (jsonResponse['Result'] == 'TEACHER') {
        return 'Teacher';
      } else if (jsonResponse['Result'] == 'PHONE_DOESNT_EXIST') {
        return 'None';
      }
      throw jsonResponse['Result'];
    } on FormatException {
      appState.showErrorSnackBar(AppLocalizations.of(appState.rootContext!)!.jsonFormatError);
    } catch (e) {
      appState.showErrorSnackBar(e.toString());
    }
  }

  return 'ERROR';
}

Future<bool> login(String phone, String password, AppState appState) async {
  appState.startLoading();
  var result = await _login(phone, password, appState);
  appState.stopLoading();
  return result;
}

Future<bool> _login(String phone, String password, AppState appState) async {
  // check if phone or password are empty
  if (phone == '' || password == '') {
    appState.showErrorSnackBar('Phone number and password are required!');
    return false;
  }

  // convert phone from the format 05XXXXXXXX to the format 9725XXXXXXXX
  if (phone.length == 10 && phone.startsWith('05')) {
    phone = '972${phone.substring(1)}';
  } else if (phone.length != 12 || !phone.startsWith('9725')) {
    appState.showErrorSnackBar(AppLocalizations.of(appState.rootContext!)!.invalidPhone);
    return false;
  }

  var response = await appState.dbRequest(
    body: {
      'Action': 'Login',
      'AccountType': 'None',
      'Phone': phone,
      'Password': password,
    },
  );

  if (response.statusCode == 200) {
    try {
      var jsonResponse = json.decode(response.body);
      if (jsonResponse['Result'] == 'CUSTOMER') {
        await saveCredentials(phone, password);

        appState.accountType = AccountType.customer;
        appState.currentCustomer = Customer(
          id: int.parse(jsonResponse['ID']),
          username: jsonResponse['Username'],
          phone: phone,
          password: password,
          currentAppointments: Lesson.fromJsonArray(jsonResponse['CurrentAppointments']),
          orders: Order.fromJsonArray(jsonResponse['Orders']),
        );

        await _loginOneSignal(appState.currentCustomer!.id.toString());

        return true;
      } else if (jsonResponse['Result'] == 'TEACHER') {
        await saveCredentials(phone, password);

        appState.accountType = AccountType.teacher;
        appState.currentTeacher = Teacher(
          id: int.parse(jsonResponse['ID']),
          username: jsonResponse['Username'],
          phone: phone,
          password: password,
          currentAppointments: Lesson.fromJsonArray(jsonResponse['CurrentAppointments']),
        );

        await _loginOneSignal(appState.currentTeacher!.id.toString());

        return true;
      } else if (jsonResponse['Result'] == 'PHONE_DOESNT_EXIST') {
        appState.showErrorSnackBar(AppLocalizations.of(appState.rootContext!)!.phoneDoesntExist);
        return false;
      } else if (jsonResponse['Result'] == 'WRONG_PASSWORD') {
        appState.showErrorSnackBar('Wrong passowrd!');
        return false;
      }
      throw jsonResponse['Result'];
    } on FormatException {
      appState.showErrorSnackBar(AppLocalizations.of(appState.rootContext!)!.jsonFormatError);
      // log the output of response.body
      log(response.body);
      return false;
    } catch (e) {
      appState.showErrorSnackBar(e.toString());
      return false;
    }
  }

  return false;
}

Future<void> _loginOneSignal(String externalID, {int timeout = 2000}) async {
  // check if OneSignal is available on this platform
  if (defaultTargetPlatform != TargetPlatform.iOS && defaultTargetPlatform != TargetPlatform.android) {
    return;
  }

  // wait for the OneSignal ID to be available
  var startTime = DateTime.now();
  while (DateTime.now().difference(startTime).inMilliseconds < timeout) {
    String oneSignalId = await OneSignal.User.getOnesignalId() ?? '';
    if (oneSignalId != '') {
      break;
    }
    await Future.delayed(const Duration(milliseconds: 100));
  }

  OneSignal.login(externalID);
  OneSignal.User.pushSubscription.optIn();
}

Future<void> logout(AppState appState) async {
  await saveCredentials('', '');
  appState.accountType = AccountType.none;
  appState.currentCustomer = null;
  appState.currentTeacher = null;

  await _logoutOneSignal();

  // remove all routes and push the login page
  appState.navigatorKey.currentState!.pushNamedAndRemoveUntil('/', (route) => false);
}

Future<void> _logoutOneSignal() async {
  // check if OneSignal is available on this platform
  if (defaultTargetPlatform != TargetPlatform.iOS && defaultTargetPlatform != TargetPlatform.android) {
    return;
  }

  OneSignal.logout();
}

Future<bool> signup(String phone, String username, AppState appState) async {
  appState.startLoading();
  var result = await _signup(phone, username, appState);
  appState.stopLoading();
  return result;
}

Future<bool> _signup(String phone, String username, AppState appState) async {
  if (phone == '') {
    appState.showErrorSnackBar(AppLocalizations.of(appState.rootContext!)!.phoneRequired);
    return false;
  }

  // convert phone from the format 05XXXXXXXX to the format 9725XXXXXXXX
  if (phone.length == 10 && phone.startsWith('05')) {
    phone = '972${phone.substring(1)}';
  } else if (phone.length != 12 || !phone.startsWith('9725')) {
    appState.showErrorSnackBar(AppLocalizations.of(appState.rootContext!)!.invalidPhone);
    return false;
  }

  if (username.length < 3) {
    appState.showErrorSnackBar(AppLocalizations.of(appState.rootContext!)!.usernameLengthLessThan3);
    return false;
  }

  var response = await appState.dbRequest(
    body: {
      'Action': 'Signup',
      'AccountType': 'Customer',
      'Phone': phone,
      'Username': username,
    },
  );

  if (response.statusCode == 200) {
    try {
      var jsonResponse = json.decode(response.body);
      if (jsonResponse['Result'] == 'SUCCESS') {
        await saveCredentials(phone, "");
        appState.accountType = AccountType.customer;
        appState.currentCustomer = Customer(
          id: 0,
          username: username,
          phone: phone,
          password: "",
          currentAppointments: List.empty(),
          orders: List.empty(),
        );
        return true;
      } else if (jsonResponse['Result'] == 'PHONE_EXISTS') {
        appState.showErrorSnackBar(AppLocalizations.of(appState.rootContext!)!.phoneExists);
        return false;
      } else if (jsonResponse['Result'] == 'ERROR') {
        appState.showErrorSnackBar('Error signing up!');
        return false;
      }
      throw 'error';
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

Future<
    (
      bool,
      int
    )> requestVerification(String phone, AppState appState) async {
  appState.startLoading();
  var result = await _requestVerification(phone, appState);
  appState.stopLoading();
  return result;
}

Future<
    (
      bool,
      int
    )> _requestVerification(String phone, AppState appState) async {
  var response = await appState.dbRequest(
    body: {
      'Action': 'RequestVerificationCode',
      'AccountType': appState.accountType == AccountType.customer ? 'Customer' : 'Teacher',
      'Phone': phone,
      'Language': appState.language,
    },
  );

  if (response.statusCode == 200) {
    try {
      var jsonResponse = json.decode(response.body);
      if (jsonResponse['Result'] == 'SUCCESS') {
        appState.showMsgSnackBar(AppLocalizations.of(appState.rootContext!)!.verificationCodeSent((jsonResponse['ExpiresIn'] / 60).toInt().toString()));
        return (
          true,
          jsonResponse['Cooldown'] as int
        );
      } else if (jsonResponse['Result'] == 'COOLDOWN') {
        appState.showErrorSnackBar(AppLocalizations.of(appState.rootContext!)!.verificationCodeAlreadySent);
        return (
          true,
          jsonResponse['Cooldown'] as int,
        );
      } else if (jsonResponse['Result'] == 'ERROR') {
        appState.showErrorSnackBar(AppLocalizations.of(appState.rootContext!)!.errorRequestingVerificationCode);
        return (
          false,
          -1
        );
      }
      throw 'error';
    } on FormatException {
      appState.showErrorSnackBar(AppLocalizations.of(appState.rootContext!)!.jsonFormatError);
      return (
        false,
        -1
      );
    } catch (e) {
      appState.showErrorSnackBar(e.toString());
      return (
        false,
        -1
      );
    }
  }

  return (
    false,
    -1
  );
}

Future<bool> verifyPhone(String phone, String verificationCode, AppState appState) async {
  appState.startLoading();
  var result = await _verifyPhone(phone, verificationCode, appState);
  appState.stopLoading();
  return result;
}

Future<bool> _verifyPhone(String phone, String verificationCode, AppState appState) async {
  var response = await appState.dbRequest(
    body: {
      'Action': 'VerifyPhone',
      'AccountType': appState.accountType == AccountType.customer ? 'Customer' : 'Teacher',
      'Phone': phone,
      'VerificationCode': verificationCode,
    },
  );

  if (response.statusCode == 200) {
    try {
      var jsonResponse = json.decode(response.body);
      if (jsonResponse['Result'] == 'SUCCESS') {
        if (appState.accountType == AccountType.customer) {
          appState.currentCustomer!.password = jsonResponse['GeneratedPassword'];
        } else {
          appState.currentTeacher!.password = jsonResponse['GeneratedPassword'];
        }

        appState.showMsgSnackBar(AppLocalizations.of(appState.rootContext!)!.phoneVerified);
        return true;
      } else if (jsonResponse['Result'] == 'PHONE_ALREADY_VERIFIED') {
        return true;
      } else if (jsonResponse['Result'] == 'CODE_EXPIRED') {
        appState.showErrorSnackBar(AppLocalizations.of(appState.rootContext!)!.verificationCodeExpired);
        return false;
      } else if (jsonResponse['Result'] == 'WRONG_CODE') {
        appState.showErrorSnackBar(AppLocalizations.of(appState.rootContext!)!.wrongVerificationCode);
        return false;
      } else if (jsonResponse['Result'] == 'ERROR') {
        appState.showErrorSnackBar('Error verifying phone number!');
        return false;
      }
      throw 'error';
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
