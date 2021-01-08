part of 'repository.dart';

class Preferences{

  Preferences._();

  static final Preferences preferences = Preferences._();

  //all settings variable stored in shared_preferences
  //direct access not provided to ensure proper initialization before use
  //and update should also update the value in sharedPreferences 
   ChartDataDateRange _chartDataDateRange;
   int _oldestDate;
   bool _dateRangeAutoGen;
   String _currencySymbol;

  DateTime get oldestDate => DateTime.fromMillisecondsSinceEpoch(_oldestDate);
  ChartDataDateRange get chartDataDateRange => _chartDataDateRange;
  bool get dateRangeAutoGen => _dateRangeAutoGen;
  String get currencySymbol => _currencySymbol;

  Future toggleDateRangeAutoGen (bool autoGen) async {
    _dateRangeAutoGen = autoGen;
    final SharedPreferences sharedPrefs = await SharedPreferences.getInstance();
    sharedPrefs.setBool(_Keys._dateRangeAutoGen, _dateRangeAutoGen);
  }

  Future setCurrencySymbol (String newSymbol) async {
    _currencySymbol = newSymbol;
    final SharedPreferences sharedPrefs = await SharedPreferences.getInstance();
    sharedPrefs.setString(_Keys._currencySymbol, _currencySymbol);
  }

  ///initsharedPrefs initializes all settings variable to either a default value or the value previously entered by user
  ///initsharedPrefs must be invoked on application start
  static Future<void> loadSettings () async {
    final sharedPrefs = await SharedPreferences.getInstance();
    preferences._initDateRangeAutoGen(sharedPrefs);
    preferences._initChartDataDateRange(sharedPrefs, preferences._dateRangeAutoGen);
    preferences._initCurrencySymbol(sharedPrefs);
    preferences._initOldestDate(sharedPrefs);
  }

  void _initOldestDate (SharedPreferences sharedPrefs) {
    _oldestDate = sharedPrefs.getInt(_Keys._oldestDate);
    if (_oldestDate == null) {
      final DateTime d = DateTime.now();
      _oldestDate = DateTime(d.year, d.month, d.day).millisecondsSinceEpoch;
    }
  }

  //setNewOldestDate is invoked when new expenses are added
  void setNewOldestDate (DateTime oldestDate) async {
    final int date = DateTime(oldestDate.year, oldestDate.month, oldestDate.day).millisecondsSinceEpoch;
    _oldestDate = date;
    final SharedPreferences sharedPrefs = await SharedPreferences.getInstance();
    sharedPrefs.setInt(_Keys._oldestDate, date);
  }

  void _initDateRangeAutoGen (SharedPreferences sharedPrefs) {
    _dateRangeAutoGen = sharedPrefs.getBool(_Keys._dateRangeAutoGen);
    if (_dateRangeAutoGen == null) {
      _dateRangeAutoGen = true;
      toggleDateRangeAutoGen(_dateRangeAutoGen);
      }
      
  }

  void _initCurrencySymbol(SharedPreferences sharedPrefs) {
    _currencySymbol = sharedPrefs.getString(_Keys._currencySymbol);
    if (_currencySymbol == null ) {
      _currencySymbol = "\$";
    }
  }

  void _initChartDataDateRange (SharedPreferences sharedPrefs, bool dateRangeAutoGen) {
    if (dateRangeAutoGen != null && dateRangeAutoGen == true) {
      _setDefaultDateRange(sharedPrefs);
      return;
    }

    //the code inside the if statement below is the same as that above, but will only run once when the app is started for the first time
    //the separation allows a quick return should dateRangeAutoGen be set to true
    _chartDataDateRange = _fetchChartDataDateRange(sharedPrefs); 
    if (_chartDataDateRange == null) {
      _setDefaultDateRange(sharedPrefs);
    }
  }

  //setDefaultTimeRange sets the time to the default value, i.e., auto generation of date range daily
  void _setDefaultDateRange(SharedPreferences sharedPrefs) {
    final DateTime date = DateTime.now();
    _setChartDataDateRange( 
      sharedPrefs: sharedPrefs, 
      chartDataDateRange: ChartDataDateRange(
        toDate: DateTime(date.year, date.month, date.day),
        fromDate: DateTime(date.year, date.month, date.day).subtract(Duration(days: 6)))
    );
  }

  ///fetchChartDataDateRange() returns null if chartDataDateRange is null
  ChartDataDateRange _fetchChartDataDateRange(SharedPreferences sharedPrefs) {
    final textRep = sharedPrefs.getString(_Keys._chartDataDateRange);
    if (textRep != null) {
      final Map<String, dynamic> map = jsonDecode(textRep) as Map<String, dynamic>;
      if (map != null) {
        return ChartDataDateRange.fromMap(map);
      }
    }
    return null;
  }

  Future<void> setChartDataDateRange (ChartDataDateRange dateRange) async {
    final sharedPrefs = await SharedPreferences.getInstance();
    _setChartDataDateRange(sharedPrefs: sharedPrefs, chartDataDateRange: dateRange);
  }

  //this is the only method through which the value of the class static variable, _chartDataDateRange was set
  //@param sharedPrefs required to use the same instance of SharedPreference while calling this method in other private methods 
  Future<void> _setChartDataDateRange({@required SharedPreferences sharedPrefs, @required ChartDataDateRange chartDataDateRange}) async {
    _chartDataDateRange = chartDataDateRange;
    await sharedPrefs.setString(_Keys._chartDataDateRange, jsonEncode(chartDataDateRange.toMap()));
  }
}


class _Keys{
  static const String _chartDataDateRange = "chartDataDateRange";
  static const String _dateRangeAutoGen = "dateRangeAutoGen";
  static const String _currencySymbol = "currencySymbol";
  static const String _oldestDate = "oldestDate";
}