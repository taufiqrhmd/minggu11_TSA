import 'package:android_intent_plus/android_intent.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:tsa_w11/login.dart';

class homeScreen extends StatefulWidget {
  homeScreen({Key? key}) : super(key: key);

  @override
  State<homeScreen> createState() => _homeScreenState();
}

class _homeScreenState extends State<homeScreen> {
  Position lokasi = Position(
    longitude: 0,
    latitude: 0,
    timestamp: DateTime.now(),
    accuracy: 0,
    altitude: 0,
    heading: 0,
    speed: 0,
    speedAccuracy: 0,
  );
  String alamat = 'Tidak diketahui';
  bool loading = false;

  @override
  void initState() {
    super.initState();
    getLocation();
  }

  getLocation() async {
    setState(() {
      loading = true;
    });

    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();

    if (!serviceEnabled) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('layanan lokasi ter-disable')));
    }

    LocationPermission permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('permintaan lokasi tidak diizinkan')));
      } else if (permission == LocationPermission.deniedForever) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content:
                Text('permintaan lokasi tidak diizinkan secara permanen')));
      }
    }

    Position result = await Geolocator.getCurrentPosition();
    var placemarks =
        await placemarkFromCoordinates(result.latitude, result.longitude);
    var address = placemarks[0];

    setState(() {
      lokasi = result;
      loading = false;
      alamat =
          '${address.street}, ${address.subLocality}, ${address.locality}, ${address.subAdministrativeArea}';
    });
  }

  logout() {
    FirebaseAuth.instance.signOut();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Berhasil logout!')),
    );
    Navigator.of(context)
        .pushReplacement(MaterialPageRoute(builder: (ctx) => loginScreen()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Home'),
        leading: Text(''),
        leadingWidth: 10,
        actions: [
          IconButton(
            onPressed: () {
              showDialog(
                context: context,
                builder: (ctx) {
                  return AlertDialog(
                    content: Text('Apakah anda yakin akan logout?'),
                    actions: [
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        child: Text('BATAL'),
                      ),
                      TextButton(onPressed: logout, child: Text('LOGOUT')),
                    ],
                  );
                },
              );
            },
            icon: Icon(Icons.logout),
          ),
        ],
      ),
      body: Container(
        padding: EdgeInsets.all(20),
        child: Card(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  'Koordinat Point',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 24,
                  ),
                ),
                Text(loading
                    ? 'Memuat...'
                    : '${lokasi.latitude},${lokasi.longitude}'),
                Container(height: 20),
                Text(
                  'Address',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 24,
                  ),
                ),
                Text(
                  loading ? 'Memuat...' : alamat,
                  textAlign: TextAlign.center,
                ),
                Container(height: 20),
                ElevatedButton(
                  onPressed: () async {
                    var intent = AndroidIntent(
                      action: 'action_view',
                      // data: Uri.encodeFull('https://www.google.com/maps/search/$alamat'),
                      data: Uri.encodeFull('https://www.google.com/maps'),
                    );
                    await intent.launch();
                  },
                  child: Text(
                    'Tampilkan Map',
                    style: TextStyle(
                      color: Colors.white,
                    ),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: getLocation,
        child: Icon(
          Icons.search,
        ),
      ),
    );
  }
}
