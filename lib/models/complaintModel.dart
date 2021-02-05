class ComplaintModel {
  final String id;
  final String content;
  final String sender;
  final String def;
  final String title;
  final String date;

  final String oederID;
  final String status;

  ComplaintModel(
      {this.id,
      this.content,
      this.def,
      this.oederID,
      this.sender,
      this.title,
      this.status,
      this.date});

  factory ComplaintModel.fromJson(Map<String, dynamic> json) {
    return ComplaintModel(
        id: json['id'],
        content: json['content'],
        def: json['def'],
        oederID: json['oederID'],
        sender: json['sender'],
        title: json['title'],
        date: json['date'],
        status: json['status']);
  }
}
