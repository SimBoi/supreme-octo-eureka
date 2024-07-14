import 'dart:convert';

import 'package:supreme_octo_eureka/Widgets/barber_card.dart';
import 'package:supreme_octo_eureka/app_state.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supreme_octo_eureka/Customers/customers_barber_profile.dart';

class SearchTab extends StatelessWidget {
  SearchTab({super.key});

  final TextEditingController _searchController = TextEditingController();
  final GlobalKey<_SearchResultsState> _searchResultsKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    var appState = context.read<AppState>();

    // Splits the screen into two sections: a search bar and a list of results
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    labelText: 'Search',
                    hintText: 'Search',
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  keyboardType: TextInputType.text, // Set keyboard type to text
                  textInputAction: TextInputAction.search,
                  onChanged: (value) => _search(true, value, appState),
                  onSubmitted: (value) => _search(false, value, appState),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: SearchResults(key: _searchResultsKey),
        ),
      ],
    );
  }

  // submit search query and trigger search
  void _search(bool isQuickSearch, String query, AppState appState) async {
    // if the string is numeric, format the phone number
    if (RegExp(r'^[0-9]+$').hasMatch(query) && query.startsWith('05')) {
      query = '972${query.substring(1)}';
    }

    // check if search query is empty
    if (query == '') {
      return;
    }

    var response = await appState.dbRequest(
      body: {
        'Action': 'SearchBarbers',
        'AccountType': 'Customer',
        'SearchQuery': query,
        'IsQuickSearch': isQuickSearch ? '1' : '0',
      },
    );

    if (response.statusCode == 200) {
      try {
        var jsonResponse = json.decode(response.body);
        if (jsonResponse['Result'] == 'SUCCESS') {
          // json response is of the format: {'Result': 'SUCCESS', 'Barbers': [{'ID': '<id>', 'ProfileImage': '<some url>', 'Username': '<username>', 'Latitude': <some int>, 'Longitude': <some int>}*]}
          _searchResultsKey.currentState!.updateSearchResults(jsonResponse['Barbers']);
          return;
        } else if (jsonResponse['Result'] == 'ERROR') {
          appState.showErrorSnackBar('Error searching for customers!');
          return;
        }
        throw 'error';
      } on FormatException {
        appState.showErrorSnackBar('Json Format Error');
        return;
      } catch (e) {
        appState.showErrorSnackBar('Unexpected Error');
        return;
      }
    }
  }
}

class SearchResults extends StatefulWidget {
  const SearchResults({Key? key}) : super(key: key);

  @override
  State<SearchResults> createState() => _SearchResultsState();
}

class _SearchResultsState extends State<SearchResults> {
  List<dynamic> _searchResults = [];

  void updateSearchResults(List<dynamic> searchResults) {
    setState(() {
      _searchResults = searchResults;
    });
  }

  void _openBarberProfile(int id) {
    Navigator.of(context).push(MaterialPageRoute(builder: (context) => BarberProfilePage(id: id)));
  }

  @override
  Widget build(BuildContext context) {
    // show a vertically scrollable grid of barber cards, two cards in each row
    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 3 / 4, // Set aspect ratio to 3:4
      ),
      padding: const EdgeInsets.all(8.0), // Add padding between elements
      itemCount: _searchResults.length,
      itemBuilder: (context, index) {
        Map<String, dynamic> barber = _searchResults[index];
        return Padding(
          padding: const EdgeInsets.all(8.0), // Add padding around each BarberCard
          child: BarberCard(
            name: barber['Username'],
            pictureURL: barber['ProfileImage'],
            id: int.parse(barber['ID']),
            distance: 0, // TODO: calculate distance using latitude and longitude
            onTap: () => _openBarberProfile(
              int.parse(barber['ID']),
            ),
          ),
        );
      },
    );
  }
}
