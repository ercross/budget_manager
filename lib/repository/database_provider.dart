part of 'repository.dart';

class DatabaseProvider {
  static const String _databaseName = "trackIt.db";
  static const int _databaseVersion = 1;

  DatabaseProvider._();

  static final DatabaseProvider databaseProvider = DatabaseProvider._();

  static Database _databaseDriver;

  Future<Database> _getDatabaseDriver () async {
    if (_databaseDriver != null) {
      return _databaseDriver;
    }
    return _databaseDriver = await _initializeDatabase();
  }

  Future<Database> _initializeDatabase() async {
    String dbPath = await getDatabasesPath();
    return await openDatabase(
      join(dbPath, _databaseName),
      onCreate: (Database database, int version) { 
        ExpenseTable.create(database, version);
        IncomeTable.create(database, version);
        BudgetTable.create(database, version);
        ReportTable.create(database, version);
      },
      version: _databaseVersion);
  }

  Future<void> insert (String tableName, Map<String, dynamic> item) async {
    final Database db = await _getDatabaseDriver();
    await db.insert(tableName, item);
  }

  ///Target rows are specified through where and whereArgs.
  ///@param->where should be formatted like this: "targetColumn=?" and the number of question marks should tally with the number of arguments in @List.targetValues
  ///where: "id=?", whereArgs: [id]
  ///@param->targetValues specifies the data to find in the targetColumn. Any row on which any of the targetValues is found will be deleted
  Future<void> delete ({@required String tableName, String where, List<dynamic> targetValues}) async {
    final Database db = await _getDatabaseDriver();
    await db.delete (tableName, where: where, whereArgs: targetValues);
  }

  ///getAll fetches all rows of the database or fetches item specified through where and whereArgs
  ///if where and whereArgs are null, the whole table item is returned
  ///if passing date in whereArgs, ensure to convert time to millisecondsSinceEpoch
  Future<List<Map<String, dynamic>>> fetch (String tableName, {String where, List<dynamic> whereArgs}) async {
    final Database db = await _getDatabaseDriver();
    return await db.query(tableName, where: where, whereArgs: whereArgs);
  }

  ///whereArgs is a list of occurrence to find on each row
  ///where shoul be formatted like so where: "id=?" if the search is to be done by id 
  Future<List<List<Map<String, dynamic>>>> batchFetch (String tableName, String where, List<DateTime> whereArgs) async {
    final Database db = await _getDatabaseDriver();
    final Batch batch = db.batch();
    for (int i=0; i<whereArgs.length; i++) {
      batch.query(tableName, where: where, whereArgs: [whereArgs[i].millisecondsSinceEpoch]);
    }
    return (await batch.commit(noResult: false)).cast<List<Map<String, dynamic>>>();
  }

  Future<void> close() async => await _databaseDriver.close();
}