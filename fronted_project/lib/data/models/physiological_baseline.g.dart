// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'physiological_baseline.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetPhysiologicalBaselineCollection on Isar {
  IsarCollection<PhysiologicalBaseline> get physiologicalBaselines =>
      this.collection();
}

const PhysiologicalBaselineSchema = CollectionSchema(
  name: r'PhysiologicalBaseline',
  id: -3406825072008475644,
  properties: {
    r'bloodOxygenLevel': PropertySchema(
      id: 0,
      name: r'bloodOxygenLevel',
      type: IsarType.double,
    ),
    r'bodyTemperature': PropertySchema(
      id: 1,
      name: r'bodyTemperature',
      type: IsarType.double,
    ),
    r'diastolicBloodPressure': PropertySchema(
      id: 2,
      name: r'diastolicBloodPressure',
      type: IsarType.long,
    ),
    r'respirationRate': PropertySchema(
      id: 3,
      name: r'respirationRate',
      type: IsarType.long,
    ),
    r'restingHeartRate': PropertySchema(
      id: 4,
      name: r'restingHeartRate',
      type: IsarType.long,
    ),
    r'systolicBloodPressure': PropertySchema(
      id: 5,
      name: r'systolicBloodPressure',
      type: IsarType.long,
    ),
    r'updatedAt': PropertySchema(
      id: 6,
      name: r'updatedAt',
      type: IsarType.dateTime,
    ),
    r'userId': PropertySchema(
      id: 7,
      name: r'userId',
      type: IsarType.string,
    )
  },
  estimateSize: _physiologicalBaselineEstimateSize,
  serialize: _physiologicalBaselineSerialize,
  deserialize: _physiologicalBaselineDeserialize,
  deserializeProp: _physiologicalBaselineDeserializeProp,
  idName: r'id',
  indexes: {
    r'userId': IndexSchema(
      id: -2005826577402374815,
      name: r'userId',
      unique: true,
      replace: true,
      properties: [
        IndexPropertySchema(
          name: r'userId',
          type: IndexType.hash,
          caseSensitive: true,
        )
      ],
    )
  },
  links: {},
  embeddedSchemas: {},
  getId: _physiologicalBaselineGetId,
  getLinks: _physiologicalBaselineGetLinks,
  attach: _physiologicalBaselineAttach,
  version: '3.1.0+1',
);

int _physiologicalBaselineEstimateSize(
  PhysiologicalBaseline object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  {
    final value = object.userId;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  return bytesCount;
}

void _physiologicalBaselineSerialize(
  PhysiologicalBaseline object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeDouble(offsets[0], object.bloodOxygenLevel);
  writer.writeDouble(offsets[1], object.bodyTemperature);
  writer.writeLong(offsets[2], object.diastolicBloodPressure);
  writer.writeLong(offsets[3], object.respirationRate);
  writer.writeLong(offsets[4], object.restingHeartRate);
  writer.writeLong(offsets[5], object.systolicBloodPressure);
  writer.writeDateTime(offsets[6], object.updatedAt);
  writer.writeString(offsets[7], object.userId);
}

PhysiologicalBaseline _physiologicalBaselineDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = PhysiologicalBaseline();
  object.bloodOxygenLevel = reader.readDoubleOrNull(offsets[0]);
  object.bodyTemperature = reader.readDoubleOrNull(offsets[1]);
  object.diastolicBloodPressure = reader.readLongOrNull(offsets[2]);
  object.id = id;
  object.respirationRate = reader.readLongOrNull(offsets[3]);
  object.restingHeartRate = reader.readLongOrNull(offsets[4]);
  object.systolicBloodPressure = reader.readLongOrNull(offsets[5]);
  object.updatedAt = reader.readDateTimeOrNull(offsets[6]);
  object.userId = reader.readStringOrNull(offsets[7]);
  return object;
}

