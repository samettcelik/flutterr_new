import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class RoomsPage extends StatefulWidget {
  final int subId;

  RoomsPage({required this.subId});

  @override
  _RoomsPageState createState() => _RoomsPageState();
}

class _RoomsPageState extends State<RoomsPage> {
  List<Map<String, dynamic>> rooms = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchRooms(widget.subId);
  }

  Future<void> fetchRooms(int subId) async {
    final response = await http.get(Uri.parse('http://10.10.208.86:8083/api/rooms/$subId'));

    if (response.statusCode == 200) {
      setState(() {
        rooms = List<Map<String, dynamic>>.from(json.decode(response.body));
        isLoading = false;
      });
    } else {
      setState(() {
        rooms = [{'odaNum': 'Odalar yüklenemedi'}];
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Oda Numaraları'),
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : rooms.isNotEmpty
              ? ListView.builder(
                  itemCount: rooms.length,
                  itemBuilder: (context, index) {
                    return ListTile(
                      title: Text(rooms[index]['odaNum']),
                      onTap: () {
                        Navigator.pop(context, {
                          'odaNum': rooms[index]['odaNum'],
                          'id': rooms[index]['id'],
                        }); // Seçilen oda numarası ve ID'yi geri döndürüyoruz
                      },
                    );
                  },
                )
              : Center(
                  child: Text(
                    'Oda numarası yok',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                  ),
                ),
    );
  }
}
