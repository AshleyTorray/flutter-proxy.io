import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'interface/proxylist.dart';
import 'dart:async';
import 'dart:convert';
import 'interface/enums.dart';


void main() {
  runApp(const ProxyApp());
}


class ProxyApp extends StatefulWidget {
  const ProxyApp({super.key});

  @override
  State<ProxyApp> createState() => _ProxyAppState(); 
}

class _ProxyAppState extends State<ProxyApp> {
  
  Future fetchProxylist() async {
    final response = await http
        .get(Uri.parse('http://192.168.144.30:8000/proxylist/serverlist.json'));

    if (response.statusCode == 200) {
      List<dynamic> list = jsonDecode(response.body);
      setState(() {
        _proxylist = (list).map((e) => ProxyItem.fromJson(e)).toList();
      });
    } else {
      throw Exception('Failed to load Proxylist');
    }
  }

  @override
  void initState() {
    super.initState();
    fetchProxylist();
  }

  String _currentProxyurl = '';
  List<ProxyItem> _proxylist = [];
  int _connectState = 0;
  int _currentindex = 0;

  void onNotifyConnectState(int newstate)
  {
    setState(() {
      _connectState = newstate;
    });
  }

  int getNextState(int index)
  {
    //for test
    if(index == ProxySate.stplay.index) {
      Timer(const Duration(milliseconds: 3000), () => {
          if(_connectState == ProxySate.stconnecting.index)
          {
            setState(() {
              _connectState = ProxySate.stconnected.index;
            })
          }
      });
    }

    if(index == ProxySate.stplay.index) return ProxySate.stconnecting.index;
    if(index == ProxySate.stconnecting.index) return ProxySate.stplay.index;
    if(index == ProxySate.stconnected.index) return ProxySate.stplay.index;

    return ProxySate.stplay.index;
  }

  void onChangeConnectionState(int index){
    if(index != _currentindex)//if click  the button of different item , then set current state to play, set different'state to connecting
    {
      setState(() {
        _connectState = ProxySate.stplay.index;
      });

      Timer(const Duration(milliseconds: 200), () => 
        setState(() {
          _currentindex = index;
          _connectState = getNextState(ProxySate.stplay.index);
        })
      );
     
    }
    else{
      setState(() {
        _connectState = getNextState(_connectState);      
      });
    }

    onNotifySelectItem(index);
  }

  void onNotifySelectItem(int index){
    if(_connectState != ProxySate.stplay.index) return;

     setState(() {
      if(index > -1 && index < _proxylist.length) {
        _currentProxyurl = _proxylist[index].flag;
        _currentindex = index;
      } else {
        _currentProxyurl = "";
      }
    });
  }

 @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: ListTileExample(
        proxylist:  _proxylist,
        connectState: _connectState,
        currentindex: _currentindex,
        currentProxyurl: _currentProxyurl,
        notifyChangeConnectionState: onChangeConnectionState,
        notifySelectItem: onNotifySelectItem
        ),
    );
  }

}

class ListTileExample extends StatelessWidget  {

  const ListTileExample({Key? key, this.connectState = 0, this.currentProxyurl = "", this.index=-1, this.currentindex=0, this.proxylist = const [] , required this.notifyChangeConnectionState, required this.notifySelectItem })
      : super(key: key);
      
  final int index;
  final int currentindex;
  final ValueChanged<int> notifyChangeConnectionState;
  final ValueChanged<int> notifySelectItem;
  void manageState() {  
    notifyChangeConnectionState(index);
    notifySelectItem(index);
  }

  final List<ProxyItem> proxylist;
  final String currentProxyurl;
  final int connectState;

  void onSelectItem(int index)
  {
    notifySelectItem(index);
  }
  

  void ChangeConnectionState(int index){
    notifyChangeConnectionState(index);
  }
  
  // Image noImage = Image.asset("assets/defimg.jpg");

