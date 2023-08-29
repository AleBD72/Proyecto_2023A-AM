import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:geolocator/geolocator.dart';
//import 'package:flutter/material.dart';

part 'gps_event.dart';
part 'gps_state.dart';

class GpsBloc extends Bloc<GpsEvent, GpsState> {

  StreamSubscription? gpsServiceSusription;

  GpsBloc() : super(const GpsState(isGpsEnable: false, isGpsPermisionGrated: false)) {

    on<GpsAndPermissionEvent>((event, emit) => emit(state.copywith(
      isGpsEnable: event.isGpsEnable,
      isGpsPermisionGrated: event.isGpsPermisionGrated
      ))
    );

    _init();
  }
  
  Future<void> _init() async {
    final isEnable = await _checkGpsStatus();
    //print('isEnable: $isEnable');

    add(GpsAndPermissionEvent(
      isGpsEnable: isEnable, 
      isGpsPermisionGrated: state.isGpsPermisionGrated,
    ));
  }

  Future<bool> _checkGpsStatus() async{
    final isEnable = await Geolocator.isLocationServiceEnabled();
    
    gpsServiceSusription= Geolocator.getServiceStatusStream().listen((event) {
      //final isEnabled = (event.index == 1) ? true : false;
      add(GpsAndPermissionEvent(
        isGpsEnable: isEnable, 
        isGpsPermisionGrated: state.isGpsPermisionGrated,
      ));
    });
    
    return isEnable;
  }

  @override
  Future<void>close(){
    gpsServiceSusription?.cancel();
    return super.close();
  }
}
