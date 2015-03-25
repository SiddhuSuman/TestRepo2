library menu_controller;

import 'package:angular/angular.dart';
import '../service/query_service.dart';
import '../service/menu.dart';
import 'package:mongo_pro/service/common_service.dart';
//import '../../web/test.dart';
import 'dart:async';
import 'dart:html';

@Component(
  selector:'menu-item',
  templateUrl: 'menu_controller.html',
  useShadowDom: false
)
class MenuController{
  
  final WEBSOCKET_URL = "ws://127.0.0.1:8000/sendorder";
  
  final Http _http;
  final QueryService _queryService;
  final Router _router;
  //final Window window;
  final RouteProvider _routeProvider;
  final CommonService _commonService;
  //final MyAppModule _testModule;
  
  bool menuItemsLoaded = false;
  
  Map<String, MenuItem> _menuItemMap = {};
  Map<String, MenuItem> get menuItemMap => _menuItemMap;
  List<MenuItem> _allMenuItems = [];
  List<MenuItem> get allMenuItems => _allMenuItems;
  List<List<MenuItem>> _properMenuItems = [];
  List<List<MenuItem>> get properMenuItems => _properMenuItems;
  List<String> _categories = [];
  List<String> get categories => _categories;
  Map<String, MenuItem> _catWiseMap = {};
  Map<String, MenuItem> get catWiseMap => _catWiseMap;
  Map<String,String> mmm = {"Hello":" world!","Foo":"bar"};
  
  Map<String, int> _orderList = {};
  
  RestaurantDetail _restaurantDetail = null;
  RestaurantDetail get restaurantDetail => _restaurantDetail;
  void set restaurantDetail(RestaurantDetail detail){
    _restaurantDetail = detail;
  }
  
  int get orderItemsCount => _orderList.length;
  
  String tableNumber = null;
  
  MenuController(this._http,this._queryService,this._router, this._routeProvider, this._commonService){
    //_loadData();
    _routeProvider.route.onPreLeave.listen((_){
      //print("Page before unload");
      querySelector('.loader').classes.remove('hide');
    });
    
    print(_commonService.session['table_num']);
    
    _loadData().then((_){
        querySelector('.loader').classes.add('hide');
    });
    
    _queryService.getCategories().then((categories){
          _categories = categories;
    });
  }
  
  Future _loadData(){
    String cat = "";
    _queryService.getAllRecipes().then((Map<String, MenuItem> allItems){
      _menuItemMap = allItems;
      _allMenuItems = _menuItemMap.values.toList();
      List<MenuItem> _tempList=[];
      cat = _allMenuItems.first.category;
      _allMenuItems.forEach((item){
        if(item.category == cat){
          //print("if clause");
          _tempList.add(item);
        }
        else{
          //print("else clause");
          cat = item.category;
          _properMenuItems.add(_tempList);
          _tempList = [];
          _tempList.add(item);
          
        }
      });
      if(_tempList.isNotEmpty){
        _properMenuItems.add(_tempList);
        _tempList = [];
      }
      
      _queryService.getRestaurantDetails().then((details){
        _restaurantDetail = details;
      });
      
      menuItemsLoaded = true;
      return new Future.value(true);
    }).catchError((e) {
      print(e);
      menuItemsLoaded = false;
      print("Some stuff happened!");
    });
    return new Future.value(false);
  }
  
  void orderItem(String id){
    print(_menuItemMap[id].name);
    MenuItem mItem = _menuItemMap[id];
    DivElement element = querySelector('#${mItem.uid}');
    if(element.classes.contains('selected')){
      //print("Class Present!");
      element.classes.remove('selected');
      _orderList.remove(mItem.name);
    }else{
      element.classes.add('selected');
      _orderList[mItem.name] = 1;
    }
    
    print("List so far is: $_orderList");
  }
  
  void sendOrder(){
    if(_orderList.isEmpty)
      return;
    else{
      WebSocket _webSocket = new WebSocket(WEBSOCKET_URL);
      _webSocket.onOpen.listen((e){
        Map<String, String> session = _commonService.session;
        if(session.containsKey('table_num'))
          _webSocket.send(session['table_num']);
        else
          _webSocket.send('online');
        _webSocket.send(_orderList.toString());
        _webSocket.close();
        _orderList.clear();
        querySelectorAll('.selected').forEach((e){
          e.classes.remove('selected');
        });
      });
      
      _webSocket.onClose.listen((e){
        print("closed sender sock");
      });
    }
  }
}