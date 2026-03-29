// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'behavior_log.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetBehaviorLogCollection on Isar {
  IsarCollection<BehaviorLog> get behaviorLogs => this.collection();
}

const BehaviorLogSchema = CollectionSchema(
  name: r'BehaviorLog',
  id: 12345,
  properties: {
    r'action': PropertySchema(
      id: 0,
      name: r'action',
      type: IsarType.string,
    ),
    r'deviceId': PropertySchema(
      id: 1,
      name: r'deviceId',
      type: IsarType.string,
    ),
    r'illuminance': PropertySchema(
      id: 2,
      name: r'illuminance',
      type: IsarType.long,
    ),
    r'indoorTemp': PropertySchema(
      id: 3,
      name: r'indoorTemp',
      type: IsarType.double,
    ),
    r'isWeekend': PropertySchema(
      id: 4,
      name: r'isWeekend',
      type: IsarType.bool,
    ),
    r'outdoorTemp': PropertySchema(
      id: 5,
      name: r'outdoorTemp',
      type: IsarType.double,
    ),
    r'season': PropertySchema(
      id: 6,
      name: r'season',
      type: IsarType.string,
    ),
    r'timeOfDay': PropertySchema(
      id: 7,
      name: r'timeOfDay',
      type: IsarType.string,
    ),
    r'timestamp': PropertySchema(
      id: 8,
      name: r'timestamp',
      type: IsarType.dateTime,
    ),
    r'value': PropertySchema(
      id: 9,
      name: r'value',
      type: IsarType.string,
    )
  },
  estimateSize: _behaviorLogEstimateSize,
  serialize: _behaviorLogSerialize,
  deserialize: _behaviorLogDeserialize,
  deserializeProp: _behaviorLogDeserializeProp,
  idName: r'id',
  indexes: {
    r'timestamp': IndexSchema(
      id: 12346,
      name: r'timestamp',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'timestamp',
          type: IndexType.value,
          caseSensitive: false,
        )
      ],
    )
  },
  links: {},
  embeddedSchemas: {},
  getId: _behaviorLogGetId,
  getLinks: _behaviorLogGetLinks,
  attach: _behaviorLogAttach,
  version: '3.1.0+1',
);

int _behaviorLogEstimateSize(
  BehaviorLog object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.action.length * 3;
  bytesCount += 3 + object.deviceId.length * 3;
  {
    final value = object.season;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  bytesCount += 3 + object.timeOfDay.length * 3;
  {
    final value = object.value;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  return bytesCount;
}

void _behaviorLogSerialize(
  BehaviorLog object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeString(offsets[0], object.action);
  writer.writeString(offsets[1], object.deviceId);
  writer.writeLong(offsets[2], object.illuminance);
  writer.writeDouble(offsets[3], object.indoorTemp);
  writer.writeBool(offsets[4], object.isWeekend);
  writer.writeDouble(offsets[5], object.outdoorTemp);
  writer.writeString(offsets[6], object.season);
  writer.writeString(offsets[7], object.timeOfDay);
  writer.writeDateTime(offsets[8], object.timestamp);
  writer.writeString(offsets[9], object.value);
}

BehaviorLog _behaviorLogDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = BehaviorLog();
  object.action = reader.readString(offsets[0]);
  object.deviceId = reader.readString(offsets[1]);
  object.id = id;
  object.illuminance = reader.readLongOrNull(offsets[2]);
  object.indoorTemp = reader.readDoubleOrNull(offsets[3]);
  object.isWeekend = reader.readBool(offsets[4]);
  object.outdoorTemp = reader.readDoubleOrNull(offsets[5]);
  object.season = reader.readStringOrNull(offsets[6]);
  object.timeOfDay = reader.readString(offsets[7]);
  object.timestamp = reader.readDateTime(offsets[8]);
  object.value = reader.readStringOrNull(offsets[9]);
  return object;
}

P _behaviorLogDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readString(offset)) as P;
    case 1:
      return (reader.readString(offset)) as P;
    case 2:
      return (reader.readLongOrNull(offset)) as P;
    case 3:
      return (reader.readDoubleOrNull(offset)) as P;
    case 4:
      return (reader.readBool(offset)) as P;
    case 5:
      return (reader.readDoubleOrNull(offset)) as P;
    case 6:
      return (reader.readStringOrNull(offset)) as P;
    case 7:
      return (reader.readString(offset)) as P;
    case 8:
      return (reader.readDateTime(offset)) as P;
    case 9:
      return (reader.readStringOrNull(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _behaviorLogGetId(BehaviorLog object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _behaviorLogGetLinks(BehaviorLog object) {
  return [];
}

void _behaviorLogAttach(
    IsarCollection<dynamic> col, Id id, BehaviorLog object) {
  object.id = id;
}

extension BehaviorLogQueryWhereSort
    on QueryBuilder<BehaviorLog, BehaviorLog, QWhere> {
  QueryBuilder<BehaviorLog, BehaviorLog, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }

  QueryBuilder<BehaviorLog, BehaviorLog, QAfterWhere> anyTimestamp() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        const IndexWhereClause.any(indexName: r'timestamp'),
      );
    });
  }
}

