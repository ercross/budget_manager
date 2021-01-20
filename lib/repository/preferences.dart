part of 'repository.dart';

class Preferences{

  Preferences._();

  static final Preferences preferences = Preferences._();

  int _lastReportDate;
  int _oldestIncomeDate;
  int _oldestExpenseDate;
  String _currency;

  DateTime get lastReportDate => DateTime.fromMicrosecondsSinceEpoch(_lastReportDate);
  DateTime get oldestIncomeDate => DateTime.fromMillisecondsSinceEpoch(_oldestIncomeDate);
  DateTime get oldestExpenseDate => DateTime.fromMillisecondsSinceEpoch(_oldestExpenseDate);
  String get currency => _currency;

  Future setCurrency (String newCurrency) async {
    _currency = newCurrency;
    final SharedPreferences sharedPrefs = await SharedPreferences.getInstance();
    sharedPrefs.setString(_Keys._currencySymbol, _currency);
  }

  ///loadSettings initializes all settings variable to either a default value or the value previously entered by user
  ///loadSettings must be invoked on application start
  static Future<void> loadSettings () async {
    final sharedPrefs = await SharedPreferences.getInstance();
    preferences._initCurrency(sharedPrefs);
    preferences._initOldestExpenseDate(sharedPrefs);
    preferences._initOldestIncomeDate(sharedPrefs);
    preferences._initLastReportDate(sharedPrefs);
  }

  void _initLastReportDate (SharedPreferences sharedPrefs) {
    _lastReportDate = sharedPrefs.getInt(_Keys._lastReportDate);
    if (_lastReportDate == null) {
      final DateTime d = DateTime.now();

      //setting _lastReportDate to today on first initialization enables trackit to generate its first report tomorrow
      //and the generated report will be todays report
      _lastReportDate = DateTime(d.year, d.month, d.day).millisecondsSinceEpoch;
      sharedPrefs.setInt(_Keys._lastReportDate, _lastReportDate);
    }
  }

  void _initOldestExpenseDate (SharedPreferences sharedPrefs) {
    _oldestExpenseDate = sharedPrefs.getInt(_Keys._oldestExpenseDate);
    if (_oldestExpenseDate == null) {
      final DateTime d = DateTime.now();
      _oldestExpenseDate = DateTime(d.year, d.month, d.day).millisecondsSinceEpoch;
      sharedPrefs.setInt(_Keys._oldestExpenseDate, _oldestExpenseDate);
    }
  }

  void _initOldestIncomeDate (SharedPreferences sharedPrefs) {
    _oldestIncomeDate = sharedPrefs.getInt (_Keys._oldestIncomeDate);
    if (_oldestIncomeDate == null) {
       _oldestIncomeDate  = DateTime(DateTime.now().year, DateTime.now().month).millisecondsSinceEpoch;
       sharedPrefs.setInt(_Keys._oldestIncomeDate, _oldestIncomeDate);
    }
  }

  //setOldestIncomeDate is invoked when a new added income.date.isBefore(_oldestIncomeDate)
  void setOldestIncomeDate (DateTime oldestDate) async {
    _oldestIncomeDate = oldestDate.millisecondsSinceEpoch;
    final SharedPreferences sharedPrefs = await SharedPreferences.getInstance();
    sharedPrefs.setInt(_Keys._oldestIncomeDate, _oldestIncomeDate);
  }

  void setLastReportDate (DateTime lastReportDate) async {
    _lastReportDate = lastReportDate.millisecondsSinceEpoch;
    final SharedPreferences sharedPrefs = await SharedPreferences.getInstance();
    sharedPrefs.setInt(_Keys._lastReportDate, _lastReportDate);
  }

  //setOldestExpenseDate is invoked when new expenses are added
  void setOldestExpenseDate (DateTime oldestDate) async {
    _oldestExpenseDate = oldestDate.millisecondsSinceEpoch;
    final SharedPreferences sharedPrefs = await SharedPreferences.getInstance();
    sharedPrefs.setInt(_Keys._oldestExpenseDate, _oldestExpenseDate);
  }

  void _initCurrency(SharedPreferences sharedPrefs) {
    _currency = sharedPrefs.getString(_Keys._currencySymbol);
    if (_currency == null ) {
      _currency = "\$";
    }
  }
}

class _Keys{
  static const String _lastReportDate = "lastReportDate";
  static const String _currencySymbol = "currencySymbol";
  static const String _oldestExpenseDate = "oldestExpenseDate";
  static const String _oldestIncomeDate = "oldestIncomeDate";
}