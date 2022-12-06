enum FileStoreType {
  image(0),
  customerSignature(1),
  documentScan(2);

  // can add more properties or getters/methods if needed
  final int value;

  // can use named parameters if you want
  const FileStoreType(this.value);
}
