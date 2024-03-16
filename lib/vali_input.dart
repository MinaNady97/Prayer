import 'package:get/get.dart';

validatefunc_input(String value, int min, int max, String type) {
  if (value.isEmpty) {
    return "cant be empty";
  } else {
    if (type == "username") {
      String username = value.trim();
      RegExp validUsername =
          RegExp(r'^[a-zA-Z\u0600-\u06FF]+(?: [a-zA-Z\u0600-\u06FF]+)*$');
      if (!validUsername.hasMatch(username)) {
        return "not valid user name";
      }
    }
    if (type == "times" || type == "notifications") {
      if (value.length < min || value.length > max) {
        return "the value must be between $min and $max ";
      }
    }
  }
}
