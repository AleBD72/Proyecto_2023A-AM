//import 'package:cloud_firestore/cloud_firestore.dart';
//import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:login_app_proyecto/screens/signin_screen.dart';

import '../utils/color_utils.dart';

import 'dart:async';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  Completer<GoogleMapController> _googleMapController = Completer();
  CameraPosition? _cameraPosition;
  Location? _location;
  LocationData? _currentLocation;
  Timer? _locationTimer; // Timer para actualizar la ubicación cada 5 segundos
  
// Función para actualizar la ubicación
  void _updateLocation() {
    _location?.getLocation().then((location) {
      setState(() {
        _currentLocation = location;
      });
      moveToPosition(LatLng(_currentLocation?.latitude ?? 0, _currentLocation?.longitude ?? 0));
      // Guarda la ubicación en Firebase
      //guardarUbicacion(_currentLocation);
    });
  }

 // Función para guardar la ubicación en Firebase
  /*void guardarUbicacion(LocationData? locationData) {
    
    try {
      User? user = FirebaseAuth.instance.currentUser;

      if (user != null && locationData != null) {
        CollectionReference ubicacionesCollection = 
          FirebaseFirestore.instance.collection('ubicaciones');
        
        //Obtenemos el documento existente del usuario
        DocumentReference userDocument = ubicacionesCollection.doc(user.uid);

        DateTime horaActual = DateTime.now();
        double? longitud = locationData.longitude;
        double? latitud = locationData.latitude;

        //Verificamos si existe un documento con la ubicación
        userDocument.get().then((documentSnapshot){
          if(documentSnapshot.exists){
            //Actualización unicamente si el documento existe
            userDocument.update({
              'latitud': latitud.toString(),
              'longitud': longitud.toString(),
              'hora': horaActual,
            }).then((_) {
              print('Ubicación actualizada con éxito');
            }).catchError((error){
              print('Error al actualizar la ubicación: $error');
            });
          }else{
            //Acciones cuando el documento no existe
            //Guardado de información por primera vez
            userDocument.set({
              'usuarioId': user.uid,
              'latitud': latitud.toString(),
              'longitud': longitud.toString(),
              'hora': horaActual,
            }).then((_){
              print('Ubicación guardada con éxito por primera vez');
            }).catchError((error){
              print('Error al guardar la ubicación por primera vez: $error');
            });
          }
        }).catchError((error){
          print('Error al verificar la existencia del documento: $error');
        });
        //
      } else {
        print('No hay usuario autenticado o datos de ubicación nulos');
      }
    } catch (error) {
      print('Error al guardar la ubicación: $error');
    }
  }*/



  @override
  void initState() {
    _init();
    super.initState();
    _locationTimer = Timer.periodic(Duration(seconds: 5), (_) {
      _updateLocation();
    });
  }

  @override
  void dispose() {
    // Cancela el timer cuando el widget se desmonta
    _locationTimer?.cancel();
    super.dispose();
  }

  _init() async {
    _location = Location();
    _cameraPosition = CameraPosition(
      target: LatLng(-0.204742, -78.485126),
      zoom: 18
    );
    _initLocation();
  }

  //función para saber cuando nos movemos o cambia la ubicación
  _initLocation(){
    _location?.getLocation().then((location){
      _currentLocation = location;
    });
    _location?.onLocationChanged.listen((newLocation) {
      _currentLocation = newLocation;
      moveToPosition(LatLng(_currentLocation?.latitude ?? 0, _currentLocation?.longitude ?? 0));
     });
  }
  
  //Funcion que mueve el mapa a una nueva posición y centra en él
  Future<LocationData?> getCurrentLocation() async{
    //    Location().getLocation().then((value) async{
      var currentLocation = await _location?.getLocation();
      return currentLocation; //?? null;
  }

  moveToPosition (LatLng latLng) async{
    GoogleMapController mapController = await _googleMapController.future;
    mapController.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(
          target: latLng,
          zoom: 18
        )
      )
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: hexStringToColor("A91079"),
        title: Text("Home Screen"),
        actions: [
          IconButton(
            icon: Icon(Icons.exit_to_app),
            onPressed: () {
              FirebaseAuth.instance.signOut().then((value) {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => SingInScreen()),
                );
              });
            },
          ),
        ],
      ),
      body: _buildAppBody(),
    );
  }

  Widget _buildAppBody(){
    return _getMap();
  }

  Widget _getMark(){
    return Container(
      width: 30,
      height: 30,
      decoration: BoxDecoration(
        color: Colors.purple,
        borderRadius: BorderRadius.circular(100),
        boxShadow: const [
          BoxShadow(
            color: Colors.grey,
            offset: Offset(0,3),
            spreadRadius: 4,
            blurRadius: 6
          )
        ]
      ),
    );
  }

  Widget _getMap(){
    return Stack(
      children: [
        GoogleMap(
          initialCameraPosition: _cameraPosition!,
          mapType: MapType.normal,
          onMapCreated: (GoogleMapController controller){
            if(!_googleMapController.isCompleted){
              _googleMapController.complete(controller);
            }
          },
        ),

        Positioned.fill(
          child: Align(
            alignment: Alignment.center,
            child:_getMark()
          )
        )
      ],
    );
    
  }
}