import 'package:flutter/material.dart';

enum StockpileActions {
  atStockPile(0, 1, "At Stock Pile", "AtStockPile", Icon(Icons.warehouse), Colors.amber),
  leftStockPile(1, 512, "Left Stock Pile", "LeftStockPile", Icon(Icons.local_shipping), Colors.green);

  // can use named parameters if you want
  const StockpileActions(this.value, this.gatePassEventActionValue, this.displayName, this.visitorName, this.icon, this.color);
  final int value;
  final int gatePassEventActionValue;
  final String displayName;
  final String visitorName;
  final Icon icon;
  final Color color;
}

extension StockpileActionsExtension on StockpileActions {
  StockpileActions mapToEnum(int jsonEnumValue) {
    for (var item in StockpileActions.values) {
      if (item.value == jsonEnumValue) {
        return item;
      }
    }

    return StockpileActions.atStockPile;
  }
}

//C# enum class example
// public enum GatePassEventAction
// {
//     Pending,//Created
//     Arrived =1,//1
//     AuthorizeEntry =2,
//     Loading =4,
//     Unloading =8,
//     RejectedEntry=16,
//     AuthorizeExit=32,
//     InternalMovement = 64,
//     Transfer = 128,
//     RejectedExit = 256,
//     Depart = 512,

   




// }