P _physiologicalBaselineDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readDoubleOrNull(offset)) as P;
    case 1:
      return (reader.readDoubleOrNull(offset)) as P;
    case 2:
      return (reader.readLongOrNull(offset)) as P;
    case 3:
      return (reader.readLongOrNull(offset)) as P;
    case 4:
      return (reader.readLongOrNull(offset)) as P;
    case 5:
      return (reader.readLongOrNull(offset)) as P;
    case 6:
      return (reader.readDateTimeOrNull(offset)) as P;
    case 7:
      return (reader.readStringOrNull(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _physiologicalBaselineGetId(PhysiologicalBaseline object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _physiologicalBaselineGetLinks(
    PhysiologicalBaseline object) {
  return [];
}

void _physiologicalBaselineAttach(
    IsarCollection<dynamic> col, Id id, PhysiologicalBaseline object) {
  object.id = id;
}

extension PhysiologicalBaselineByIndex
    on IsarCollection<PhysiologicalBaseline> {
  Future<PhysiologicalBaseline?> getByUserId(String? userId) {
    return getByIndex(r'userId', [userId]);
  }

  PhysiologicalBaseline? getByUserIdSync(String? userId) {
    return getByIndexSync(r'userId', [userId]);
  }

  Future<bool> deleteByUserId(String? userId) {
    return deleteByIndex(r'userId', [userId]);
  }

  bool deleteByUserIdSync(String? userId) {
    return deleteByIndexSync(r'userId', [userId]);
  }

  Future<List<PhysiologicalBaseline?>> getAllByUserId(
      List<String?> userIdValues) {
    final values = userIdValues.map((e) => [e]).toList();
    return getAllByIndex(r'userId', values);
  }

  List<PhysiologicalBaseline?> getAllByUserIdSync(List<String?> userIdValues) {
    final values = userIdValues.map((e) => [e]).toList();
    return getAllByIndexSync(r'userId', values);
  }

  Future<int> deleteAllByUserId(List<String?> userIdValues) {
    final values = userIdValues.map((e) => [e]).toList();
    return deleteAllByIndex(r'userId', values);
  }

  int deleteAllByUserIdSync(List<String?> userIdValues) {
    final values = userIdValues.map((e) => [e]).toList();
    return deleteAllByIndexSync(r'userId', values);
  }

  Future<Id> putByUserId(PhysiologicalBaseline object) {
    return putByIndex(r'userId', object);
  }

  Id putByUserIdSync(PhysiologicalBaseline object, {bool saveLinks = true}) {
    return putByIndexSync(r'userId', object, saveLinks: saveLinks);
  }

  Future<List<Id>> putAllByUserId(List<PhysiologicalBaseline> objects) {
    return putAllByIndex(r'userId', objects);
  }

  List<Id> putAllByUserIdSync(List<PhysiologicalBaseline> objects,
      {bool saveLinks = true}) {
    return putAllByIndexSync(r'userId', objects, saveLinks: saveLinks);
  }
}

extension PhysiologicalBaselineQueryWhereSort
    on QueryBuilder<PhysiologicalBaseline, PhysiologicalBaseline, QWhere> {
  QueryBuilder<PhysiologicalBaseline, PhysiologicalBaseline, QAfterWhere>
      anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension PhysiologicalBaselineQueryWhere on QueryBuilder<PhysiologicalBaseline,
    PhysiologicalBaseline, QWhereClause> {
  QueryBuilder<PhysiologicalBaseline, PhysiologicalBaseline, QAfterWhereClause>
      idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<PhysiologicalBaseline, PhysiologicalBaseline, QAfterWhereClause>
      idNotEqualTo(Id id) {
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

  QueryBuilder<PhysiologicalBaseline, PhysiologicalBaseline, QAfterWhereClause>
      idGreaterThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<PhysiologicalBaseline, PhysiologicalBaseline, QAfterWhereClause>
      idLessThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<PhysiologicalBaseline, PhysiologicalBaseline, QAfterWhereClause>
      idBetween(
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

  QueryBuilder<PhysiologicalBaseline, PhysiologicalBaseline, QAfterWhereClause>
      userIdIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'userId',
        value: [null],
      ));
    });
  }

  QueryBuilder<PhysiologicalBaseline, PhysiologicalBaseline, QAfterWhereClause>
      userIdIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'userId',
        lower: [null],
        includeLower: false,
        upper: [],
      ));
    });
  }

  QueryBuilder<PhysiologicalBaseline, PhysiologicalBaseline, QAfterWhereClause>
      userIdEqualTo(String? userId) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'userId',
        value: [userId],
      ));
    });
  }

  QueryBuilder<PhysiologicalBaseline, PhysiologicalBaseline, QAfterWhereClause>
      userIdNotEqualTo(String? userId) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'userId',
              lower: [],
              upper: [userId],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'userId',
              lower: [userId],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'userId',
              lower: [userId],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'userId',
              lower: [],
              upper: [userId],
              includeUpper: false,
            ));
      }
    });
  }
}

