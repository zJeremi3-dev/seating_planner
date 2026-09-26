/// A fixed-seat rule for one student.
///
/// A student can be pinned to one or more specific seats
/// ([allowedSeats], as {tableId, seatIndex} pairs) or to one or more whole
/// rows of desks ([allowedRowIds]). The randomizer then only places that
/// student on one of the allowed options.
///
/// Both lists empty means "no restriction" - the student can end up anywhere.
class FixedSeat {
  String studentName;
  List<Map<String, dynamic>> allowedSeats;
  List<String> allowedRowIds;

  FixedSeat({
    required this.studentName,
    List<Map<String, dynamic>>? allowedSeats,
    List<String>? allowedRowIds,
  }) : allowedSeats = allowedSeats ?? [],
       allowedRowIds = allowedRowIds ?? [];

  bool get hasFixedSeat => allowedSeats.isNotEmpty || allowedRowIds.isNotEmpty;

  void clear() {
    allowedSeats = [];
    allowedRowIds = [];
  }

  Map<String, dynamic> toJson() => {
    'studentName': studentName,
    'allowedSeats': allowedSeats,
    'allowedRowIds': allowedRowIds,
  };

  factory FixedSeat.fromJson(Map<String, dynamic> json) {
    return FixedSeat(
      studentName: json['studentName'] as String,
      allowedSeats: json['allowedSeats'] != null
          ? List<Map<String, dynamic>>.from(
              (json['allowedSeats'] as List).map(
                (e) => Map<String, dynamic>.from(e as Map),
              ),
            )
          : [],
      allowedRowIds: json['allowedRowIds'] != null
          ? List<String>.from(json['allowedRowIds'] as List)
          : [],
    );
  }
}
