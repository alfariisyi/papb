import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class HomePage extends StatelessWidget {
  void deleteData(String docId) async {
    try {
      await FirebaseFirestore.instance.collection('sampah').doc(docId).delete();
      print("Data deleted successfully");
    } catch (e) {
      print("Error deleting data: $e");
    }
  }

  Future<List<String>> fetchJenisSampah() async {
    try {
      final querySnapshot =
          await FirebaseFirestore.instance.collection('sampah').get();
      final jenisSampahList = querySnapshot.docs
          .map((doc) => doc['jenis_sampah'] as String)
          .toSet()
          .toList();
      return jenisSampahList;
    } catch (e) {
      print("Error fetching jenis sampah: $e");
      return [];
    }
  }

  void addData(BuildContext context) async {
    TextEditingController namaController = TextEditingController();
    TextEditingController volumeController = TextEditingController();
    String? selectedJenisSampah;

    List<String> jenisSampahList = await fetchJenisSampah();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return Padding(
          padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom,
              left: 16,
              right: 16,
              top: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Tambah Sampah',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 20),
              TextField(
                controller: namaController,
                decoration: InputDecoration(
                  labelText: "Nama Sampah",
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 10),
              DropdownButtonFormField<String>(
                decoration: InputDecoration(
                  labelText: "Jenis Sampah",
                  border: OutlineInputBorder(),
                ),
                items: jenisSampahList
                    .map((jenis) => DropdownMenuItem<String>(
                          value: jenis,
                          child: Text(jenis),
                        ))
                    .toList(),
                onChanged: (value) {
                  selectedJenisSampah = value;
                },
              ),
              SizedBox(height: 10),
              TextField(
                controller: volumeController,
                decoration: InputDecoration(
                  labelText: "Volume",
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
              ),
              SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey[300],
                    ),
                    child: Text("Batal", style: TextStyle(color: Colors.black)),
                  ),
                  SizedBox(width: 10),
                  ElevatedButton(
                    onPressed: () {
                      if (namaController.text.isNotEmpty &&
                          selectedJenisSampah != null &&
                          volumeController.text.isNotEmpty) {
                        FirebaseFirestore.instance.collection('sampah').add({
                          'nama_sampah': namaController.text,
                          'jenis_sampah': selectedJenisSampah,
                          'volume': int.parse(volumeController.text),
                        });
                        Navigator.of(context).pop();
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                              content:
                                  Text("Semua data harus diisi dengan benar")),
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green[300],
                    ),
                    child: Text("Tambah", style: TextStyle(color: Colors.black),),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  void logout(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Logout berhasil!")),
    );
    Navigator.of(context).pop(); 
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Data Sampah', style: TextStyle(color: Colors.black),),
        backgroundColor: Colors.green[100],
        actions: [
          TextButton(
            onPressed: () => logout(context),
            child: Text(
              "Logout",
              style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
      backgroundColor: Colors.white,
      body: StreamBuilder(
        stream: FirebaseFirestore.instance.collection('sampah').snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(child: Text('Tidak ada data.'));
          }

          Map<String, List<DocumentSnapshot>> groupedData = {};
          for (var doc in snapshot.data!.docs) {
            String jenisSampah = doc['jenis_sampah'];
            if (!groupedData.containsKey(jenisSampah)) {
              groupedData[jenisSampah] = [];
            }
            groupedData[jenisSampah]!.add(doc);
          }

          return ListView(
            children: groupedData.entries.map((entry) {
              String jenisSampah = entry.key;
              List<DocumentSnapshot> docs = entry.value;

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      jenisSampah,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.green[900],
                      ),
                    ),
                  ),
                  Card(
                    margin: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    elevation: 4,
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: DataTable(
                        border: TableBorder.all(
                          color: Colors.grey,
                          width: 1,
                        ),
                        headingRowColor: MaterialStateProperty.resolveWith(
                            (states) => Colors.green[100]),
                        columns: const [
                          DataColumn(label: Text('Nama Sampah')),
                          DataColumn(label: Text('Volume')),
                          DataColumn(label: Text('Aksi')),
                        ],
                        rows: docs.map((doc) {
                          return DataRow(cells: [
                            DataCell(Text(doc['nama_sampah'])),
                            DataCell(Text('${doc['volume']} Kg')),
                            DataCell(IconButton(
                              icon: Icon(Icons.delete, color: Colors.red),
                              onPressed: () {
                                deleteData(doc.id);
                              },
                            )),
                          ]);
                        }).toList(),
                      ),
                    ),
                  ),
                ],
              );
            }).toList(),
          );
        },
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ElevatedButton.icon(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.green[700],
            padding: EdgeInsets.symmetric(horizontal: 50, vertical: 20),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
          ),
          onPressed: () => addData(context),
          icon: Icon(Icons.add, color: Colors.white),
          label: Text(
            "Tambah Sampah",
            style: TextStyle(color: Colors.white),
          ),
        ),
      ),
    );
  }
}
