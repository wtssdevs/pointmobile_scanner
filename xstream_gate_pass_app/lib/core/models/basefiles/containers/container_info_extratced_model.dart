class ContainerInfo {
  final String containerNumber;
  final String isoType;
  final String isoTypeDescription; // New field
  final String fullText;

  ContainerInfo(
      {required this.containerNumber,
      required this.isoType,
      this.isoTypeDescription = '',
      this.fullText = ''});

  @override
  String toString() =>
      'Container: $containerNumber, ISO Type: $isoType ($isoTypeDescription)';
}