extension PhysiologicalBaselineQueryFilter on QueryBuilder<
    PhysiologicalBaseline, PhysiologicalBaseline, QFilterCondition> {
  QueryBuilder<PhysiologicalBaseline, PhysiologicalBaseline,
      QAfterFilterCondition> bloodOxygenLevelIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'bloodOxygenLevel',
      ));
    });
  }

  QueryBuilder<PhysiologicalBaseline, PhysiologicalBaseline,
      QAfterFilterCondition> bloodOxygenLevelIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'bloodOxygenLevel',
      ));
    });
  }

  QueryBuilder<PhysiologicalBaseline, PhysiologicalBaseline,
      QAfterFilterCondition> bloodOxygenLevelEqualTo(
    double? value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'bloodOxygenLevel',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<PhysiologicalBaseline, PhysiologicalBaseline,
      QAfterFilterCondition> bloodOxygenLevelGreaterThan(
    double? value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'bloodOxygenLevel',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<PhysiologicalBaseline, PhysiologicalBaseline,
      QAfterFilterCondition> bloodOxygenLevelLessThan(
    double? value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'bloodOxygenLevel',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<PhysiologicalBaseline, PhysiologicalBaseline,
      QAfterFilterCondition> bloodOxygenLevelBetween(
    double? lower,
    double? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'bloodOxygenLevel',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<PhysiologicalBaseline, PhysiologicalBaseline,
      QAfterFilterCondition> bodyTemperatureIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'bodyTemperature',
      ));
    });
  }

  QueryBuilder<PhysiologicalBaseline, PhysiologicalBaseline,
      QAfterFilterCondition> bodyTemperatureIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'bodyTemperature',
      ));
    });
  }

  QueryBuilder<PhysiologicalBaseline, PhysiologicalBaseline,
      QAfterFilterCondition> bodyTemperatureEqualTo(
    double? value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'bodyTemperature',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<PhysiologicalBaseline, PhysiologicalBaseline,
      QAfterFilterCondition> bodyTemperatureGreaterThan(
    double? value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'bodyTemperature',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<PhysiologicalBaseline, PhysiologicalBaseline,
      QAfterFilterCondition> bodyTemperatureLessThan(
    double? value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'bodyTemperature',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<PhysiologicalBaseline, PhysiologicalBaseline,
      QAfterFilterCondition> bodyTemperatureBetween(
    double? lower,
    double? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'bodyTemperature',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<PhysiologicalBaseline, PhysiologicalBaseline,
      QAfterFilterCondition> diastolicBloodPressureIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'diastolicBloodPressure',
      ));
    });
  }

  QueryBuilder<PhysiologicalBaseline, PhysiologicalBaseline,
      QAfterFilterCondition> diastolicBloodPressureIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'diastolicBloodPressure',
      ));
    });
  }

  QueryBuilder<PhysiologicalBaseline, PhysiologicalBaseline,
      QAfterFilterCondition> diastolicBloodPressureEqualTo(int? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'diastolicBloodPressure',
        value: value,
      ));
    });
  }

  QueryBuilder<PhysiologicalBaseline, PhysiologicalBaseline,
      QAfterFilterCondition> diastolicBloodPressureGreaterThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'diastolicBloodPressure',
        value: value,
      ));
    });
  }

  QueryBuilder<PhysiologicalBaseline, PhysiologicalBaseline,
      QAfterFilterCondition> diastolicBloodPressureLessThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'diastolicBloodPressure',
        value: value,
      ));
    });
  }

  QueryBuilder<PhysiologicalBaseline, PhysiologicalBaseline,
      QAfterFilterCondition> diastolicBloodPressureBetween(
    int? lower,
    int? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'diastolicBloodPressure',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<PhysiologicalBaseline, PhysiologicalBaseline,
      QAfterFilterCondition> idEqualTo(Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<PhysiologicalBaseline, PhysiologicalBaseline,
      QAfterFilterCondition> idGreaterThan(
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

  QueryBuilder<PhysiologicalBaseline, PhysiologicalBaseline,
      QAfterFilterCondition> idLessThan(
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

  QueryBuilder<PhysiologicalBaseline, PhysiologicalBaseline,
      QAfterFilterCondition> idBetween(
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

  QueryBuilder<PhysiologicalBaseline, PhysiologicalBaseline,
      QAfterFilterCondition> respirationRateIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'respirationRate',
      ));
    });
  }

  QueryBuilder<PhysiologicalBaseline, PhysiologicalBaseline,
      QAfterFilterCondition> respirationRateIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'respirationRate',
      ));
    });
  }

  QueryBuilder<PhysiologicalBaseline, PhysiologicalBaseline,
      QAfterFilterCondition> respirationRateEqualTo(int? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'respirationRate',
        value: value,
      ));
    });
  }

  QueryBuilder<PhysiologicalBaseline, PhysiologicalBaseline,
      QAfterFilterCondition> respirationRateGreaterThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'respirationRate',
        value: value,
      ));
    });
  }

  QueryBuilder<PhysiologicalBaseline, PhysiologicalBaseline,
      QAfterFilterCondition> respirationRateLessThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'respirationRate',
        value: value,
      ));
    });
  }

  QueryBuilder<PhysiologicalBaseline, PhysiologicalBaseline,
      QAfterFilterCondition> respirationRateBetween(
    int? lower,
    int? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'respirationRate',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<PhysiologicalBaseline, PhysiologicalBaseline,
      QAfterFilterCondition> restingHeartRateIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'restingHeartRate',
      ));
    });
  }

  QueryBuilder<PhysiologicalBaseline, PhysiologicalBaseline,
      QAfterFilterCondition> restingHeartRateIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'restingHeartRate',
      ));
    });
  }

  QueryBuilder<PhysiologicalBaseline, PhysiologicalBaseline,
      QAfterFilterCondition> restingHeartRateEqualTo(int? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'restingHeartRate',
        value: value,
      ));
    });
  }

  QueryBuilder<PhysiologicalBaseline, PhysiologicalBaseline,
      QAfterFilterCondition> restingHeartRateGreaterThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'restingHeartRate',
        value: value,
      ));
    });
  }

  QueryBuilder<PhysiologicalBaseline, PhysiologicalBaseline,
      QAfterFilterCondition> restingHeartRateLessThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'restingHeartRate',
        value: value,
      ));
    });
  }

  QueryBuilder<PhysiologicalBaseline, PhysiologicalBaseline,
      QAfterFilterCondition> restingHeartRateBetween(
    int? lower,
    int? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'restingHeartRate',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<PhysiologicalBaseline, PhysiologicalBaseline,
      QAfterFilterCondition> systolicBloodPressureIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'systolicBloodPressure',
      ));
    });
  }

  QueryBuilder<PhysiologicalBaseline, PhysiologicalBaseline,
      QAfterFilterCondition> systolicBloodPressureIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'systolicBloodPressure',
      ));
    });
  }

  QueryBuilder<PhysiologicalBaseline, PhysiologicalBaseline,
      QAfterFilterCondition> systolicBloodPressureEqualTo(int? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'systolicBloodPressure',
        value: value,
      ));
    });
  }

  QueryBuilder<PhysiologicalBaseline, PhysiologicalBaseline,
      QAfterFilterCondition> systolicBloodPressureGreaterThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'systolicBloodPressure',
        value: value,
      ));
    });
  }

  QueryBuilder<PhysiologicalBaseline, PhysiologicalBaseline,
      QAfterFilterCondition> systolicBloodPressureLessThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'systolicBloodPressure',
        value: value,
      ));
    });
  }

  QueryBuilder<PhysiologicalBaseline, PhysiologicalBaseline,
      QAfterFilterCondition> systolicBloodPressureBetween(
    int? lower,
    int? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'systolicBloodPressure',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<PhysiologicalBaseline, PhysiologicalBaseline,
      QAfterFilterCondition> updatedAtIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'updatedAt',
      ));
    });
  }

  QueryBuilder<PhysiologicalBaseline, PhysiologicalBaseline,
      QAfterFilterCondition> updatedAtIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'updatedAt',
      ));
    });
  }

  QueryBuilder<PhysiologicalBaseline, PhysiologicalBaseline,
      QAfterFilterCondition> updatedAtEqualTo(DateTime? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'updatedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<PhysiologicalBaseline, PhysiologicalBaseline,
      QAfterFilterCondition> updatedAtGreaterThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'updatedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<PhysiologicalBaseline, PhysiologicalBaseline,
      QAfterFilterCondition> updatedAtLessThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'updatedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<PhysiologicalBaseline, PhysiologicalBaseline,
      QAfterFilterCondition> updatedAtBetween(
    DateTime? lower,
    DateTime? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'updatedAt',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<PhysiologicalBaseline, PhysiologicalBaseline,
      QAfterFilterCondition> userIdIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'userId',
      ));
    });
  }

  QueryBuilder<PhysiologicalBaseline, PhysiologicalBaseline,
      QAfterFilterCondition> userIdIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'userId',
      ));
    });
  }

  QueryBuilder<PhysiologicalBaseline, PhysiologicalBaseline,
      QAfterFilterCondition> userIdEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'userId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PhysiologicalBaseline, PhysiologicalBaseline,
      QAfterFilterCondition> userIdGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'userId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PhysiologicalBaseline, PhysiologicalBaseline,
      QAfterFilterCondition> userIdLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'userId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PhysiologicalBaseline, PhysiologicalBaseline,
      QAfterFilterCondition> userIdBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'userId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PhysiologicalBaseline, PhysiologicalBaseline,
      QAfterFilterCondition> userIdStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'userId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PhysiologicalBaseline, PhysiologicalBaseline,
      QAfterFilterCondition> userIdEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'userId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PhysiologicalBaseline, PhysiologicalBaseline,
          QAfterFilterCondition>
      userIdContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'userId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PhysiologicalBaseline, PhysiologicalBaseline,
          QAfterFilterCondition>
      userIdMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'userId',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PhysiologicalBaseline, PhysiologicalBaseline,
      QAfterFilterCondition> userIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'userId',
        value: '',
      ));
    });
  }

  QueryBuilder<PhysiologicalBaseline, PhysiologicalBaseline,
      QAfterFilterCondition> userIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'userId',
        value: '',
      ));
    });
  }
}

