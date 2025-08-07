class SubjectAttendance {
  String subject;
  int present;
  int bunked;
  double requiredPercentage;

  SubjectAttendance({
    required this.subject,
    this.present = 0,
    this.bunked = 0,
    double? requiredPercentage,
  }) : // Use provided requiredPercentage if it's valid (>0), otherwise default to 75.0
       requiredPercentage =
           (requiredPercentage != null && requiredPercentage > 0)
           ? requiredPercentage
           : 75.0;

  factory SubjectAttendance.fromJson(Map<String, dynamic> json) {
    return SubjectAttendance(
      subject: json['subject'],
      present: json['present'] ?? 0,
      bunked: json['bunked'] ?? 0,
      requiredPercentage:
          (json['requiredPercentage'] as num?)?.toDouble() ?? 75.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'subject': subject,
      'present': present,
      'bunked': bunked,
      'requiredPercentage': requiredPercentage,
    };
  }
}
