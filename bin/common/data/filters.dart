 import 'dart:convert';
import 'dart:core';

import 'package:io/ansi.dart';

import '../thing_manager.dart';
import '../util/string_utils.dart';
import 'users.dart';
import 'thing.dart';
import 'property.dart';

class AbstractFilter<T> extends Named implements JsonEncodable{
  static AbstractFilter errorFilter = AbstractFilter("error", AbstractProperty.errorDataType);

  static Map<String, Function(String, AbstractProperty, Map<String, dynamic>)> parseFilterMap = <String, Function(String, AbstractProperty, Map<String, dynamic>)>{
    "single_value" : SingleValueFilter.parseFilterType,
    "multi_value" : MultipleValueFilter.parseFilterType,
    "number_range" : NumberRangeFilter.parseFilterType
  };

  AbstractProperty<T> property;
  String id;

  OriginState state = OriginState.user;

  AbstractFilter(this.id, this.property);

  bool shouldApplyFilter(AbstractProperty<T> valuesDataType) {
    return property == valuesDataType;
  }

  bool test(T value){
    return true;
  }

  @override
  String toString() {
    return "id: $id, dataType: ${property.toString()}";
  }

  @override
  String getName() {
    return id;
  }

  @override
  List<StringAnsiHelper> getExtraFormattedData({bool debugInfo = false, int leftPadding = 0}) {
    return [StringAnsiHelper.ofArrow("[Data Type: ${property.getFormattedName()}] ${property.getExtraFormattedData(debugInfo: debugInfo)}")];
  }

  Map<String, String> getExtraStringData(){
    return {"Data Type" : property.getFormattedName()};
  }

  @override
  void encodeDataJson(Map<String, dynamic> jsonDataMap){
    jsonDataMap[id] = {
      "data_type" : property.id
    };
  }
}

class SingleValueFilter<T> extends AbstractFilter<T> {

  T filterValue;

  SingleValueFilter(String id, AbstractProperty<T> dataType, this.filterValue) : super(id, dataType);

  @override
  bool test(dynamic value) {
    return filterValue == value;
  }

  static AbstractFilter parseFilterType(String id, AbstractProperty dataType, Map<String, dynamic> filterData){
    if(filterData.containsKey("value")) {
      return SingleValueFilter(id, dataType, filterData["value"]);
    } else {
      TextLogger.errorOutput("A filter was missing the needed data to generate correctly, such will be skipped by Manager! [Filter: $id]");

      return AbstractFilter.errorFilter;
    }
  }

  @override
  void encodeDataJson(Map<String, dynamic> jsonDataMap){
    jsonDataMap[id] = {
      "filter_type" : "single_value",
      "data_type" : property.id,
      "value" : filterValue
    };
  }

  @override
  String toString() {
    return "filterType: SingleValue, value: $filterValue, " + super.toString();
  }

  @override
  List<StringAnsiHelper> getExtraFormattedData({bool debugInfo = false, int leftPadding = 0}) {
    return [StringAnsiHelper.ofArrow(
        wrapWith("SingleValue: ", [white])! +
        wrapWith("[", [lightBlue])! +
        wrapWith("Data Type: ", [white])! +
        wrapWith(property.getFormattedName(), [lightYellow])! +
        wrapWith(", ", [lightBlue])! +
        wrapWith("Filter Value: ", [white])! +
        wrapWith(property.getFormattedValue(filterValue), [lightYellow])! +
        wrapWith("]", [lightBlue])!,
        [[white], [lightBlue], [white], [lightYellow], [lightBlue], [white], [lightYellow], [lightBlue]]
    )];
  }

  @override
  Map<String, String> getExtraStringData(){
    return {"${property.getFormattedName()}" : property.getFormattedValue(filterValue)};
  }
}

class MultipleValueFilter<T> extends AbstractFilter<T> {
  List<T> filterValues;

  MultipleValueFilter(String id, AbstractProperty<T> dataType, this.filterValues) : super(id, dataType);

