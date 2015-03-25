library take_order_service;

import 'dart:async';
import 'package:angular/angular.dart';

@Injectable()
class TakeOrderService{
  static StreamController<String> _controller;
  static bool _acceptOrders = false;
  
  TakeOrderService(){
    print("TakeOrderService");
    
  }
  
  String takeOrder(String name){
    if(_acceptOrders){
      _controller.add(name);
      return "Order sent to the kitchen";
    }else{
      return "The kitchen is closed right now. Please try again later";
    }
  }
  
  Stream<String> orders(){
    if(_controller == null){
      print("creating stream controller");
      _controller = new StreamController<String>(
                onListen: (){ _acceptOrders = true; print("onListen");},
                onPause: (){ _acceptOrders = false; print("onPause");},
                onResume: (){ _acceptOrders = true; print("onResume");},
                onCancel: (){ _acceptOrders = false; print("onCancel");}
      );
      return _controller.stream;
    }
    else{
      print("reusing same controller");
      return _controller.stream;
    }
  }
}