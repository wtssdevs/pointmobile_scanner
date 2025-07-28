class CheckListResolveTypeOutput {
  final String? checklistType;
  final String? deliveryType;

  CheckListResolveTypeOutput({this.checklistType, this.deliveryType});

factory CheckListResolveTypeOutput.fromJson(Map<String, dynamic> json) {
  return CheckListResolveTypeOutput(
    checklistType: json['checklistType'].toString(),
    deliveryType: json['deliveryType'].toString(),
  );
}

}
