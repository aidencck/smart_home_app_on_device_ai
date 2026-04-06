// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'override_log.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetOverrideLogCollection on Isar {
  IsarCollection<OverrideLog> get overrideLogs => this.collection();
}

const OverrideLogSchema = CollectionSchema(
  name: r'OverrideLog',
  id: 517977699503458233,
  properties: {
    r'actionType': PropertySchema(
      id: 0,
      name: r'actionType',
      type: IsarType.string,
    ),
    r'isResolved': PropertySchema(
      id: 1,
      name: r'isResolved',
      type: IsarType.bool,
    ),
    r'reason': PropertySchema(
      id: 2,
      name: r'reason',
      type: IsarType.string,
    ),
    r'resolvedAt': PropertySchema(
      id: 3,
      name: r'resolvedAt',
      type: IsarType.dateTime,
    ),
    r'severityLevel': PropertySchema(
      id: 4,
      name: r'severityLevel',
      type: IsarType.long,
    ),
    r'targetId': PropertySchema(
      id: 5,
      name: r'targetId',
      type: IsarType.string,
    ),
    r'timestamp': PropertySchema(
      id: 6,
      name: r'timestamp',
      type: IsarType.dateTime,
    ),
    r'triggeredBy': PropertySchema(
      id: 7,
      name: r'triggeredBy',
      type: IsarType.string,
    )
  },
  estimateSize: _overrideLogEstimateSize,
  serialize: _overrideLogSerialize,
  deserialize: _overrideLogDeserialize,
  deserializeProp: _overrideLogDeserializeProp,
  idName: r'id',
  indexes: {
    r'targetId': IndexSchema(
      id: -7400732725972739031,
      name: r'targetId',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'targetId',
          type: IndexType.hash,
          caseSensitive: true,
        )
      ],
    ),
    r'timestamp': IndexSchema(
      id: 1852253767416892198,
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
  getId: _overrideLogGetId,
  getLinks: _overrideLogGetLinks,
  attach: _overrideLogAttach,
  version: '3.1.0+1',
);

int _overrideLogEstimateSize(
  OverrideLog object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  {
    final value = object.actionType;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.reason;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.targetId;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.triggeredBy;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  return bytesCount;
}

void _overrideLogSerialize(
  OverrideLog object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeString(offsets[0], object.actionType);
  writer.writeBool(offsets[1], object.isResolved);
  writer.writeString(offsets[2], object.reason);
  writer.writeDateTime(offsets[3], object.resolvedAt);
  writer.writeLong(offsets[4], object.severityLevel);
  writer.writeString(offsets[5], object.targetId);
  writer.writeDateTime(offsets[6], object.timestamp);
  writer.writeString(offsets[7], object.triggeredBy);
}

OverrideLog _overrideLogDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = OverrideLog();
  object.actionType = reader.readStringOrNull(offsets[0]);
  object.id = id;
  object.isResolved = reader.readBoolOrNull(offsets[1]);
  object.reason = reader.readStringOrNull(offsets[2]);
  object.resolvedAt = reader.readDateTimeOrNull(offsets[3]);
  object.severityLevel = reader.readLongOrNull(offsets[4]);
  object.targetId = reader.readStringOrNull(offsets[5]);
  object.timestamp = reader.readDateTimeOrNull(offsets[6]);
  object.triggeredBy = reader.readStringOrNull(offsets[7]);
  return object;
}

P _overrideLogDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readStringOrNull(offset)) as P;
    case 1:
      return (reader.readBoolOrNull(offset)) as P;
    case 2:
      return (reader.readStringOrNull(offset)) as P;
    case 3:
      return (reader.readDateTimeOrNull(offset)) as P;
    case 4:
      return (reader.readLongOrNull(offset)) as P;
    case 5:
      return (reader.readStringOrNull(offset)) as P;
    case 6:
      return (reader.readDateTimeOrNull(offset)) as P;
    case 7:
      return (reader.readStringOrNull(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _overrideLogGetId(OverrideLog object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _overrideLogGetLinks(OverrideLog object) {
  return [];
}

void _overrideLogAttach(
    IsarCollection<dynamic> col, Id id, OverrideLog object) {
  object.id = id;
}

extension OverrideLogQueryWhereSort
    on QueryBuilder<OverrideLog, OverrideLog, QWhere> {
  QueryBuilder<OverrideLog, OverrideLog, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }

  QueryBuilder<OverrideLog, OverrideLog, QAfterWhere> anyTimestamp() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        const IndexWhereClause.any(indexName: r'timestamp'),
      );
    });
  }
}