extension BehaviorLogQueryWhere
    on QueryBuilder<BehaviorLog, BehaviorLog, QWhereClause> {
  QueryBuilder<BehaviorLog, BehaviorLog, QAfterWhereClause> idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<BehaviorLog, BehaviorLog, QAfterWhereClause> idNotEqualTo(
      Id id) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(
              IdWhereClause.lessThan(upper: id, includeUpper: false),
            )
            .addWhereClause(
              IdWhereClause.greaterThan(lower: id, includeLower: false),
            );
      } else {
        return query
            .addWhereClause(
              IdWhereClause.greaterThan(lower: id, includeLower: false),
            )
            .addWhereClause(
              IdWhereClause.lessThan(upper: id, includeUpper: false),
            );
      }
    });
  }

  QueryBuilder<BehaviorLog, BehaviorLog, QAfterWhereClause> idGreaterThan(Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<BehaviorLog, BehaviorLog, QAfterWhereClause> idLessThan(Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<BehaviorLog, BehaviorLog, QAfterWhereClause> idBetween(
    Id lowerId,
    Id upperId, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: lowerId,
        includeLower: includeLower,
        upper: upperId,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<BehaviorLog, BehaviorLog, QAfterWhereClause> timestampEqualTo(
      DateTime timestamp) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'timestamp',
        value: [timestamp],
      ));
    });
  }

  QueryBuilder<BehaviorLog, BehaviorLog, QAfterWhereClause> timestampNotEqualTo(
      DateTime timestamp) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'timestamp',
              lower: [],
              upper: [timestamp],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'timestamp',
              lower: [timestamp],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'timestamp',
              lower: [timestamp],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'timestamp',
              lower: [],
              upper: [timestamp],
              includeUpper: false,
            ));
      }
    });
  }

  QueryBuilder<BehaviorLog, BehaviorLog, QAfterWhereClause>
      timestampGreaterThan(
    DateTime timestamp, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'timestamp',
        lower: [timestamp],
        includeLower: include,
        upper: [],
      ));
    });
  }

  QueryBuilder<BehaviorLog, BehaviorLog, QAfterWhereClause> timestampLessThan(
    DateTime timestamp, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'timestamp',
        lower: [],
        upper: [timestamp],
        includeUpper: include,
      ));
    });
  }

  QueryBuilder<BehaviorLog, BehaviorLog, QAfterWhereClause> timestampBetween(
    DateTime lowerTimestamp,
    DateTime upperTimestamp, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'timestamp',
        lower: [lowerTimestamp],
        includeLower: includeLower,
        upper: [upperTimestamp],
        includeUpper: includeUpper,
      ));
    });
  }
}