extension PhysiologicalBaselineQueryObject on QueryBuilder<
    PhysiologicalBaseline, PhysiologicalBaseline, QFilterCondition> {}

extension PhysiologicalBaselineQueryLinks on QueryBuilder<PhysiologicalBaseline,
    PhysiologicalBaseline, QFilterCondition> {}

extension PhysiologicalBaselineQuerySortBy
    on QueryBuilder<PhysiologicalBaseline, PhysiologicalBaseline, QSortBy> {
  QueryBuilder<PhysiologicalBaseline, PhysiologicalBaseline, QAfterSortBy>
      sortByBloodOxygenLevel() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'bloodOxygenLevel', Sort.asc);
    });
  }

  QueryBuilder<PhysiologicalBaseline, PhysiologicalBaseline, QAfterSortBy>
      sortByBloodOxygenLevelDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'bloodOxygenLevel', Sort.desc);
    });
  }

  QueryBuilder<PhysiologicalBaseline, PhysiologicalBaseline, QAfterSortBy>
      sortByBodyTemperature() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'bodyTemperature', Sort.asc);
    });
  }

  QueryBuilder<PhysiologicalBaseline, PhysiologicalBaseline, QAfterSortBy>
      sortByBodyTemperatureDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'bodyTemperature', Sort.desc);
    });
  }

  QueryBuilder<PhysiologicalBaseline, PhysiologicalBaseline, QAfterSortBy>
      sortByDiastolicBloodPressure() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'diastolicBloodPressure', Sort.asc);
    });
  }

  QueryBuilder<PhysiologicalBaseline, PhysiologicalBaseline, QAfterSortBy>
      sortByDiastolicBloodPressureDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'diastolicBloodPressure', Sort.desc);
    });
  }

  QueryBuilder<PhysiologicalBaseline, PhysiologicalBaseline, QAfterSortBy>
      sortByRespirationRate() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'respirationRate', Sort.asc);
    });
  }

  QueryBuilder<PhysiologicalBaseline, PhysiologicalBaseline, QAfterSortBy>
      sortByRespirationRateDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'respirationRate', Sort.desc);
    });
  }

  QueryBuilder<PhysiologicalBaseline, PhysiologicalBaseline, QAfterSortBy>
      sortByRestingHeartRate() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'restingHeartRate', Sort.asc);
    });
  }

  QueryBuilder<PhysiologicalBaseline, PhysiologicalBaseline, QAfterSortBy>
      sortByRestingHeartRateDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'restingHeartRate', Sort.desc);
    });
  }

  QueryBuilder<PhysiologicalBaseline, PhysiologicalBaseline, QAfterSortBy>
      sortBySystolicBloodPressure() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'systolicBloodPressure', Sort.asc);
    });
  }

  QueryBuilder<PhysiologicalBaseline, PhysiologicalBaseline, QAfterSortBy>
      sortBySystolicBloodPressureDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'systolicBloodPressure', Sort.desc);
    });
  }

  QueryBuilder<PhysiologicalBaseline, PhysiologicalBaseline, QAfterSortBy>
      sortByUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.asc);
    });
  }

  QueryBuilder<PhysiologicalBaseline, PhysiologicalBaseline, QAfterSortBy>
      sortByUpdatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.desc);
    });
  }

  QueryBuilder<PhysiologicalBaseline, PhysiologicalBaseline, QAfterSortBy>
      sortByUserId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'userId', Sort.asc);
    });
  }

  QueryBuilder<PhysiologicalBaseline, PhysiologicalBaseline, QAfterSortBy>
      sortByUserIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'userId', Sort.desc);
    });
  }
}

