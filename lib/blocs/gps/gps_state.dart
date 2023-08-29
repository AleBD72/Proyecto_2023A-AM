part of 'gps_bloc.dart';

class GpsState extends Equatable {
  
  final bool isGpsEnable;
  final bool isGpsPermisionGrated;

  const GpsState({
    required this.isGpsEnable,
    required this.isGpsPermisionGrated
  });

  GpsState copywith({
    bool? isGpsEnable,
    bool? isGpsPermisionGrated
  }) =>GpsState(
    isGpsEnable: isGpsEnable ?? this.isGpsEnable, 
    isGpsPermisionGrated: isGpsPermisionGrated ?? this.isGpsPermisionGrated
  );

  @override
  List<Object> get props => [ isGpsEnable, isGpsPermisionGrated ];
}

//final class GpsInitial extends GpsState {}