extension BehaviorLogQueryFilter
    on QueryBuilder<BehaviorLog, BehaviorLog, QFilterCondition> {
  QueryBuilder<BehaviorLog, BehaviorLog, QAfterFilterCondition> actionEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'action',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BehaviorLog, BehaviorLog, QAfterFilterCondition>
      actionGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'action',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BehaviorLog, BehaviorLog, QAfterFilterCondition> actionLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'action',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BehaviorLog, BehaviorLog, QAfterFilterCondition> actionBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'action',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BehaviorLog, BehaviorLog, QAfterFilterCondition>
      actionStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'action',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BehaviorLog, BehaviorLog, QAfterFilterCondition> actionEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'action',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BehaviorLog, BehaviorLog, QAfterFilterCondition> actionContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'action',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BehaviorLog, BehaviorLog, QAfterFilterCondition> actionMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'action',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BehaviorLog, BehaviorLog, QAfterFilterCondition>
      actionIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'action',
        value: '',
      ));
    });
  }

  QueryBuilder<BehaviorLog, BehaviorLog, QAfterFilterCondition>
      actionIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'action',
        value: '',
      ));
    });
  }

  QueryBuilder<BehaviorLog, BehaviorLog, QAfterFilterCondition> deviceIdEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'deviceId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BehaviorLog, BehaviorLog, QAfterFilterCondition>
      deviceIdGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'deviceId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BehaviorLog, BehaviorLog, QAfterFilterCondition>
      deviceIdLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'deviceId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BehaviorLog, BehaviorLog, QAfterFilterCondition> deviceIdBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'deviceId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BehaviorLog, BehaviorLog, QAfterFilterCondition>
      deviceIdStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'deviceId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BehaviorLog, BehaviorLog, QAfterFilterCondition>
      deviceIdEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'deviceId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BehaviorLog, BehaviorLog, QAfterFilterCondition>
      deviceIdContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'deviceId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BehaviorLog, BehaviorLog, QAfterFilterCondition> deviceIdMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'deviceId',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BehaviorLog, BehaviorLog, QAfterFilterCondition>
      deviceIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'deviceId',
        value: '',
      ));
    });
  }

  QueryBuilder<BehaviorLog, BehaviorLog, QAfterFilterCondition>
      deviceIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'deviceId',
        value: '',
      ));
    });
  }

  QueryBuilder<BehaviorLog, BehaviorLog, QAfterFilterCondition> idEqualTo(
      Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<BehaviorLog, BehaviorLog, QAfterFilterCondition> idGreaterThan(
    Id value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<BehaviorLog, BehaviorLog, QAfterFilterCondition> idLessThan(
    Id value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<BehaviorLog, BehaviorLog, QAfterFilterCondition> idBetween(
    Id lower,
    Id upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'id',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<BehaviorLog, BehaviorLog, QAfterFilterCondition>
      illuminanceIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'illuminance',
      ));
    });
  }

  QueryBuilder<BehaviorLog, BehaviorLog, QAfterFilterCondition>
      illuminanceIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'illuminance',
      ));
    });
  }

  QueryBuilder<BehaviorLog, BehaviorLog, QAfterFilterCondition>
      illuminanceEqualTo(int? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'illuminance',
        value: value,
      ));
    });
  }

  QueryBuilder<BehaviorLog, BehaviorLog, QAfterFilterCondition>
      illuminanceGreaterThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'illuminance',
        value: value,
      ));
    });
  }

  QueryBuilder<BehaviorLog, BehaviorLog, QAfterFilterCondition>
      illuminanceLessThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'illuminance',
        value: value,
      ));
    });
  }

  QueryBuilder<BehaviorLog, BehaviorLog, QAfterFilterCondition>
      illuminanceBetween(
    int? lower,
    int? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'illuminance',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<BehaviorLog, BehaviorLog, QAfterFilterCondition>
      indoorTempIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'indoorTemp',
      ));
    });
  }

  QueryBuilder<BehaviorLog, BehaviorLog, QAfterFilterCondition>
      indoorTempIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'indoorTemp',
      ));
    });
  }

  QueryBuilder<BehaviorLog, BehaviorLog, QAfterFilterCondition>
      indoorTempEqualTo(
    double? value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'indoorTemp',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<BehaviorLog, BehaviorLog, QAfterFilterCondition>
      indoorTempGreaterThan(
    double? value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'indoorTemp',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<BehaviorLog, BehaviorLog, QAfterFilterCondition>
      indoorTempLessThan(
    double? value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'indoorTemp',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<BehaviorLog, BehaviorLog, QAfterFilterCondition>
      indoorTempBetween(
    double? lower,
    double? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'indoorTemp',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<BehaviorLog, BehaviorLog, QAfterFilterCondition>
      isWeekendEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'isWeekend',
        value: value,
      ));
    });
  }

  QueryBuilder<BehaviorLog, BehaviorLog, QAfterFilterCondition>
      outdoorTempIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'outdoorTemp',
      ));
    });
  }

  QueryBuilder<BehaviorLog, BehaviorLog, QAfterFilterCondition>
      outdoorTempIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'outdoorTemp',
      ));
    });
  }

  QueryBuilder<BehaviorLog, BehaviorLog, QAfterFilterCondition>
      outdoorTempEqualTo(
    double? value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'outdoorTemp',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<BehaviorLog, BehaviorLog, QAfterFilterCondition>
      outdoorTempGreaterThan(
    double? value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'outdoorTemp',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<BehaviorLog, BehaviorLog, QAfterFilterCondition>
      outdoorTempLessThan(
    double? value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'outdoorTemp',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<BehaviorLog, BehaviorLog, QAfterFilterCondition>
      outdoorTempBetween(
    double? lower,
    double? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'outdoorTemp',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<BehaviorLog, BehaviorLog, QAfterFilterCondition> seasonIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'season',
      ));
    });
  }

  QueryBuilder<BehaviorLog, BehaviorLog, QAfterFilterCondition>
      seasonIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'season',
      ));
    });
  }

  QueryBuilder<BehaviorLog, BehaviorLog, QAfterFilterCondition> seasonEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'season',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BehaviorLog, BehaviorLog, QAfterFilterCondition>
      seasonGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'season',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BehaviorLog, BehaviorLog, QAfterFilterCondition> seasonLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'season',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BehaviorLog, BehaviorLog, QAfterFilterCondition> seasonBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'season',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BehaviorLog, BehaviorLog, QAfterFilterCondition>
      seasonStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'season',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BehaviorLog, BehaviorLog, QAfterFilterCondition> seasonEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'season',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BehaviorLog, BehaviorLog, QAfterFilterCondition> seasonContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'season',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BehaviorLog, BehaviorLog, QAfterFilterCondition> seasonMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'season',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BehaviorLog, BehaviorLog, QAfterFilterCondition>
      seasonIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'season',
        value: '',
      ));
    });
  }

  QueryBuilder<BehaviorLog, BehaviorLog, QAfterFilterCondition>
      seasonIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'season',
        value: '',
      ));
    });
  }

  QueryBuilder<BehaviorLog, BehaviorLog, QAfterFilterCondition>
      timeOfDayEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'timeOfDay',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BehaviorLog, BehaviorLog, QAfterFilterCondition>
      timeOfDayGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'timeOfDay',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BehaviorLog, BehaviorLog, QAfterFilterCondition>
      timeOfDayLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'timeOfDay',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BehaviorLog, BehaviorLog, QAfterFilterCondition>
      timeOfDayBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'timeOfDay',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BehaviorLog, BehaviorLog, QAfterFilterCondition>
      timeOfDayStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'timeOfDay',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BehaviorLog, BehaviorLog, QAfterFilterCondition>
      timeOfDayEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'timeOfDay',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BehaviorLog, BehaviorLog, QAfterFilterCondition>
      timeOfDayContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'timeOfDay',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BehaviorLog, BehaviorLog, QAfterFilterCondition>
      timeOfDayMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'timeOfDay',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BehaviorLog, BehaviorLog, QAfterFilterCondition>
      timeOfDayIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'timeOfDay',
        value: '',
      ));
    });
  }

  QueryBuilder<BehaviorLog, BehaviorLog, QAfterFilterCondition>
      timeOfDayIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'timeOfDay',
        value: '',
      ));
    });
  }

  QueryBuilder<BehaviorLog, BehaviorLog, QAfterFilterCondition>
      timestampEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'timestamp',
        value: value,
      ));
    });
  }

  QueryBuilder<BehaviorLog, BehaviorLog, QAfterFilterCondition>
      timestampGreaterThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'timestamp',
        value: value,
      ));
    });
  }

  QueryBuilder<BehaviorLog, BehaviorLog, QAfterFilterCondition>
      timestampLessThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'timestamp',
        value: value,
      ));
    });
  }

  QueryBuilder<BehaviorLog, BehaviorLog, QAfterFilterCondition>
      timestampBetween(
    DateTime lower,
    DateTime upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'timestamp',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<BehaviorLog, BehaviorLog, QAfterFilterCondition> valueIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'value',
      ));
    });
  }

  QueryBuilder<BehaviorLog, BehaviorLog, QAfterFilterCondition>
      valueIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'value',
      ));
    });
  }

  QueryBuilder<BehaviorLog, BehaviorLog, QAfterFilterCondition> valueEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'value',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BehaviorLog, BehaviorLog, QAfterFilterCondition>
      valueGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'value',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BehaviorLog, BehaviorLog, QAfterFilterCondition> valueLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'value',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BehaviorLog, BehaviorLog, QAfterFilterCondition> valueBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'value',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BehaviorLog, BehaviorLog, QAfterFilterCondition> valueStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'value',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BehaviorLog, BehaviorLog, QAfterFilterCondition> valueEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'value',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BehaviorLog, BehaviorLog, QAfterFilterCondition> valueContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'value',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BehaviorLog, BehaviorLog, QAfterFilterCondition> valueMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'value',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BehaviorLog, BehaviorLog, QAfterFilterCondition> valueIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'value',
        value: '',
      ));
    });
  }

  QueryBuilder<BehaviorLog, BehaviorLog, QAfterFilterCondition>
      valueIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'value',
        value: '',
      ));
    });
  }
}

