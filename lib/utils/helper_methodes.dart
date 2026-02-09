import 'package:flutter/material.dart';

void printRed(String msg) {
  const red = '\x1B[31m';
  const reset = '\x1B[0m';
  debugPrint('$red$msg$reset');
}

void printGreen(String msg) {
  const green = '\x1B[32m';
  const reset = '\x1B[0m';
  debugPrint('$green$msg$reset');
}

void printBlue(String msg) {
  const blue = '\x1B[34m';
  const reset = '\x1B[0m';
  debugPrint('$blue$msg$reset');
}
