library objectory_service;

import 'dart:async';
import 'package:objectory/objectory_browser.dart';
import 'package:mongo_pro/service/menu.dart';
import 'package:angular/angular.dart';
import 'dart:html';

//var port = Platform.environment.containsKey('PORT')?Platform.environment['PORT']:8881;
//var DefaultUri = 'restaurant-pp.herokuapp.com:16011';
var DefaultUri = '';

@Injectable()
class QueryService {

  Window _window;
  //Future of queries being completed
  Future _loaded;
  Future _inited;

  //cache files for avoiding querying the server whenever possible
  Map<String, MenuItem> _menuItemsCache;
  List<String> _categories;
  RestaurantDetail _restaurantDetail;

  //constructor for calling the loadData function
  QueryService(this._window) {
    /*
    _inited.then((_){
      _loaded = loadData();
    });
    */
    
    print("window location is:");
    print(DefaultUri = _window.location.origin.replaceAll('http://', ''));
    _loaded = loadData();
    _loaded.then((e){
      print("Query Service loading done");
      print(_restaurantDetail.name);
    });
  }
  
  Future initData(){
    objectory = new ObjectoryWebsocketBrowserImpl(DefaultUri,registerClasses,false);
    return _inited = objectory.initDomainModel();
  }

  //queries and fetches the documents from database and puts them into cache
  Future loadData() {
    List<Future> allTasks = [];
    print("queryServiceLoadData");
    objectory = new ObjectoryWebsocketBrowserImpl(DefaultUri,registerClasses,false);
    return objectory.initDomainModel().then((_) {
      allTasks.add(objectory[MenuItem].find(where.sortBy("category")).then((items) {
        _menuItemsCache = new Map<String, MenuItem>();
        String cat = "";
        _categories = [];
        for (MenuItem item in items) {
          print(item.name);
          _menuItemsCache[item.menuItemId] = item;
          if(cat != item.category){
            cat = item.category;
            _categories.add(cat);
          }
        }
        return new Future.value(true);
      },
      onError: ()=>print("error in first future")));
      
      allTasks.add(objectory[RestaurantDetail].findOne().then((detail){
        _restaurantDetail = detail;
        return new Future.value(true);
      },
      onError: ()=>print("error in second future")));
      
      return Future.wait(allTasks);
    },
    onError: ()=>print("error in query service"));
  }

  //Specific queries
  Future<MenuItem> getMenuItemById(String id) {
    return _menuItemsCache == null
        ? _loaded.then((_) => _menuItemsCache[id])
        : new Future.value(_menuItemsCache[id]);
  }

  Future<Map<String, MenuItem>> getAllRecipes() {
      return _menuItemsCache == null
        ? _loaded.then((_) => _menuItemsCache)
        :new Future.value(_menuItemsCache);
  }
  
  Future<List<String>> getCategories(){
    return _categories == null
        ? _loaded.then((_) => _categories)
        :new Future.value(_categories);
  }
  
  Future<RestaurantDetail> getRestaurantDetails() {
    return _restaurantDetail == null
        ? _loaded.then((_) => _restaurantDetail)
        : new Future.value(_restaurantDetail);
  }  
}