extension BehaviorLogQueryObject
    on QueryBuilder<BehaviorLog, BehaviorLog, QFilterCondition> {}

extension BehaviorLogQueryLinks
    on QueryBuilder<BehaviorLog, BehaviorLog, QFilterCondition> {}

extension BehaviorLogQuerySortBy
    on QueryBuilder<BehaviorLog, BehaviorLog, QSortBy> {
  QueryBuilder<BehaviorLog, BehaviorLog, QAfterSortBy> sortByAction() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'action', Sort.asc);
    });
  }

  QueryBuilder<BehaviorLog, BehaviorLog, QAfterSortBy> sortByActionDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'action', Sort.desc);
    });
  }

  QueryBuilder<BehaviorLog, BehaviorLog, QAfterSortBy> sortByDeviceId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'deviceId', Sort.asc);
    });
  }

  QueryBuilder<BehaviorLog, BehaviorLog, QAfterSortBy> sortByDeviceIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'deviceId', Sort.desc);
    });
  }

  QueryBuilder<BehaviorLog, BehaviorLog, QAfterSortBy> sortByIlluminance() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'illuminance', Sort.asc);
    });
  }

  QueryBuilder<BehaviorLog, BehaviorLog, QAfterSortBy> sortByIlluminanceDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'illuminance', Sort.desc);
    });
  }

  QueryBuilder<BehaviorLog, BehaviorLog, QAfterSortBy> sortByIndoorTemp() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'indoorTemp', Sort.asc);
    });
  }

  QueryBuilder<BehaviorLog, BehaviorLog, QAfterSortBy> sortByIndoorTempDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'indoorTemp', Sort.desc);
    });
  }

  QueryBuilder<BehaviorLog, BehaviorLog, QAfterSortBy> sortByIsWeekend() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isWeekend', Sort.asc);
    });
  }

  QueryBuilder<BehaviorLog, BehaviorLog, QAfterSortBy> sortByIsWeekendDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isWeekend', Sort.desc);
    });
  }

  QueryBuilder<BehaviorLog, BehaviorLog, QAfterSortBy> sortByOutdoorTemp() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'outdoorTemp', Sort.asc);
    });
  }

  QueryBuilder<BehaviorLog, BehaviorLog, QAfterSortBy> sortByOutdoorTempDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'outdoorTemp', Sort.desc);
    });
  }

  QueryBuilder<BehaviorLog, BehaviorLog, QAfterSortBy> sortBySeason() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'season', Sort.asc);
    });
  }

  QueryBuilder<BehaviorLog, BehaviorLog, QAfterSortBy> sortBySeasonDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'season', Sort.desc);
    });
  }

  QueryBuilder<BehaviorLog, BehaviorLog, QAfterSortBy> sortByTimeOfDay() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'timeOfDay', Sort.asc);
    });
  }

  QueryBuilder<BehaviorLog, BehaviorLog, QAfterSortBy> sortByTimeOfDayDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'timeOfDay', Sort.desc);
    });
  }

  QueryBuilder<BehaviorLog, BehaviorLog, QAfterSortBy> sortByTimestamp() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'timestamp', Sort.asc);
    });
  }

  QueryBuilder<BehaviorLog, BehaviorLog, QAfterSortBy> sortByTimestampDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'timestamp', Sort.desc);
    });
  }

  QueryBuilder<BehaviorLog, BehaviorLog, QAfterSortBy> sortByValue() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'value', Sort.asc);
    });
  }

  QueryBuilder<BehaviorLog, BehaviorLog, QAfterSortBy> sortByValueDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'value', Sort.desc);
    });
  }
}

