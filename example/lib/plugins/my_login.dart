class MyLogin {
  MyLogin._internal();

  static final MyLogin instance = MyLogin._internal();

  late String _token;

  String get token => _token;

  set token(String value) {
    _token = value;
  }
}