extension OverrideLogQueryWhere
    on QueryBuilder<OverrideLog, OverrideLog, QWhereClause> {
  QueryBuilder<OverrideLog, OverrideLog, QAfterWhereClause> idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<OverrideLog, OverrideLog, QAfterWhereClause> idNotEqualTo(
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

  QueryBuilder<OverrideLog, OverrideLog, QAfterWhereClause> idGreaterThan(Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<OverrideLog, OverrideLog, QAfterWhereClause> idLessThan(Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<OverrideLog, OverrideLog, QAfterWhereClause> idBetween(
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

  QueryBuilder<OverrideLog, OverrideLog, QAfterWhereClause> targetIdIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'targetId',
        value: [null],
      ));
    });
  }

  QueryBuilder<OverrideLog, OverrideLog, QAfterWhereClause>
      targetIdIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'targetId',
        lower: [null],
        includeLower: false,
        upper: [],
      ));
    });
  }

  QueryBuilder<OverrideLog, OverrideLog, QAfterWhereClause> targetIdEqualTo(
      String? targetId) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'targetId',
        value: [targetId],
      ));
    });
  }

  QueryBuilder<OverrideLog, OverrideLog, QAfterWhereClause> targetIdNotEqualTo(
      String? targetId) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'targetId',
              lower: [],
              upper: [targetId],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'targetId',
              lower: [targetId],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'targetId',
              lower: [targetId],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'targetId',
              lower: [],
              upper: [targetId],
              includeUpper: false,
            ));
      }
    });
  }

  QueryBuilder<OverrideLog, OverrideLog, QAfterWhereClause> timestampIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'timestamp',
        value: [null],
      ));
    });
  }

  QueryBuilder<OverrideLog, OverrideLog, QAfterWhereClause>
      timestampIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'timestamp',
        lower: [null],
        includeLower: false,
        upper: [],
      ));
    });
  }

  QueryBuilder<OverrideLog, OverrideLog, QAfterWhereClause> timestampEqualTo(
      DateTime? timestamp) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'timestamp',
        value: [timestamp],
      ));
    });
  }

  QueryBuilder<OverrideLog, OverrideLog, QAfterWhereClause> timestampNotEqualTo(
      DateTime? timestamp) {
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

  QueryBuilder<OverrideLog, OverrideLog, QAfterWhereClause>
      timestampGreaterThan(
    DateTime? timestamp, {
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

  QueryBuilder<OverrideLog, OverrideLog, QAfterWhereClause> timestampLessThan(
    DateTime? timestamp, {
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

  QueryBuilder<OverrideLog, OverrideLog, QAfterWhereClause> timestampBetween(
    DateTime? lowerTimestamp,
    DateTime? upperTimestamp, {
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

extension OverrideLogQueryFilter
    on QueryBuilder<OverrideLog, OverrideLog, QFilterCondition> {
  QueryBuilder<OverrideLog, OverrideLog, QAfterFilterCondition>
      actionTypeIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'actionType',
      ));
    });
  }

  QueryBuilder<OverrideLog, OverrideLog, QAfterFilterCondition>
      actionTypeIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'actionType',
      ));
    });
  }

  QueryBuilder<OverrideLog, OverrideLog, QAfterFilterCondition>
      actionTypeEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'actionType',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<OverrideLog, OverrideLog, QAfterFilterCondition>
      actionTypeGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'actionType',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<OverrideLog, OverrideLog, QAfterFilterCondition>
      actionTypeLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'actionType',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<OverrideLog, OverrideLog, QAfterFilterCondition>
      actionTypeBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'actionType',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<OverrideLog, OverrideLog, QAfterFilterCondition>
      actionTypeStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'actionType',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<OverrideLog, OverrideLog, QAfterFilterCondition>
      actionTypeEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'actionType',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<OverrideLog, OverrideLog, QAfterFilterCondition>
      actionTypeContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'actionType',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<OverrideLog, OverrideLog, QAfterFilterCondition>
      actionTypeMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'actionType',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<OverrideLog, OverrideLog, QAfterFilterCondition>
      actionTypeIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'actionType',
        value: '',
      ));
    });
  }

  QueryBuilder<OverrideLog, OverrideLog, QAfterFilterCondition>
      actionTypeIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'actionType',
        value: '',
      ));
    });
  }

  QueryBuilder<OverrideLog, OverrideLog, QAfterFilterCondition> idEqualTo(
      Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<OverrideLog, OverrideLog, QAfterFilterCondition> idGreaterThan(
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

  QueryBuilder<OverrideLog, OverrideLog, QAfterFilterCondition> idLessThan(
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

  QueryBuilder<OverrideLog, OverrideLog, QAfterFilterCondition> idBetween(
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

  QueryBuilder<OverrideLog, OverrideLog, QAfterFilterCondition>
      isResolvedIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'isResolved',
      ));
    });
  }

  QueryBuilder<OverrideLog, OverrideLog, QAfterFilterCondition>
      isResolvedIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'isResolved',
      ));
    });
  }

  QueryBuilder<OverrideLog, OverrideLog, QAfterFilterCondition>
      isResolvedEqualTo(bool? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'isResolved',
        value: value,
      ));
    });
  }

  QueryBuilder<OverrideLog, OverrideLog, QAfterFilterCondition> reasonIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'reason',
      ));
    });
  }

  QueryBuilder<OverrideLog, OverrideLog, QAfterFilterCondition>
      reasonIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'reason',
      ));
    });
  }

  QueryBuilder<OverrideLog, OverrideLog, QAfterFilterCondition> reasonEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'reason',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<OverrideLog, OverrideLog, QAfterFilterCondition>
      reasonGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'reason',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<OverrideLog, OverrideLog, QAfterFilterCondition> reasonLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'reason',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<OverrideLog, OverrideLog, QAfterFilterCondition> reasonBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'reason',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<OverrideLog, OverrideLog, QAfterFilterCondition>
      reasonStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'reason',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<OverrideLog, OverrideLog, QAfterFilterCondition> reasonEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'reason',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<OverrideLog, OverrideLog, QAfterFilterCondition> reasonContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'reason',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<OverrideLog, OverrideLog, QAfterFilterCondition> reasonMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'reason',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<OverrideLog, OverrideLog, QAfterFilterCondition>
      reasonIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'reason',
        value: '',
      ));
    });
  }

  QueryBuilder<OverrideLog, OverrideLog, QAfterFilterCondition>
      reasonIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'reason',
        value: '',
      ));
    });
  }

  QueryBuilder<OverrideLog, OverrideLog, QAfterFilterCondition>
      resolvedAtIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'resolvedAt',
      ));
    });
  }

  QueryBuilder<OverrideLog, OverrideLog, QAfterFilterCondition>
      resolvedAtIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'resolvedAt',
      ));
    });
  }

  QueryBuilder<OverrideLog, OverrideLog, QAfterFilterCondition>
      resolvedAtEqualTo(DateTime? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'resolvedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<OverrideLog, OverrideLog, QAfterFilterCondition>
      resolvedAtGreaterThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'resolvedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<OverrideLog, OverrideLog, QAfterFilterCondition>
      resolvedAtLessThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'resolvedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<OverrideLog, OverrideLog, QAfterFilterCondition>
      resolvedAtBetween(
    DateTime? lower,
    DateTime? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'resolvedAt',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<OverrideLog, OverrideLog, QAfterFilterCondition>
      severityLevelIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'severityLevel',
      ));
    });
  }

  QueryBuilder<OverrideLog, OverrideLog, QAfterFilterCondition>
      severityLevelIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'severityLevel',
      ));
    });
  }

  QueryBuilder<OverrideLog, OverrideLog, QAfterFilterCondition>
      severityLevelEqualTo(int? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'severityLevel',
        value: value,
      ));
    });
  }

  QueryBuilder<OverrideLog, OverrideLog, QAfterFilterCondition>
      severityLevelGreaterThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'severityLevel',
        value: value,
      ));
    });
  }

  QueryBuilder<OverrideLog, OverrideLog, QAfterFilterCondition>
      severityLevelLessThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'severityLevel',
        value: value,
      ));
    });
  }

  QueryBuilder<OverrideLog, OverrideLog, QAfterFilterCondition>
      severityLevelBetween(
    int? lower,
    int? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'severityLevel',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<OverrideLog, OverrideLog, QAfterFilterCondition>
      targetIdIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'targetId',
      ));
    });
  }

  QueryBuilder<OverrideLog, OverrideLog, QAfterFilterCondition>
      targetIdIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'targetId',
      ));
    });
  }

  QueryBuilder<OverrideLog, OverrideLog, QAfterFilterCondition> targetIdEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'targetId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<OverrideLog, OverrideLog, QAfterFilterCondition>
      targetIdGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'targetId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<OverrideLog, OverrideLog, QAfterFilterCondition>
      targetIdLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'targetId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<OverrideLog, OverrideLog, QAfterFilterCondition> targetIdBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'targetId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<OverrideLog, OverrideLog, QAfterFilterCondition>
      targetIdStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'targetId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<OverrideLog, OverrideLog, QAfterFilterCondition>
      targetIdEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'targetId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<OverrideLog, OverrideLog, QAfterFilterCondition>
      targetIdContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'targetId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<OverrideLog, OverrideLog, QAfterFilterCondition> targetIdMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'targetId',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<OverrideLog, OverrideLog, QAfterFilterCondition>
      targetIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'targetId',
        value: '',
      ));
    });
  }

  QueryBuilder<OverrideLog, OverrideLog, QAfterFilterCondition>
      targetIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'targetId',
        value: '',
      ));
    });
  }

  QueryBuilder<OverrideLog, OverrideLog, QAfterFilterCondition>
      timestampIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'timestamp',
      ));
    });
  }

  QueryBuilder<OverrideLog, OverrideLog, QAfterFilterCondition>
      timestampIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'timestamp',
      ));
    });
  }

  QueryBuilder<OverrideLog, OverrideLog, QAfterFilterCondition>
      timestampEqualTo(DateTime? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'timestamp',
        value: value,
      ));
    });
  }

  QueryBuilder<OverrideLog, OverrideLog, QAfterFilterCondition>
      timestampGreaterThan(
    DateTime? value, {
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

  QueryBuilder<OverrideLog, OverrideLog, QAfterFilterCondition>
      timestampLessThan(
    DateTime? value, {
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

  QueryBuilder<OverrideLog, OverrideLog, QAfterFilterCondition>
      timestampBetween(
    DateTime? lower,
    DateTime? upper, {
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

  QueryBuilder<OverrideLog, OverrideLog, QAfterFilterCondition>
      triggeredByIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'triggeredBy',
      ));
    });
  }

  QueryBuilder<OverrideLog, OverrideLog, QAfterFilterCondition>
      triggeredByIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'triggeredBy',
      ));
    });
  }

  QueryBuilder<OverrideLog, OverrideLog, QAfterFilterCondition>
      triggeredByEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'triggeredBy',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<OverrideLog, OverrideLog, QAfterFilterCondition>
      triggeredByGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'triggeredBy',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<OverrideLog, OverrideLog, QAfterFilterCondition>
      triggeredByLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'triggeredBy',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<OverrideLog, OverrideLog, QAfterFilterCondition>
      triggeredByBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'triggeredBy',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<OverrideLog, OverrideLog, QAfterFilterCondition>
      triggeredByStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'triggeredBy',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<OverrideLog, OverrideLog, QAfterFilterCondition>
      triggeredByEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'triggeredBy',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<OverrideLog, OverrideLog, QAfterFilterCondition>
      triggeredByContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'triggeredBy',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<OverrideLog, OverrideLog, QAfterFilterCondition>
      triggeredByMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'triggeredBy',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<OverrideLog, OverrideLog, QAfterFilterCondition>
      triggeredByIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'triggeredBy',
        value: '',
      ));
    });
  }

  QueryBuilder<OverrideLog, OverrideLog, QAfterFilterCondition>
      triggeredByIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'triggeredBy',
        value: '',
      ));
    });
  }
}

