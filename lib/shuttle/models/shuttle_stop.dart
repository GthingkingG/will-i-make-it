import 'package:equatable/equatable.dart';

class ShuttleStop extends Equatable {
  const ShuttleStop({
    required this.id,
    required this.name,
    required this.latitude,
    required this.longitude,
  });

  final String id;
  final String name;
  final double latitude;
  final double longitude;

  @override
  List<Object?> get props => [id, name, latitude, longitude];
}
