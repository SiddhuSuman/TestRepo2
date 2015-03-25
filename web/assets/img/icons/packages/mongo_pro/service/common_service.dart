library common_service;

import 'package:angular/angular.dart';

@Injectable()
class CommonService{
  
  //serves the session object
  Map<String, String> _session = {};
  Map<String, String> get session => _session;
  void set session(Map<String, String> s){
    _session = s;
  }
  
  void clearSession(){
    _session = {};
  }
}