extension OverrideLogQueryObject
    on QueryBuilder<OverrideLog, OverrideLog, QFilterCondition> {}

extension OverrideLogQueryLinks
    on QueryBuilder<OverrideLog, OverrideLog, QFilterCondition> {}

extension OverrideLogQuerySortBy
    on QueryBuilder<OverrideLog, OverrideLog, QSortBy> {
  QueryBuilder<OverrideLog, OverrideLog, QAfterSortBy> sortByActionType() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'actionType', Sort.asc);
    });
  }

  QueryBuilder<OverrideLog, OverrideLog, QAfterSortBy> sortByActionTypeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'actionType', Sort.desc);
    });
  }

  QueryBuilder<OverrideLog, OverrideLog, QAfterSortBy> sortByIsResolved() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isResolved', Sort.asc);
    });
  }

  QueryBuilder<OverrideLog, OverrideLog, QAfterSortBy> sortByIsResolvedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isResolved', Sort.desc);
    });
  }

  QueryBuilder<OverrideLog, OverrideLog, QAfterSortBy> sortByReason() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'reason', Sort.asc);
    });
  }

  QueryBuilder<OverrideLog, OverrideLog, QAfterSortBy> sortByReasonDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'reason', Sort.desc);
    });
  }

  QueryBuilder<OverrideLog, OverrideLog, QAfterSortBy> sortByResolvedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'resolvedAt', Sort.asc);
    });
  }

  QueryBuilder<OverrideLog, OverrideLog, QAfterSortBy> sortByResolvedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'resolvedAt', Sort.desc);
    });
  }

  QueryBuilder<OverrideLog, OverrideLog, QAfterSortBy> sortBySeverityLevel() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'severityLevel', Sort.asc);
    });
  }

  QueryBuilder<OverrideLog, OverrideLog, QAfterSortBy>
      sortBySeverityLevelDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'severityLevel', Sort.desc);
    });
  }

  QueryBuilder<OverrideLog, OverrideLog, QAfterSortBy> sortByTargetId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'targetId', Sort.asc);
    });
  }

  QueryBuilder<OverrideLog, OverrideLog, QAfterSortBy> sortByTargetIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'targetId', Sort.desc);
    });
  }

  QueryBuilder<OverrideLog, OverrideLog, QAfterSortBy> sortByTimestamp() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'timestamp', Sort.asc);
    });
  }

  QueryBuilder<OverrideLog, OverrideLog, QAfterSortBy> sortByTimestampDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'timestamp', Sort.desc);
    });
  }

  QueryBuilder<OverrideLog, OverrideLog, QAfterSortBy> sortByTriggeredBy() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'triggeredBy', Sort.asc);
    });
  }

  QueryBuilder<OverrideLog, OverrideLog, QAfterSortBy> sortByTriggeredByDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'triggeredBy', Sort.desc);
    });
  }
}

