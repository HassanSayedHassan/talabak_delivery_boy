class DeliveryTimeTableModel {
  final String status;
  final String dboyname;
  final String dboyid;
  final String sat_st;
  final String sat_end;
  final String sun_st;
  final String sun_end;
  final String mon_st;
  final String mon_end;
  final String tue_st;
  final String tue_end;
  final String wen_st;
  final String wen_end;
  final String thu_st;
  final String thu_end;
  final String fri_st;
  final String fri_end;

  DeliveryTimeTableModel(
      {this.status,
      this.dboyname,
      this.dboyid,
      this.sat_st,
      this.sat_end,
      this.sun_st,
      this.sun_end,
      this.mon_st,
      this.mon_end,
      this.tue_st,
      this.tue_end,
      this.wen_st,
      this.wen_end,
      this.thu_st,
      this.thu_end,
      this.fri_st,
      this.fri_end});
  factory DeliveryTimeTableModel.fromJson(Map<String, dynamic> json) {
    return DeliveryTimeTableModel(
        status: json['status'],
        dboyname: json['dboyname'],
        dboyid: json['dboyid'],
        sat_st: json['sat_st'],
        sat_end: json['sat_end'],
        sun_st: json['sun_st'],
        sun_end: json['sun_end'],
        mon_st: json['mon_st'],
        mon_end: json['mon_end'],
        tue_st: json['tue_st'],
        tue_end: json['tue_end'],
        wen_st: json['wen_st'],
        wen_end: json['wen_end'],
        thu_st: json['thu_st'],
        thu_end: json['thu_end'],
        fri_st: json['fri_st'],
        fri_end: json['fri_end']);
  }
}
