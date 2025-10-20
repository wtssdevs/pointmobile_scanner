import 'package:flutter/material.dart';

enum LoadingStockpileType {
  loadingSlip(
    0,
    "LoadingSlip",
  ),
  stockPile(
    1,
    "StockPile",
  );

  // can use named parameters if you want
  const LoadingStockpileType(
    this.value,
    this.displayName,
  );
  final int value;
  final String displayName;
}

extension LoadingStockpileTypeExtension on LoadingStockpileType {
  LoadingStockpileType mapToEnum(int jsonEnumValue) {
    for (var item in LoadingStockpileType.values) {
      if (item.value == jsonEnumValue) {
        return item;
      }
    }

    return LoadingStockpileType.loadingSlip;
  }
}