extension PhysiologicalBaselineQuerySortThenBy
    on QueryBuilder<PhysiologicalBaseline, PhysiologicalBaseline, QSortThenBy> {
  QueryBuilder<PhysiologicalBaseline, PhysiologicalBaseline, QAfterSortBy>
      thenByBloodOxygenLevel() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'bloodOxygenLevel', Sort.asc);
    });
  }

  QueryBuilder<PhysiologicalBaseline, PhysiologicalBaseline, QAfterSortBy>
      thenByBloodOxygenLevelDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'bloodOxygenLevel', Sort.desc);
    });
  }

  QueryBuilder<PhysiologicalBaseline, PhysiologicalBaseline, QAfterSortBy>
      thenByBodyTemperature() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'bodyTemperature', Sort.asc);
    });
  }

  QueryBuilder<PhysiologicalBaseline, PhysiologicalBaseline, QAfterSortBy>
      thenByBodyTemperatureDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'bodyTemperature', Sort.desc);
    });
  }

  QueryBuilder<PhysiologicalBaseline, PhysiologicalBaseline, QAfterSortBy>
      thenByDiastolicBloodPressure() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'diastolicBloodPressure', Sort.asc);
    });
  }

  QueryBuilder<PhysiologicalBaseline, PhysiologicalBaseline, QAfterSortBy>
      thenByDiastolicBloodPressureDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'diastolicBloodPressure', Sort.desc);
    });
  }

  QueryBuilder<PhysiologicalBaseline, PhysiologicalBaseline, QAfterSortBy>
      thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<PhysiologicalBaseline, PhysiologicalBaseline, QAfterSortBy>
      thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<PhysiologicalBaseline, PhysiologicalBaseline, QAfterSortBy>
      thenByRespirationRate() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'respirationRate', Sort.asc);
    });
  }

  QueryBuilder<PhysiologicalBaseline, PhysiologicalBaseline, QAfterSortBy>
      thenByRespirationRateDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'respirationRate', Sort.desc);
    });
  }

  QueryBuilder<PhysiologicalBaseline, PhysiologicalBaseline, QAfterSortBy>
      thenByRestingHeartRate() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'restingHeartRate', Sort.asc);
    });
  }

  QueryBuilder<PhysiologicalBaseline, PhysiologicalBaseline, QAfterSortBy>
      thenByRestingHeartRateDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'restingHeartRate', Sort.desc);
    });
  }

  QueryBuilder<PhysiologicalBaseline, PhysiologicalBaseline, QAfterSortBy>
      thenBySystolicBloodPressure() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'systolicBloodPressure', Sort.asc);
    });
  }

  QueryBuilder<PhysiologicalBaseline, PhysiologicalBaseline, QAfterSortBy>
      thenBySystolicBloodPressureDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'systolicBloodPressure', Sort.desc);
    });
  }

  QueryBuilder<PhysiologicalBaseline, PhysiologicalBaseline, QAfterSortBy>
      thenByUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.asc);
    });
  }

  QueryBuilder<PhysiologicalBaseline, PhysiologicalBaseline, QAfterSortBy>
      thenByUpdatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.desc);
    });
  }

  QueryBuilder<PhysiologicalBaseline, PhysiologicalBaseline, QAfterSortBy>
      thenByUserId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'userId', Sort.asc);
    });
  }

  QueryBuilder<PhysiologicalBaseline, PhysiologicalBaseline, QAfterSortBy>
      thenByUserIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'userId', Sort.desc);
    });
  }
}