  void EditItem(int index){
    print("on Edit Item");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Proxy Server List'), backgroundColor: Colors.pinkAccent,),
      // backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      backgroundColor: Colors.deepPurple,
      body: Center(
        child: Card(
            color:Colors.deepOrangeAccent,
            child: ListView.builder(
              // shrinkWrap: true,
              itemCount: proxylist.length,
              itemBuilder: (context, index) {
                return ListTile(
                  leading: CircleAvatar(
                    backgroundImage: NetworkImage(proxylist[index].flag)
                  ),
                  // title: Text(proxylist[index].country),
                  // subtitle: Text(proxylist[index].ip),
                  subtitle: Row(
                    children: <Widget>[
                      SizedBox(
                        width: 130,
                        child: Text(
                            proxylist[index].ip, 
                            style: const TextStyle(
                              color: Colors.white,                     
                            ),
                        ),
                      ),

                      SizedBox(
                        width: 80,
                        child: Row(
                          children: <Widget>
                          [
                            // TextButton(                 
                            //   style: TextButton.styleFrom(
                            //     padding: const EdgeInsets.fromLTRB(10.0, 3.0, 10.0, 3.0),
                            //     backgroundColor: const Color.fromARGB(255, 6, 130, 247),      
                            //     side: const BorderSide(color: Color.fromARGB(255, 104, 193, 253), width: 2),  
                            //     shape: const RoundedRectangleBorder(
                            //       borderRadius: BorderRadius.all(Radius.circular(25)),
                            //     ) 
                            //   ),                      
                            //   child: const Text('Edit'),
                            //   onPressed: () { print("On Edit"); },
                            // ),
                            TextButton(
                              style: TextButton.styleFrom(
                                padding: const EdgeInsets.fromLTRB(10.0, 3.0, 10.0, 3.0),
                                backgroundColor: const Color.fromARGB(255, 6, 130, 247),    
                                side: const BorderSide(color: Color.fromARGB(255, 104, 193, 253), width: 2),  
                                shape: const RoundedRectangleBorder(
                                  borderRadius: BorderRadius.all(Radius.circular(25)),
                                ) 
                              ), 
                              child: currentindex != index? const Icon(Icons.play_arrow) : (connectState == ProxySate.stplay.index ? const Icon(Icons.play_arrow) : (connectState == ProxySate.stconnected.index ? const Icon(Icons.stop) : Image.asset("assets/images/loading.gif", width: 30))),
                              onPressed: () { ChangeConnectionState(index); },
                            ),
                          ],
                        ),
                      ),
                      
                    ],
                  ),
                  trailing: SizedBox(
                              width: 70,
                              child: Text(
                                  proxylist[index].price,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    color: Color.fromARGB(255, 247, 200, 32),                          
                                  ),
                              )
                            ),

                  // shape: const Border(bottom: BorderSide(), ),
                  tileColor: Colors.blueAccent,
                  onTap: (){
                    onSelectItem(index);
                  },
                  shape: RoundedRectangleBorder(
                    side: const BorderSide(color: Colors.cyanAccent, width: 2),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  
                );
              },
            ),
          ),
     

      ),
            
      floatingActionButton: const FractionallySizedBox(
        widthFactor: 0.5,
        heightFactor: 0.1,                
        alignment: FractionalOffset.bottomCenter,
        child: Row(          
          children: <Widget>[
            SizedBox(
              width: 100,
              child: Text(
                            "",
                            style: TextStyle(
                              color: Color.fromARGB(255, 247, 200, 32),                          
                            ),
                        )                 
            ),
          ],
          
        ),

      ),

      bottomNavigationBar: 
        FractionallySizedBox(
          widthFactor: 1,
          heightFactor: 0.2,
          alignment: FractionalOffset.bottomCenter,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  const Text("SPEED", style: TextStyle(fontSize:22, color: Colors.blueAccent),),
                  CircleAvatar(radius: 40,backgroundImage: currentProxyurl==''?  NetworkImage(currentProxyurl) : NetworkImage(currentProxyurl)),
                  const Text("SPEED", style: TextStyle(fontSize:22, color: Colors.blueAccent),)                
                ],
              ),
              
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  const Text("contents", style: TextStyle(fontSize:18, color: Color.fromARGB(255, 240, 242, 247)),),
                  Text(currentindex < 0 || currentindex > proxylist.length-1 ? "" : proxylist[currentindex].country, style: const TextStyle(fontSize: 30, color: Color.fromARGB(255, 240, 242, 247)),),
                  const Text("contents", style: TextStyle(fontSize:18, color: Color.fromARGB(255, 240, 242, 247)),)
                ],
              ),
            ],
          )

        ),
      
    );
  }
}