  @override
  bool test(dynamic value) {
    return filterValues.contains(value);
  }

  static AbstractFilter parseFilterType(String id, AbstractProperty dataType, Map<String, dynamic> filterData){
    if(filterData.containsKey("values")) {
      return MultipleValueFilter(id, dataType, filterData["values"]);
    } else {
      TextLogger.errorOutput("A filter was missing the needed data to generate correctly, such will be skipped by Manager! [Filter: $id]");

      return AbstractFilter.errorFilter;
    }
  }

  @override
  void encodeDataJson(Map<String, dynamic> jsonDataMap){
    jsonDataMap[id] = {
      "filter_type" : "single_value",
      "data_type" : property.id,
      "values" : filterValues
    };
  }

  @override
  String toString() {
    return "${super.toString()}, filterType: MultiValue, values: $filterValues";
  }

  @override
  List<StringAnsiHelper> getExtraFormattedData({bool debugInfo = false, int leftPadding = 0}) {
    return [StringAnsiHelper.ofArrow(
        wrapWith(" MultiValue: ", [white])! +
        wrapWith("[", [lightBlue])! +
        wrapWith("Data Type: ", [white])! +
        wrapWith(property.getFormattedName(), [lightYellow])! +
        wrapWith(", ", [lightBlue])! +
        wrapWith("Filter Values: ", [white])! +
        wrapWith(filterValues.map((value) => property.getFormattedValue(value)).toString(), [lightYellow])! +
        wrapWith("]", [lightBlue])!,
        [[white], [lightBlue], [white], [lightYellow], [lightBlue], [white], [lightYellow], [lightBlue]]
    )];
  }

  @override
  Map<String, String> getExtraStringData(){
    return {"${property.getFormattedName()}" : "${filterValues.map((value) => property.getFormattedValue(value))}"};
  }
}

class NumberRangeFilter<T extends num> extends AbstractFilter<T> implements JsonEncodable{
  T min;
  T max;

  NumberRangeFilter(String id, AbstractProperty<T> dataType, this.min, this.max) : super(id, dataType);

  @override
  bool test(T value){
    return value >= min && value <= max;
  }

  static AbstractFilter parseFilterType(String id, AbstractProperty dataType, Map<String, dynamic> filterData){
    if(dataType is NumberProperty) {
      Map<String, dynamic> rangeData = filterData["range"];

      num min = rangeData["min"] ?? dataType.min;
      num max = rangeData["max"] ?? dataType.max;

      if(!(min == dataType.min && max == dataType.max)){
        return NumberRangeFilter(id, dataType, min, max);
      } else {
        TextLogger.errorOutput("A filter was missing the needed data to generate correctly, such will be skipped by Manager! [Filter: $id]");
      }
    } else {
      TextLogger.errorOutput("A Number Range Filter has a dataType that doesn't allow for number comparison, such will be skipped by Manager! [Filter: $id]");
    }

    //Only errors if it doesn't pass the need checks

    return AbstractFilter.errorFilter;
  }

  @override
  void encodeDataJson(Map<String, dynamic> jsonDataMap){
    jsonDataMap[id] = {
      "filter_type" : "single_value",
      "data_type" : property.id,
      "range" : {
        "min" : min,
        "max" : max
      }
    };
  }

  @override
  String toString() {
    return "${super.toString()}, filterType: NumberRange, range: [$min, $max]";
  }

  @override
  List<StringAnsiHelper> getExtraFormattedData({bool debugInfo = false, int leftPadding = 0}) {
    return [StringAnsiHelper.ofArrow(
        wrapWith("NumberRange: ", [white])! +
            wrapWith("[", [lightBlue])! +
            wrapWith("Data Type", [white])! +
            wrapWith(": ", [lightBlue])! +
            wrapWith(property.getFormattedName(), [lightYellow])! +
            wrapWith(" / ", [lightBlue])! +
            wrapWith("Range", [white])! +
            wrapWith(": ", [lightBlue])! +
            wrapWith("($min, $max)", [lightYellow])! +
            wrapWith("]", [lightBlue])!,
        [[white], [lightBlue], [white], [lightBlue], [lightYellow], [lightBlue], [white], [lightBlue], [lightYellow], [lightBlue]]
    )];
  }

