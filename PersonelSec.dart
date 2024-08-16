import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class PersonelSec extends StatefulWidget {
  @override
  _PersonelSecState createState() => _PersonelSecState();
}

class _PersonelSecState extends State<PersonelSec> {
  TextEditingController _controller = TextEditingController();
  List<Map<String, dynamic>> searchResults = [];
  List<Map<String, dynamic>> uniquePersonelList = [];
  List<Map<String, dynamic>> roomList = [];
  bool isLoading = false;
  String errorMessage = '';
  Map<String, dynamic>? selectedPersonel; // Seçilen personel bilgisi

  void _searchPersonel() async {
    setState(() {
      isLoading = true;
      errorMessage = '';
      selectedPersonel = null;
      roomList.clear();
    });

    final query = _controller.text.trim();

    try {
      final response = await http.get(Uri.parse(
          'http://10.10.208.86:8083/api/personel/search?query=$query'));

      if (response.statusCode == 200) {
        searchResults =
            List<Map<String, dynamic>>.from(json.decode(response.body));
        _groupBySicilNo(); // Aynı sicil numarasına sahip personelleri grupluyoruz
        setState(() {
          isLoading = false;

          if (uniquePersonelList.isEmpty) {
            errorMessage = 'Personel bulunamadı';
          }
        });
      } else {
        setState(() {
          isLoading = false;
          errorMessage = 'Bir hata oluştu: ${response.body}';
        });
      }
    } catch (e) {
      setState(() {
        isLoading = false;
        errorMessage = 'Bir hata oluştu: $e';
      });
    }
  }

  void _groupBySicilNo() {
    // Aynı sicil numarasına sahip personelleri grupluyoruz
    Map<String, Map<String, dynamic>> grouped = {};
    for (var personel in searchResults) {
      grouped[personel['sicilNo']] = personel;
    }
    uniquePersonelList = grouped.values.toList();
  }

  void _showRoomList(Map<String, dynamic> personel) {
    setState(() {
      selectedPersonel = personel;
      roomList = searchResults
          .where((p) => p['sicilNo'] == personel['sicilNo'])
          .toList();
    });
  }

  void _selectRoom(Map<String, dynamic> room) {
    Navigator.pop(context, {
      'personel': selectedPersonel,
      'odaNum': room['odaNum'],
      'roomId': room['id'], // roomId'yi ekleyelim
      'personelId': selectedPersonel!['id'], // personelId'yi ekleyelim
      'personelAdSoyad': selectedPersonel!['adSoyad'], // personelin ad ve soyadını ekleyelim
      'personelSicilNo': selectedPersonel!['sicilNo'], // personelin sicil numarasını ekleyelim
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Personel Seç'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            TextField(
              controller: _controller,
              keyboardType: TextInputType.text,
              decoration: InputDecoration(
                hintText: 'Sicil No veya Ad Soyad Giriniz',
                border: OutlineInputBorder(),
                suffixIcon: IconButton(
                  icon: Icon(Icons.search),
                  onPressed: _searchPersonel,
                ),
              ),
            ),
            SizedBox(height: 10),
            isLoading
                ? CircularProgressIndicator()
                : errorMessage.isNotEmpty
                    ? Text(
                        errorMessage,
                        style: TextStyle(color: Colors.red),
                      )
                    : Expanded(
                        child: ListView.builder(
                          itemCount: uniquePersonelList.length,
                          itemBuilder: (context, index) {
                            final personel = uniquePersonelList[index];
                            return ListTile(
                              title: Text(personel['adSoyad']),
                              subtitle:
                                  Text('Sicil No: ${personel['sicilNo']}'),
                              onTap: () {
                                _showRoomList(personel);
                              },
                            );
                          },
                        ),
                      ),
            if (selectedPersonel != null)
              Expanded(
                child: Column(
                  children: [
                    Divider(),
                    Text(
                      'Oda Seç',
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    Expanded(
                      child: ListView.builder(
                        itemCount: roomList.length,
                        itemBuilder: (context, index) {
                          final room = roomList[index]['room'];
                          return ListTile(
                            title: Text(
                              'Oda: ${room['odaNum']}',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.green, // Yeşil renk, personelden gelen
                              ),
                            ),
                            onTap: () {
                              _selectRoom(room);
                            },
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}