extension OverrideLogQuerySortThenBy
    on QueryBuilder<OverrideLog, OverrideLog, QSortThenBy> {
  QueryBuilder<OverrideLog, OverrideLog, QAfterSortBy> thenByActionType() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'actionType', Sort.asc);
    });
  }

  QueryBuilder<OverrideLog, OverrideLog, QAfterSortBy> thenByActionTypeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'actionType', Sort.desc);
    });
  }

  QueryBuilder<OverrideLog, OverrideLog, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<OverrideLog, OverrideLog, QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<OverrideLog, OverrideLog, QAfterSortBy> thenByIsResolved() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isResolved', Sort.asc);
    });
  }

  QueryBuilder<OverrideLog, OverrideLog, QAfterSortBy> thenByIsResolvedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isResolved', Sort.desc);
    });
  }

  QueryBuilder<OverrideLog, OverrideLog, QAfterSortBy> thenByReason() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'reason', Sort.asc);
    });
  }

  QueryBuilder<OverrideLog, OverrideLog, QAfterSortBy> thenByReasonDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'reason', Sort.desc);
    });
  }

  QueryBuilder<OverrideLog, OverrideLog, QAfterSortBy> thenByResolvedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'resolvedAt', Sort.asc);
    });
  }

  QueryBuilder<OverrideLog, OverrideLog, QAfterSortBy> thenByResolvedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'resolvedAt', Sort.desc);
    });
  }

  QueryBuilder<OverrideLog, OverrideLog, QAfterSortBy> thenBySeverityLevel() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'severityLevel', Sort.asc);
    });
  }

  QueryBuilder<OverrideLog, OverrideLog, QAfterSortBy>
      thenBySeverityLevelDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'severityLevel', Sort.desc);
    });
  }

  QueryBuilder<OverrideLog, OverrideLog, QAfterSortBy> thenByTargetId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'targetId', Sort.asc);
    });
  }

  QueryBuilder<OverrideLog, OverrideLog, QAfterSortBy> thenByTargetIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'targetId', Sort.desc);
    });
  }

  QueryBuilder<OverrideLog, OverrideLog, QAfterSortBy> thenByTimestamp() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'timestamp', Sort.asc);
    });
  }

  QueryBuilder<OverrideLog, OverrideLog, QAfterSortBy> thenByTimestampDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'timestamp', Sort.desc);
    });
  }

  QueryBuilder<OverrideLog, OverrideLog, QAfterSortBy> thenByTriggeredBy() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'triggeredBy', Sort.asc);
    });
  }

  QueryBuilder<OverrideLog, OverrideLog, QAfterSortBy> thenByTriggeredByDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'triggeredBy', Sort.desc);
    });
  }
}