  @override
  Map<String, String> getExtraStringData(){
    return {"${property.getFormattedName()}: " : "$min - $max"};
  }
}

enum OriginState {
  internal,
  user,
  unsaved
}

class Preset extends Named implements JsonEncodable{

  static String unsavedPreset = "custom_unsaved";

  String id;

  OriginState state = OriginState.user;

  List<AbstractFilter> activeFilters = <AbstractFilter>[];

  Preset(this.id, this.activeFilters);

  List<Thing> filterCharacters(List<Thing> characters){
    List<Thing> filteredList = <Thing>[];

    for(Thing character in characters){
      bool addToFilteredList = false;

      for(AbstractFilter filter in activeFilters){
        if(character.properties.containsKey(filter.property) && filter.test(character.properties[filter.property])){
          addToFilteredList = true;

          break;
        }
      }

      if(addToFilteredList){
        filteredList.add(character);
      }
    }

    return filteredList;
  }

  static Preset parsePreset(String id, List<dynamic> filterIDs, ThingManager manager, User? user){
    List<AbstractFilter> availableFilters = manager.getAllFilters(user);

    List<AbstractFilter> presetFilters = [];

    for(String filterID in filterIDs) {
      AbstractFilter filter = availableFilters.firstWhere((element) => element.id == filterID, orElse: () => AbstractFilter.errorFilter);

      if(filter != AbstractFilter.errorFilter) {
        presetFilters.add(filter);
      } else {
        TextLogger.errorOutput("A filter within a Preset seems to not exist, such filter is not loaded within the preset! [Preset: $id, FilterID: $filterID]");
      }
    }

    return Preset(id, presetFilters);
  }

  Preset copyFilters([List<AbstractFilter>? filters]){
    return Preset(unsavedPreset, (filters ?? [])..addAll(activeFilters));
  }


  @override
  void encodeDataJson(Map<String, dynamic> jsonDataMap){
    jsonDataMap[id] = {
      "filters" : activeFilters.map((filter) => filter.id).toList()
    };
  }

  Map<String, String> getExtraStringData(){
    return {"Filters" : "${activeFilters.map((filter) => filter.getFormattedName())}"};
  }

  @override
  List<StringAnsiHelper> getExtraFormattedData({bool debugInfo = false, int leftPadding = 0}) {
    return [StringAnsiHelper.ofArrow(
        wrapWith("[", [lightBlue])! +
        wrapWith("Filters: ", [white])! +
        wrapWith("${(debugInfo ? activeFilters.map((value) => value.getName()) : activeFilters.map((value) => value.getFormattedName()))}", [lightYellow])! +
        wrapWith("]", [lightBlue])!,
        [[lightBlue], [white], [lightYellow], [lightBlue]]
    )];
  }

  @override
  String getName() {
    return id;
  }

}

abstract class JsonEncodable {
  static const JsonEncoder fancyEncoder = JsonEncoder.withIndent('  ');

  void encodeDataJson(Map<String, dynamic> jsonDataMap);

  static Map<String, dynamic> encodeList(List<JsonEncodable> encodableList){
    Map<String, dynamic> jsonData = {};

    for(JsonEncodable encodable in encodableList){
      encodable.encodeDataJson(jsonData);
    }

    return jsonData;
  }

  static String encodeJsonFancy(Map<String, dynamic> jsonData){
    return fancyEncoder.convert(jsonData);
  }

  static String encodeJsonFancyFromList(List<JsonEncodable> encodableList){
    return fancyEncoder.convert(encodeList(encodableList));
  }
}