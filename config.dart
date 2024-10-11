import 'users.dart';

class Configure {
  //10.0.2.2 For android Emu :D
  //Localhost For browser Emu
  //add photo did't work with browser idon't know why ????
  
  static const server = "localhost:3000"; 

  static Users login = Users();
  
  static String? loggedInUserId;

  // static List<String> gender = [
  //   "None",
  //   "Male",
  //   "Female"
  // ];
}