extension BehaviorLogQuerySortThenBy
    on QueryBuilder<BehaviorLog, BehaviorLog, QSortThenBy> {
  QueryBuilder<BehaviorLog, BehaviorLog, QAfterSortBy> thenByAction() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'action', Sort.asc);
    });
  }

  QueryBuilder<BehaviorLog, BehaviorLog, QAfterSortBy> thenByActionDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'action', Sort.desc);
    });
  }

  QueryBuilder<BehaviorLog, BehaviorLog, QAfterSortBy> thenByDeviceId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'deviceId', Sort.asc);
    });
  }

  QueryBuilder<BehaviorLog, BehaviorLog, QAfterSortBy> thenByDeviceIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'deviceId', Sort.desc);
    });
  }

  QueryBuilder<BehaviorLog, BehaviorLog, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<BehaviorLog, BehaviorLog, QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<BehaviorLog, BehaviorLog, QAfterSortBy> thenByIlluminance() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'illuminance', Sort.asc);
    });
  }

  QueryBuilder<BehaviorLog, BehaviorLog, QAfterSortBy> thenByIlluminanceDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'illuminance', Sort.desc);
    });
  }

  QueryBuilder<BehaviorLog, BehaviorLog, QAfterSortBy> thenByIndoorTemp() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'indoorTemp', Sort.asc);
    });
  }

  QueryBuilder<BehaviorLog, BehaviorLog, QAfterSortBy> thenByIndoorTempDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'indoorTemp', Sort.desc);
    });
  }

  QueryBuilder<BehaviorLog, BehaviorLog, QAfterSortBy> thenByIsWeekend() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isWeekend', Sort.asc);
    });
  }

  QueryBuilder<BehaviorLog, BehaviorLog, QAfterSortBy> thenByIsWeekendDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isWeekend', Sort.desc);
    });
  }

  QueryBuilder<BehaviorLog, BehaviorLog, QAfterSortBy> thenByOutdoorTemp() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'outdoorTemp', Sort.asc);
    });
  }

  QueryBuilder<BehaviorLog, BehaviorLog, QAfterSortBy> thenByOutdoorTempDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'outdoorTemp', Sort.desc);
    });
  }

  QueryBuilder<BehaviorLog, BehaviorLog, QAfterSortBy> thenBySeason() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'season', Sort.asc);
    });
  }

  QueryBuilder<BehaviorLog, BehaviorLog, QAfterSortBy> thenBySeasonDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'season', Sort.desc);
    });
  }

  QueryBuilder<BehaviorLog, BehaviorLog, QAfterSortBy> thenByTimeOfDay() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'timeOfDay', Sort.asc);
    });
  }

  QueryBuilder<BehaviorLog, BehaviorLog, QAfterSortBy> thenByTimeOfDayDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'timeOfDay', Sort.desc);
    });
  }

  QueryBuilder<BehaviorLog, BehaviorLog, QAfterSortBy> thenByTimestamp() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'timestamp', Sort.asc);
    });
  }

  QueryBuilder<BehaviorLog, BehaviorLog, QAfterSortBy> thenByTimestampDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'timestamp', Sort.desc);
    });
  }

  QueryBuilder<BehaviorLog, BehaviorLog, QAfterSortBy> thenByValue() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'value', Sort.asc);
    });
  }

  QueryBuilder<BehaviorLog, BehaviorLog, QAfterSortBy> thenByValueDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'value', Sort.desc);
    });
  }
}

