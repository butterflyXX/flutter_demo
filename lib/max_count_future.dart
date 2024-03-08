import 'dart:async';

import 'package:flutter/foundation.dart';

typedef FutureCallback = Future Function(int index);
class AsyncCountFuture {
  static Future wait(List<Future Function()> list,
      {int maxAsyncCount = 10}) async {
    if (list.isEmpty) return;

    ValueNotifier doingCount = ValueNotifier(0);
    Completer completer = Completer();

    doTask(Future Function() task) async {
      list.remove(task);
      await task();
      doingCount.value--;
    }

    doingCount.addListener(() {
      if (doingCount.value < maxAsyncCount && list.isNotEmpty) {
        doTask(list.first);
        doingCount.value++;
      } else if (doingCount.value == 0) {
        completer.complete();
      }
    });

    doTask(list.first);
    doingCount.value++;

    await completer.future;
  }

  static Future waitBuilder({
    required int itemCount,
    required FutureCallback itemBuilder,
    int maxAsyncCount = 10,
  }) async {
    if (itemCount == 0) return;

    ValueNotifier doingCount = ValueNotifier(0);
    int nextIndex = 0;
    Completer completer = Completer();

    doTask(int index) async {
      nextIndex++;
      await itemBuilder(index);
      doingCount.value--;
    }

    doingCount.addListener(() {
      if (doingCount.value < maxAsyncCount && nextIndex < itemCount) {
        doTask(nextIndex);
        doingCount.value++;
      } else if (doingCount.value == 0) {
        completer.complete();
      }
    });

    doTask(nextIndex);
    doingCount.value++;

    await completer.future;
  }
}