extension PhysiologicalBaselineQueryWhereDistinct
    on QueryBuilder<PhysiologicalBaseline, PhysiologicalBaseline, QDistinct> {
  QueryBuilder<PhysiologicalBaseline, PhysiologicalBaseline, QDistinct>
      distinctByBloodOxygenLevel() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'bloodOxygenLevel');
    });
  }

  QueryBuilder<PhysiologicalBaseline, PhysiologicalBaseline, QDistinct>
      distinctByBodyTemperature() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'bodyTemperature');
    });
  }

  QueryBuilder<PhysiologicalBaseline, PhysiologicalBaseline, QDistinct>
      distinctByDiastolicBloodPressure() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'diastolicBloodPressure');
    });
  }

  QueryBuilder<PhysiologicalBaseline, PhysiologicalBaseline, QDistinct>
      distinctByRespirationRate() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'respirationRate');
    });
  }

  QueryBuilder<PhysiologicalBaseline, PhysiologicalBaseline, QDistinct>
      distinctByRestingHeartRate() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'restingHeartRate');
    });
  }

  QueryBuilder<PhysiologicalBaseline, PhysiologicalBaseline, QDistinct>
      distinctBySystolicBloodPressure() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'systolicBloodPressure');
    });
  }

  QueryBuilder<PhysiologicalBaseline, PhysiologicalBaseline, QDistinct>
      distinctByUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'updatedAt');
    });
  }

  QueryBuilder<PhysiologicalBaseline, PhysiologicalBaseline, QDistinct>
      distinctByUserId({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'userId', caseSensitive: caseSensitive);
    });
  }
}