extension BehaviorLogQueryWhereDistinct
    on QueryBuilder<BehaviorLog, BehaviorLog, QDistinct> {
  QueryBuilder<BehaviorLog, BehaviorLog, QDistinct> distinctByAction(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'action', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<BehaviorLog, BehaviorLog, QDistinct> distinctByDeviceId(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'deviceId', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<BehaviorLog, BehaviorLog, QDistinct> distinctByIlluminance() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'illuminance');
    });
  }

  QueryBuilder<BehaviorLog, BehaviorLog, QDistinct> distinctByIndoorTemp() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'indoorTemp');
    });
  }

  QueryBuilder<BehaviorLog, BehaviorLog, QDistinct> distinctByIsWeekend() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'isWeekend');
    });
  }

  QueryBuilder<BehaviorLog, BehaviorLog, QDistinct> distinctByOutdoorTemp() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'outdoorTemp');
    });
  }

  QueryBuilder<BehaviorLog, BehaviorLog, QDistinct> distinctBySeason(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'season', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<BehaviorLog, BehaviorLog, QDistinct> distinctByTimeOfDay(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'timeOfDay', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<BehaviorLog, BehaviorLog, QDistinct> distinctByTimestamp() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'timestamp');
    });
  }

  QueryBuilder<BehaviorLog, BehaviorLog, QDistinct> distinctByValue(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'value', caseSensitive: caseSensitive);
    });
  }
}

