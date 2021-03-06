import 'dart:async';

import 'package:flutter/material.dart';
import '../props/primitive_props.dart';

import '../stateful_props_manager.dart';

//TODO: Could add preserveValue functionality...
class FutureProp<T> extends StatefulProp<FutureProp<T>> {
  FutureProp({
    this.initial,
    this.initialData,
    this.preserveState = true,
    this.key,
  }) {}
  Future<T> initial;
  T initialData;
  bool preserveState;
  Key key;

  //Internal State
  AsyncSnapshot<T> _snapshot;
  ValueProp<Future<T>> futureValue; // Handles rebuilds when future changes

  @override
  void init() {
    _snapshot = AsyncSnapshot<T>.withData(ConnectionState.none, initialData);
    // Use a ValueProp to handle our 'did-change' check
    futureValue = addProp?.call(ValueProp(initial: initial));
  }

  @override
  void update(FutureProp<T> newProp) {
    key = newProp.key;
    initialData = newProp.initialData;
  }

  @override
  ChildBuilder getBuilder(ChildBuilder childBuilder) {
    return (_) => FutureBuilder<T>(
          key: key,
          initialData: initialData,
          future: futureValue.value,
          builder: (BuildContext context, AsyncSnapshot<T> snapshot) {
            //print("Build Future");
            _snapshot = snapshot;
            return childBuilder(context);
          },
        );
  }

  // Helper methods
  AsyncSnapshot<T> get snapshot => _snapshot;
  T get data => _snapshot?.data ?? null;
  bool get isWaiting => _snapshot?.connectionState == ConnectionState.waiting;

  Future<T> get value => futureValue?.value;
  set value(Future<T> value) {
    if (isWaiting) return;
    futureValue.value = value;
  }

  void replace(Future<T> value) {
    if (!preserveState) {
      _snapshot = AsyncSnapshot<T>.withData(ConnectionState.none, initialData);
    }
    futureValue.value = value;
  }
}