extension OverrideLogQueryWhereDistinct
    on QueryBuilder<OverrideLog, OverrideLog, QDistinct> {
  QueryBuilder<OverrideLog, OverrideLog, QDistinct> distinctByActionType(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'actionType', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<OverrideLog, OverrideLog, QDistinct> distinctByIsResolved() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'isResolved');
    });
  }

  QueryBuilder<OverrideLog, OverrideLog, QDistinct> distinctByReason(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'reason', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<OverrideLog, OverrideLog, QDistinct> distinctByResolvedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'resolvedAt');
    });
  }

  QueryBuilder<OverrideLog, OverrideLog, QDistinct> distinctBySeverityLevel() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'severityLevel');
    });
  }

  QueryBuilder<OverrideLog, OverrideLog, QDistinct> distinctByTargetId(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'targetId', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<OverrideLog, OverrideLog, QDistinct> distinctByTimestamp() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'timestamp');
    });
  }

  QueryBuilder<OverrideLog, OverrideLog, QDistinct> distinctByTriggeredBy(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'triggeredBy', caseSensitive: caseSensitive);
    });
  }
}

extension OverrideLogQueryProperty
    on QueryBuilder<OverrideLog, OverrideLog, QQueryProperty> {
  QueryBuilder<OverrideLog, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<OverrideLog, String?, QQueryOperations> actionTypeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'actionType');
    });
  }

  QueryBuilder<OverrideLog, bool?, QQueryOperations> isResolvedProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'isResolved');
    });
  }

  QueryBuilder<OverrideLog, String?, QQueryOperations> reasonProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'reason');
    });
  }

  QueryBuilder<OverrideLog, DateTime?, QQueryOperations> resolvedAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'resolvedAt');
    });
  }

  QueryBuilder<OverrideLog, int?, QQueryOperations> severityLevelProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'severityLevel');
    });
  }

  QueryBuilder<OverrideLog, String?, QQueryOperations> targetIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'targetId');
    });
  }

  QueryBuilder<OverrideLog, DateTime?, QQueryOperations> timestampProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'timestamp');
    });
  }

  QueryBuilder<OverrideLog, String?, QQueryOperations> triggeredByProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'triggeredBy');
    });
  }
}
