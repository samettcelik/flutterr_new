import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_application_2/PersonelSec.dart';
import 'package:http/http.dart' as http;

import 'Lokasyon.dart';
import 'RoomsPage.dart';

class Sayim extends StatefulWidget {
  final String username;

  Sayim({required this.username});

  @override
  _SayimState createState() => _SayimState();
}

class _SayimState extends State<Sayim> {
  String? selectedRoomNum;
  int? selectedSubId;
  int? selectedRoomId;
  String? selectedPersonelAdSoyad; // Seçilen personelin ad soyadı
  String? selectedPersonelSicilNo; // Seçilen personelin sicil numarası

  String? barcodeInput;

  int totalEnvanter = 0;
  int bulunanEnvanter = 0;
  int bulunmayanEnvanter = 0;
  int farkliLokasyonEnvanter = 0;

  void _navigateAndSelectLocation(BuildContext context) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => Lokasyon(username: widget.username),
      ),
    );

    if (result != null) {
      setState(() {
        selectedSubId = result;
        _navigateAndSelectRoom(context);
      });
    }
  }

  void _navigateAndSelectRoom(BuildContext context) async {
    if (selectedSubId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lütfen önce bir lokasyon seçin!')),
      );
      return;
    }

    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => RoomsPage(subId: selectedSubId!),
      ),
    );

    if (result != null && result is Map<String, dynamic>) {
      setState(() {
        selectedRoomNum = result['odaNum'];
        selectedRoomId = result['id'];
        _fetchEnvanterSayisi(selectedRoomId!);
      });
    }
  }

  void _navigateAndSelectPersonel(BuildContext context) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            PersonelSec(), // Personel seçimi ekranına yönlendir
      ),
    );

    if (result != null && result is Map<String, dynamic>) {
      setState(() {
        selectedPersonelAdSoyad =
            result['adSoyad']; // Seçilen personelin ad soyadını alıyoruz
        selectedPersonelSicilNo =
            result['sicilNo']; // Seçilen personelin sicil numarasını alıyoruz
      });
    }
  }

  Future<void> _fetchEnvanterSayisi(int roomId) async {
    try {
      final totalResponse = await http.get(
          Uri.parse('http://10.10.208.86:8083/api/materials/total/$roomId'));
      final totalData = json.decode(totalResponse.body);

      final foundResponse = await http.get(
          Uri.parse('http://10.10.208.86:8083/api/materials/found/$roomId'));
      final foundData = json.decode(foundResponse.body);

      final otherLocationsResponse = await http.get(Uri.parse(
          'http://10.10.208.86:8083/api/materials/other-locations/$roomId'));
      final otherLocationsData = json.decode(otherLocationsResponse.body);

      setState(() {
        totalEnvanter = totalData;
        bulunanEnvanter = foundData;
        bulunmayanEnvanter = totalEnvanter - bulunanEnvanter;
        farkliLokasyonEnvanter = otherLocationsData;
      });
    } catch (e) {
      print('Envanter bilgisi alınırken hata oluştu: $e');
    }
  }

  void _checkBarcode() async {
    if (barcodeInput != null && barcodeInput!.isNotEmpty) {
      try {
        final response = await http.post(
          Uri.parse(
              'http://10.10.208.86:8083/api/materials/update-status?barkodNo=$barcodeInput&found=true'),
        );
        if (response.statusCode == 200) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Barkod başarıyla güncellendi.')),
          );
          _fetchEnvanterSayisi(selectedRoomId!);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Barkod güncellemesi başarısız oldu.')),
          );
        }
      } catch (e) {
        print('Barkod güncellenirken hata oluştu: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Bir hata oluştu.')),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lütfen bir barkod numarası girin')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                SizedBox(height: 20),
                Text(
                  'SAYIM',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 10),
                ElevatedButton(
                  onPressed: () => _navigateAndSelectLocation(context),
                  child: Text(
                    'LOKASYON SEÇ',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.black,
                    backgroundColor: Colors.grey[200],
                    padding: EdgeInsets.symmetric(horizontal: 40, vertical: 10),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                      side: BorderSide(color: Colors.black),
                    ),
                  ),
                ),
                SizedBox(height: 10),
                ElevatedButton(
                  onPressed: () => _navigateAndSelectPersonel(context),
                  child: Text(
                    'PERSONEL SEÇ',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.black,
                    backgroundColor: Colors.grey[200],
                    padding: EdgeInsets.symmetric(horizontal: 40, vertical: 10),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                      side: BorderSide(color: Colors.black),
                    ),
                  ),
                ),
                SizedBox(height: 10),
                selectedPersonelAdSoyad != null &&
                        selectedPersonelSicilNo != null
                    ? Text(
                        'Personel: $selectedPersonelAdSoyad\nSicil No: $selectedPersonelSicilNo',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.blue,
                          fontWeight: FontWeight.bold,
                        ),
                      )
                    : Text(
                        'Henüz Personel Seçmediniz.',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.red,
                        ),
                      ),
                SizedBox(height: 10),
                selectedRoomNum != null
                    ? Text(
                        'Oda Numarası: $selectedRoomNum',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.blue,
                          fontWeight: FontWeight.bold,
                        ),
                      )
                    : Text(
                        'Henüz Lokasyon Seçmediniz.',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.red,
                        ),
                      ),
                SizedBox(height: 10),
                TextField(
                  onChanged: (value) {
                    setState(() {
                      barcodeInput = value;
                    });
                  },
                  decoration: InputDecoration(
                    labelText: 'Barkod Numarası Girin',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                ),
                SizedBox(height: 10),
                ElevatedButton(
                  onPressed: _checkBarcode,
                  child: Text(
                    'Barkod Kontrolü',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.black,
                    backgroundColor: Colors.grey[200],
                    padding: EdgeInsets.symmetric(horizontal: 40, vertical: 10),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                      side: BorderSide(color: Colors.black),
                    ),
                  ),
                ),
                SizedBox(height: 20),
                _buildEnvanterInfo(
                    'TOPLAM SAYILMASI GEREKEN ENVANTER', totalEnvanter),
                SizedBox(height: 10),
                _buildEnvanterInfo(
                    'BULUNMAYAN ENVANTERLER', bulunmayanEnvanter),
                SizedBox(height: 10),
                _buildEnvanterInfo('BULUNAN ENVANTERLER', bulunanEnvanter),
                SizedBox(height: 10),
                _buildEnvanterInfo(
                    'FARKLI LOKASYONDAKİ ENVANTERLER', farkliLokasyonEnvanter),
                SizedBox(height: 10),
                ElevatedButton(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Sayım kaydedildi.')),
                    );
                  },
                  child: Text(
                    'SAYIM KAYDET',
                    style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.black),
                  ),
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.black,
                    backgroundColor: Colors.grey[200],
                    padding: EdgeInsets.symmetric(horizontal: 40, vertical: 10),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                      side: BorderSide(color: Colors.black),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEnvanterInfo(String title, int count) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
      decoration: BoxDecoration(
        color: Colors.grey[200],
        border: Border.all(color: Colors.black),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Text(
              title,
              style: TextStyle(fontSize: 12, color: Colors.black),
            ),
          ),
          Container(
            width: 55,
            height: 45,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              border: Border.all(color: Colors.black),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              '$count',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
          ),
        ],
      ),
    );
  }
}