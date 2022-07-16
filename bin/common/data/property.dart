import 'dart:math';

import 'package:basic_utils/basic_utils.dart';

import '../util/string_utils.dart';

class AbstractProperty<T> extends Named {
  static AbstractProperty errorDataType = AbstractProperty("error", String);

  static Map<String, Function(String, Map<String, dynamic>)> parseDataTypeMap = {
    "String" : StringProperty.parseProperty,
    "boolean" : BooleanProperty.parseProperty,
    "int" : NumberProperty.parseIntProperty,
    "double" : NumberProperty.parseDoubleProperty
  };

  Map<T, String> stringOverrides = <T, String>{};

  String id;
  Type type;

  AbstractProperty(this.id, this.type);

  void parseStringOverrides(Map<String, dynamic> dataTypeJson){
    if(dataTypeJson.containsKey("overrides")) {
      for (MapEntry<String, dynamic> entry in (dataTypeJson["overrides"] as Map<String, dynamic>).entries) {
        evaluateLength(entry.key.toString());

        stringOverrides[entry.value] = entry.key;
      }
    }
  }

  //--------------------------------

  @override
  String getName() {
    return id;
  }

  @override
  List<StringAnsiHelper> getExtraFormattedData({bool debugInfo = false, int leftPadding = 0}) {
    return [StringAnsiHelper.ofArrow("[ValueType: ${type.toString()}]")];
  }

  @override
  String toString() {
    return "$id, ValueType = $type";
  }

  String getFormattedValue(T value){
    return stringOverrides[value] ?? value.toString();
  }

  //--------------------------------

  int getMaxStringLength() {
    return 0;
  }

  void setMaxStringLength(int maxLength){}

  void evaluateLength(String value) {
    setMaxStringLength(max(value.length, getMaxStringLength()));
  }
}

class StringProperty extends AbstractProperty<String> {

  static int maxStringLength = 0;

  StringProperty(String dataTypeName) : super(dataTypeName, String);

  static AbstractProperty parseProperty(String id, Map<String, dynamic> dataTypeInfo) {
    return StringProperty(id)..parseStringOverrides(dataTypeInfo);
  }

  //--------------------------------

  @override
  String getFormattedValue(String value){
    return StringUtils.capitalize(super.getFormattedValue(value), allWords: true);
  }

  //--------------------------------

  @override
  int getMaxStringLength() {
    return maxStringLength;
  }

  @override
  void setMaxStringLength(int value) {
    maxStringLength = value;
  }
}

class BooleanProperty extends AbstractProperty<bool> {

  static int maxStringLength = 0;

  BooleanProperty(String dataTypeName) : super(dataTypeName, String);

  static AbstractProperty parseProperty(String id, Map<String, dynamic> dataTypeInfo) {
    return BooleanProperty(id)..parseStringOverrides(dataTypeInfo);
  }

  //--------------------------------

  @override
  int getMaxStringLength() {
    return maxStringLength;
  }

  @override
  void setMaxStringLength(int value) {
    maxStringLength = value;
  }
}

/// The smallest possible value of an int as double-precision floating-point to support java script
const int minInt = -9007199254740991;

/// The biggest possible value of an int as double-precision floating-point to support java script
const int maxInt =  9007199254740991;

class NumberProperty<T extends num> extends AbstractProperty<T> {
  static int maxStringLength = 0;

  num min = 0;
  num max = 0;

  NumberProperty(String name, Type type, num? min, num? max) : super(name, type) {
    if(type == int){
      this.min = min ?? minInt;
      this.max = max ?? maxInt;
    } else {
      this.min = min ?? double.minPositive;
      this.max = max ?? double.maxFinite;
    }
  }

  static AbstractProperty parseIntProperty(String id, Map<String, dynamic> dataTypeInfo){
    return parseProperty(id, int, dataTypeInfo);
  }

  static AbstractProperty parseDoubleProperty(String id, Map<String, dynamic> dataTypeInfo){
    return parseProperty(id, double, dataTypeInfo);
  }

  static AbstractProperty parseProperty(String id, Type type, Map<String, dynamic> dataTypeInfo) {
    Map<String, dynamic> rangeMap = dataTypeInfo["range"];

    num? min = rangeMap["min"];
    num? max = rangeMap["max"];

    if(!rangeMap.containsKey("min") && !rangeMap.containsKey("max")) {
      TextLogger.warningOutput("A range was defined in a IntegerProperty but no min or max value was found! [NumProperty: $id]");
    }

    return NumberProperty(id, type, min, max)..parseStringOverrides(dataTypeInfo);
  }

  //--------------------------------

  @override
  String toString() {
    // TODO: implement toString
    return "${super.toString()}, Range: [$min, $max]";
  }

  //--------------------------------

  bool validStringNum(String valueAsString){
    try {
      T value;

      if (type == int) {
        value = int.parse(valueAsString) as T;
      } else {
        value = double.parse(valueAsString) as T;
      }

      if (value >= min && value <= max) {
        return true;
      } else {
        return false;
      }
    } on FormatException catch(e){
      return false;
    }
  }

  @override
  int getMaxStringLength() {
    return maxStringLength;
  }

  @override
  void setMaxStringLength(int value) {
    maxStringLength = value;
  }
}