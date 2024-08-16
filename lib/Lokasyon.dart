import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class Lokasyon extends StatefulWidget {
  final String username;

  Lokasyon({required this.username});

  @override
  _LokasyonState createState() => _LokasyonState();
}

class _LokasyonState extends State<Lokasyon> {
  List<Map<String, dynamic>> subLocations = [];
  List<Map<String, dynamic>> filteredSubLocations = [];
  bool isLoading = false;
  String query = "";

  @override
  void initState() {
    super.initState();
    fetchSubLocations();
  }

  Future<void> fetchSubLocations() async {
    setState(() {
      isLoading = true;
    });

    final response = await http.get(Uri.parse('http://10.10.208.86:8083/api/sublocations'));

    if (response.statusCode == 200) {
      setState(() {
        subLocations = List<Map<String, dynamic>>.from(json.decode(response.body).map((data) => {'name': data['name'], 'id': data['id']}));
        filteredSubLocations = subLocations; // Başlangıçta tüm sub lokasyonları gösteriyoruz
        isLoading = false;
      });
    } else {
      setState(() {
        isLoading = false;
      });
    }
  }

  void updateSearchQuery(String newQuery) {
    setState(() {
      query = newQuery;
      filteredSubLocations = subLocations
          .where((subLocation) =>
              subLocation['name'].toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Lokasyon Seç'),
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: 'Lokasyon Ara...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.0),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: Colors.grey[200],
                      prefixIcon: Icon(Icons.search),
                    ),
                    onChanged: updateSearchQuery,
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    itemCount: filteredSubLocations.length,
                    itemBuilder: (context, index) {
                      return ListTile(
                        title: Text(filteredSubLocations[index]['name']),
                        onTap: () {
                          Navigator.pop(context, filteredSubLocations[index]['id']);
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
    );
  }
}
