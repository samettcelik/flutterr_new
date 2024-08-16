import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class MalzemeBul extends StatefulWidget {
  @override
  _MalzemeBulState createState() => _MalzemeBulState();
}

class _MalzemeBulState extends State<MalzemeBul> {
  final TextEditingController _barkodController = TextEditingController();
  Map<String, dynamic>? materialDetails;

  Future<void> fetchMaterialDetails(String barkodNo) async {
    final response = await http.get(Uri.parse('http://10.10.208.86:8083/api/materials/details/$barkodNo'));

    if (response.statusCode == 200) {
      setState(() {
        materialDetails = json.decode(response.body);
      });
    } else {
      // Eğer veri bulunmazsa ya da hata oluşursa:
      setState(() {
        materialDetails = null;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Malzeme Bul'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _barkodController,
              decoration: InputDecoration(
                labelText: 'Barkod No Giriniz',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                fetchMaterialDetails(_barkodController.text);
              },
              child: Text('Bul'),
            ),
            SizedBox(height: 20),
            if (materialDetails != null)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('SubLokasyon: ${materialDetails!['room']['subLocation']['name']}'),
                  Text('Oda Numarası: ${materialDetails!['room']['odaNum']}'),
                  Text('Model: ${materialDetails!['model']}'),
                  Text('Marka: ${materialDetails!['marka']}'),
                ],
              ),
            if (materialDetails == null && _barkodController.text.isNotEmpty)
              Text('Veri bulunamadı'),
          ],
        ),
      ),
    );
  }
}