extension PhysiologicalBaselineQueryProperty on QueryBuilder<
    PhysiologicalBaseline, PhysiologicalBaseline, QQueryProperty> {
  QueryBuilder<PhysiologicalBaseline, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<PhysiologicalBaseline, double?, QQueryOperations>
      bloodOxygenLevelProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'bloodOxygenLevel');
    });
  }

  QueryBuilder<PhysiologicalBaseline, double?, QQueryOperations>
      bodyTemperatureProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'bodyTemperature');
    });
  }

  QueryBuilder<PhysiologicalBaseline, int?, QQueryOperations>
      diastolicBloodPressureProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'diastolicBloodPressure');
    });
  }

  QueryBuilder<PhysiologicalBaseline, int?, QQueryOperations>
      respirationRateProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'respirationRate');
    });
  }

  QueryBuilder<PhysiologicalBaseline, int?, QQueryOperations>
      restingHeartRateProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'restingHeartRate');
    });
  }

  QueryBuilder<PhysiologicalBaseline, int?, QQueryOperations>
      systolicBloodPressureProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'systolicBloodPressure');
    });
  }

  QueryBuilder<PhysiologicalBaseline, DateTime?, QQueryOperations>
      updatedAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'updatedAt');
    });
  }

  QueryBuilder<PhysiologicalBaseline, String?, QQueryOperations>
      userIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'userId');
    });
  }
}
