/// Room data model for allocation and capacity monitoring.
class RoomModel {
  final String id;
  final String roomNumber;
  final int floor;
  final int capacity;
  final int occupied;
  final List<String> studentIds;
  final List<String> studentNames;
  final String? notes;

  const RoomModel({
    required this.id,
    required this.roomNumber,
    this.floor = 1,
    required this.capacity,
    required this.occupied,
    this.studentIds = const [],
    this.studentNames = const [],
    this.notes,
  });

  int get availableBeds => (capacity - occupied).clamp(0, capacity);
  bool get isFull => occupied >= capacity;
  bool get isEmpty => occupied == 0;

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'roomNumber': roomNumber,
      'floor': floor,
      'capacity': capacity,
      'occupied': occupied,
      'studentIds': studentIds,
      'studentNames': studentNames,
      'notes': notes,
    };
  }

  factory RoomModel.fromMap(Map<String, dynamic> map, String id) {
    return RoomModel(
      id: id,
      roomNumber: map['roomNumber'] ?? '',
      floor: map['floor'] ?? 1,
      capacity: map['capacity'] ?? 3,
      occupied: map['occupied'] ?? 0,
      studentIds: List<String>.from(map['studentIds'] ?? []),
      studentNames: List<String>.from(map['studentNames'] ?? []),
      notes: map['notes'],
    );
  }
}
