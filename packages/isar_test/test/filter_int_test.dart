import 'package:isar/isar.dart';
import 'package:isar_test/common.dart';
import 'package:isar_test/int_model.dart';
import 'package:test/test.dart';

void main() {
  group('Int filter', () {
    late Isar isar;
    late IsarCollection<IntModel> col;

    late IntModel obj0;
    late IntModel obj1;
    late IntModel obj2;
    late IntModel obj3;
    late IntModel obj4;
    late IntModel objNull;

    setUp(() async {
      isar = await openTempIsar([IntModelSchema]);
      col = isar.intModels;

      obj0 = IntModel()..field = 0;
      obj1 = IntModel()..field = 1;
      obj2 = IntModel()..field = 2;
      obj3 = IntModel()..field = 3;
      obj4 = IntModel()..field = 4;
      objNull = IntModel()..field = null;

      await isar.writeTxn((isar) async {
        await isar.intModels.putAll([obj4, obj0, obj2, obj3, obj1, objNull]);
      });
    });

    tearDown(() async {
      await isar.close();
    });

    isarTest('.equalTo()', () async {
      // where clause
      await qEqual(col.where().fieldEqualTo(2).findAll(), [obj2]);
      await qEqual(col.where().fieldEqualTo(null).findAll(), [objNull]);
      await qEqual(col.where().fieldEqualTo(5).findAll(), []);

      // filters
      await qEqualSet(col.filter().fieldEqualTo(2).findAll(), [obj2]);
      await qEqualSet(col.filter().fieldEqualTo(null).findAll(), [objNull]);
      await qEqualSet(col.filter().fieldEqualTo(5).findAll(), []);
    });

    isarTest('.greaterThan()', () async {
      // where clause
      await qEqual(col.where().fieldGreaterThan(3).findAll(), [obj4]);
      await qEqual(
        col.where().fieldGreaterThan(3, include: true).findAll(),
        [obj3, obj4],
      );
      await qEqual(
        col.where().fieldGreaterThan(null).findAll(),
        [obj0, obj1, obj2, obj3, obj4],
      );
      await qEqual(
        col.where().fieldGreaterThan(null, include: true).findAll(),
        [objNull, obj0, obj1, obj2, obj3, obj4],
      );
      await qEqual(col.where().fieldGreaterThan(4).findAll(), []);

      // filters
      await qEqualSet(col.filter().fieldGreaterThan(3).findAll(), [obj4]);
      await qEqualSet(
        col.filter().fieldGreaterThan(3, include: true).findAll(),
        [obj3, obj4],
      );
      await qEqualSet(
        col.filter().fieldGreaterThan(null).findAll(),
        [obj0, obj1, obj2, obj3, obj4],
      );
      await qEqualSet(
        col.filter().fieldGreaterThan(null, include: true).findAll(),
        [objNull, obj0, obj1, obj2, obj3, obj4],
      );
      await qEqualSet(col.filter().fieldGreaterThan(4).findAll(), []);
    });

    isarTest('.lessThan()', () async {
      // where clauses
      await qEqual(col.where().fieldLessThan(1).findAll(), [objNull, obj0]);
      await qEqual(col.where().fieldLessThan(null).findAll(), []);
      await qEqual(
        col.where().fieldLessThan(null, include: true).findAll(),
        [objNull],
      );

      // filters
      await qEqualSet(col.filter().fieldLessThan(1).findAll(), [objNull, obj0]);
      await qEqualSet(col.filter().fieldLessThan(null).findAll(), []);
      await qEqualSet(
        col.filter().fieldLessThan(null, include: true).findAll(),
        [objNull],
      );
    });

    isarTest('.between()', () async {
      // where clauses
      await qEqual(
        col.where().fieldBetween(1, 3).findAll(),
        [obj1, obj2, obj3],
      );
      await qEqual(
        col.where().fieldBetween(1, 3, includeLower: false).findAll(),
        [obj2, obj3],
      );
      await qEqual(
        col.where().fieldBetween(1, 3, includeUpper: false).findAll(),
        [obj1, obj2],
      );
      await qEqual(
        col
            .where()
            .fieldBetween(1, 3, includeLower: false, includeUpper: false)
            .findAll(),
        [obj2],
      );
      await qEqual(
        col.where().fieldBetween(null, 0).findAll(),
        [objNull, obj0],
      );
      await qEqual(col.where().fieldBetween(5, 6).findAll(), []);

      // filters
      await qEqualSet(
        col.filter().fieldBetween(1, 3).findAll(),
        [obj1, obj2, obj3],
      );
      await qEqualSet(
        col.filter().fieldBetween(1, 3, includeLower: false).findAll(),
        [obj2, obj3],
      );
      await qEqualSet(
        col.filter().fieldBetween(1, 3, includeUpper: false).findAll(),
        [obj1, obj2],
      );
      await qEqualSet(
        col
            .filter()
            .fieldBetween(1, 3, includeLower: false, includeUpper: false)
            .findAll(),
        [obj2],
      );
      await qEqualSet(
        col.filter().fieldBetween(null, 0).findAll(),
        [objNull, obj0],
      );
      await qEqualSet(col.filter().fieldBetween(5, 6).findAll(), []);
    });

    isarTest('.isNull() / .isNotNull()', () async {
      await qEqual(col.where().fieldIsNull().findAll(), [objNull]);
      await qEqual(
        col.where().fieldIsNotNull().findAll(),
        [obj0, obj1, obj2, obj3, obj4],
      );

      await qEqual(col.filter().fieldIsNull().findAll(), [objNull]);
    });
  });

  group('Float list filter', () {
    late Isar isar;
    late IsarCollection<IntModel> col;

    late IntModel objEmpty;
    late IntModel obj1;
    late IntModel obj2;
    late IntModel obj3;
    late IntModel objNull;

    setUp(() async {
      isar = await openTempIsar([IntModelSchema]);
      col = isar.intModels;

      objEmpty = IntModel()..list = [];
      obj1 = IntModel()..list = [-1, 5, 10];
      obj2 = IntModel()..list = [null];
      obj3 = IntModel()..list = [null, 5, 8];
      objNull = IntModel()..list = null;

      await isar.writeTxn((isar) async {
        await col.putAll([objEmpty, obj1, obj3, obj2, objNull]);
      });
    });
  });
}
