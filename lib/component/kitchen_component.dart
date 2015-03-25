library kitchen_component;

import 'dart:html';
import 'package:angular/angular.dart';
//import 'package:mongo_pro/service/take_order_service.dart';

@Component(
    selector:'kitchen',
    templateUrl: 'kitchen_component.html',
    useShadowDom: false)
class KitchenComponent{ //implements ShadowRootAware{
  
  final WEBSOCKET_URL = "ws://127.0.0.1:8000/kitchen";
  WebSocket _webSocket;
  
  Element output;
  final RouteProvider _router;
  final Window window;
  
  //final TakeOrderService _takeOrderService;
  
  List<List<String>> orderItems = [];
  List<String> temp = [];
  KitchenComponent(this._router,this.output,this.window){
    print("Kitchen called");
    
    //doesnt work... use something else to monitor the trigger of close of tabs and close the socket

    
    _router.route.onPreLeave.listen((_){
      _webSocket.close();
      querySelector('.loader').classes.remove('hide');
      
    });
    
    querySelector('.loader').classes.add('hide');
    
    window.onBeforeUnload.listen((e){
      
      //in case window is closed... stop listening from socket
      print("onBeforeUnload");
      _webSocket.close();
      print("after");
    });
    
    //print(ngQuery(output, "#orders").length);
    _takeOrders();
  }
  
  void _takeOrders(){
    _webSocket = new WebSocket(WEBSOCKET_URL);
    _webSocket.onOpen.listen((e){
      print("opening kitchen");
      _webSocket.send("Send Now");
    });
    
    _webSocket.onMessage.listen((msg){
      print("received order of: ${msg.data}");
      if(msg.data.toString() == 'start'){
        temp = new List<String>();
        return;
      }
      if(msg.data.toString() == 'end'){
        orderItems.add(temp);
        return;
      }
      temp.add(msg.data);
    });
    
    _webSocket.onClose.listen((msg){
      print("server closing");
    });
  }
  
  bool isNumeric(String s) {
    if(s == null) {
      return false;
    }
    return double.parse(s, (e) => null) != null;
  }
  
  /*
  void onShadowRoot(ShadowRoot root) {
      Element e = root.querySelector('#orders');
      print("Text is : ${e.text}");
  }
  */
}