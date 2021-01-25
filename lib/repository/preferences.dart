part of 'repository.dart';

class Preferences{

  Preferences._();

  static final Preferences preferences = Preferences._();

  ///lastDailyReportDate holds the actual Date a daily report was last prepared
  int _lastDailyReportDate;

  ///lastWeeklyReportDate holds the week number of the last weekly report
  int _lastWeeklyReportDate;

  ///lastMonthlyReportDate holds year.month a monthly report was last prepared.
  ///_lastMonthlyReportDate is formatted as year.month
  double _lastMonthlyReportDate;

  ///lastYearlyReportDate holds the year a yearly report was last prepared
  ///lastYearlyReportDate is formatted as year.0
  double _lastYearlyReportDate;

  //These two fields help with the middle nav bar. They specifically contain the date which trackit was first started
  int _oldestIncomeDate;
  int _oldestExpenseDate;

  //currency is the currency symbol chosen by user
  String _currency;

  double get lastYearlyReportDate => _lastYearlyReportDate;
  double get lastMonthlyReportDate => _lastMonthlyReportDate;
  int get lastWeeklyReportDate => _lastWeeklyReportDate;
  DateTime get lastDailyReportDate => DateTime.fromMillisecondsSinceEpoch(_lastDailyReportDate);
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
    preferences._initLastReportDates(sharedPrefs);
  }

  void _initLastReportDates (SharedPreferences sharedPrefs) {
    _lastDailyReportDate = sharedPrefs.getInt(_Keys._lastDailyReportDate);
    _lastWeeklyReportDate = sharedPrefs.getInt(_Keys._lastWeeklyReportDate);
    _lastMonthlyReportDate = sharedPrefs.getDouble(_Keys._lastMonthlyReportDate);
    _lastYearlyReportDate = sharedPrefs.getDouble(_Keys._lastYearlyReportDate);

    if (_lastDailyReportDate == null) {
      final DateTime d = DateTime.now().subtract(Duration(days: 1));

      //initializing _lastDailyReportDate to yesterday enables trackit to generate its first report tomorrow
      //and the generated report will be todays report. 
      //This makes sense because trackit would assume it has generated report for the day before app was opened for the first time 
      _lastDailyReportDate = DateTime(d.year, d.month, d.day).millisecondsSinceEpoch;
      sharedPrefs.setInt(_Keys._lastDailyReportDate, _lastDailyReportDate);
    }

    if (_lastWeeklyReportDate == null) {

      //initializing lastWeeklyReportDate to the last week enables trackit to generate its first weekly report next week
      //and the generated report will be for this week.
      //This makes sense because trackit would assume it has generated report for the week before app was opened for the first time
      //and its first weekly report would be the report of the week the app was first opened
      Weeks weeks = Weeks(inYear: Year(DateTime.now().year));
      _lastWeeklyReportDate = weeks.getWeekByDate(DateTime.now()).number-1;
      sharedPrefs.setInt(_Keys._lastWeeklyReportDate, _lastWeeklyReportDate);
    }

    if (_lastMonthlyReportDate == null) {

      //initializing lastMonthlyReportDate to last month enables trackit generate its first monthly report next month
      //and the generated report will be for this month.
      //This makes sense because trackit would assume it has generated report for the month before app was opened for the first time
      //and its first monthly report would be the report of the month the app was first opened
      if(DateTime.now().month == 1) {
        _lastMonthlyReportDate = DateTime.now().year-1 + 0.12;
      }
      else {
        final int month = DateTime.now().month;
        _lastMonthlyReportDate = DateTime.now().year + double.parse("0.$month");
      }
      sharedPrefs.setDouble(_Keys._lastMonthlyReportDate, _lastMonthlyReportDate);
    }

    if (_lastYearlyReportDate == null) {

      //initializing lastYearlyReportDate to last month enables trackit generate its first yearly report next year
      //and the generated report will be for this year.
      //This makes sense because trackit would assume it has generated report for the year before app was opened for the first time
      //and its first yearly report would be the report of the year the app was first opened
      _lastYearlyReportDate = DateTime.now().year -1.0;
      sharedPrefs.setDouble(_Keys._lastYearlyReportDate, _lastYearlyReportDate);
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

  void setLastDailyReportDate (DateTime lastDailyReportDate) async {
    _lastDailyReportDate = lastDailyReportDate.millisecondsSinceEpoch;
    final SharedPreferences sharedPrefs = await SharedPreferences.getInstance();
    sharedPrefs.setInt(_Keys._lastDailyReportDate, _lastDailyReportDate);
  }

  void setLastWeeklyReportDate (int lastWeeklyReportDate) async {
    _lastWeeklyReportDate = lastWeeklyReportDate;
    final SharedPreferences sharedPrefs = await SharedPreferences.getInstance();
    sharedPrefs.setInt(_Keys._lastWeeklyReportDate, _lastWeeklyReportDate);
  }

  void setLastMonthlyReportDate (double lastMonthlyReportDate) async {
    _lastMonthlyReportDate = lastMonthlyReportDate;
    final SharedPreferences sharedPrefs = await SharedPreferences.getInstance();
    sharedPrefs.setDouble(_Keys._lastMonthlyReportDate, _lastMonthlyReportDate);
  }

  void setLastYearlyReportDate (double lastYearlyReportDate) async {
    _lastYearlyReportDate = lastYearlyReportDate;
    final SharedPreferences sharedPrefs = await SharedPreferences.getInstance();
    sharedPrefs.setDouble(_Keys._lastYearlyReportDate, _lastYearlyReportDate);
  }

  void _initCurrency(SharedPreferences sharedPrefs) {
    _currency = sharedPrefs.getString(_Keys._currencySymbol);
    if (_currency == null ) {
      _currency = "\$";
    }
  }
}

class _Keys{
  static const String _lastYearlyReportDate = "lastYearlyReportDate";
  static const String _lastMonthlyReportDate = "lastMonthlyReportDate";
  static const String _lastWeeklyReportDate = "lastWeeklyReportDate";
  static const String _lastDailyReportDate = "lastReportDate";
  static const String _currencySymbol = "currencySymbol";
  static const String _oldestExpenseDate = "oldestExpenseDate";
  static const String _oldestIncomeDate = "oldestIncomeDate";
}