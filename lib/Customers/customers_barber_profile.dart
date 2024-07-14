import 'dart:convert';

import 'package:supreme_octo_eureka/app_state.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class BarberProfilePage extends StatelessWidget {
  final int id;

  const BarberProfilePage({
    super.key,
    required this.id,
  });

  Future<Barber> fetchBarberProfile(int barberId, AppState appState) async {
    var response = await appState.dbRequest(
      body: {
        'Action': 'LoadBarberProfile',
        'AccountType': 'Customer',
        'BarberID': barberId.toString(),
      },
      indicateLoading: false,
    );

    if (response.statusCode == 200) {
      try {
        // json response is of the following format: {SUCCESS,ProfileImage,Phone,Username,Instagram,TimeBetweenAppointments,About,Services,Sunday,Monday,Tuesday,Wednesday,Thursday,Friday,Saturday,Latitude,Longitude}
        var jsonResponse = json.decode(response.body);
        if (jsonResponse['Result'] == 'SUCCESS') {
          return Barber(
            id: barberId,
            username: jsonResponse['Username'],
            profileImage: jsonResponse['ProfileImage'],
            phone: jsonResponse['Phone'],
            password: '',
            instagram: jsonResponse['Instagram'],
            about: jsonResponse['About'],
            services: jsonResponse['Services'],
            latitude: 0, // TODO: add latitude
            longitude: 0, // TODO: add longitude
            oneSignalID: '',
            blockedCustomers: [],
            maxBookingDaysAhead: 0,
            timeBetweenAppointments: int.parse(jsonResponse['TimeBetweenAppointments']),
            sunday: jsonResponse['Sunday'],
            monday: jsonResponse['Monday'],
            tuesday: jsonResponse['Tuesday'],
            wednesday: jsonResponse['Wednesday'],
            thursday: jsonResponse['Thursday'],
            friday: jsonResponse['Friday'],
            saturday: jsonResponse['Saturday'],
          );
        } else if (jsonResponse['Result'] == 'ERROR') {
          appState.showErrorSnackBar('Error loading barber profile!');
          return Barber.empty;
        }
        throw 'error';
      } on FormatException {
        appState.showErrorSnackBar('Json Format Error');
        return Barber.empty;
      } catch (e) {
        appState.showErrorSnackBar('Unexpected Error');
        return Barber.empty;
      }
    }
    return Barber.empty;
  }

  @override
  Widget build(BuildContext context) {
    var appState = context.read<AppState>();
    // create a futurebuilder that calls fetchBarberProfile and displays the barber's profile when its ready, otherwise show a loading indicator
    return FutureBuilder<Barber?>(
      future: fetchBarberProfile(id, appState),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          if (snapshot.hasData) {
            if (snapshot.data == Barber.empty) {
              return const Scaffold(
                body: Center(
                  child: Text('Error loading barber profile!'),
                ),
              );
            }
            Barber barber = snapshot.data!;
            return Scaffold(
              appBar: AppBar(
                title: const Text('Barber Profile'),
              ),
              body: const Placeholder(),
            );
          } else {
            return const Center(child: CircularProgressIndicator());
          }
        } else {
          return const Center(child: CircularProgressIndicator());
        }
      },
    );
  }
}