extension BehaviorLogQueryProperty
    on QueryBuilder<BehaviorLog, BehaviorLog, QQueryProperty> {
  QueryBuilder<BehaviorLog, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<BehaviorLog, String, QQueryOperations> actionProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'action');
    });
  }

  QueryBuilder<BehaviorLog, String, QQueryOperations> deviceIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'deviceId');
    });
  }

  QueryBuilder<BehaviorLog, int?, QQueryOperations> illuminanceProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'illuminance');
    });
  }

  QueryBuilder<BehaviorLog, double?, QQueryOperations> indoorTempProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'indoorTemp');
    });
  }

  QueryBuilder<BehaviorLog, bool, QQueryOperations> isWeekendProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'isWeekend');
    });
  }

  QueryBuilder<BehaviorLog, double?, QQueryOperations> outdoorTempProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'outdoorTemp');
    });
  }

  QueryBuilder<BehaviorLog, String?, QQueryOperations> seasonProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'season');
    });
  }

  QueryBuilder<BehaviorLog, String, QQueryOperations> timeOfDayProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'timeOfDay');
    });
  }

  QueryBuilder<BehaviorLog, DateTime, QQueryOperations> timestampProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'timestamp');
    });
  }

  QueryBuilder<BehaviorLog, String?, QQueryOperations> valueProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'value');
    });
  }
}
