import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'interface/proxylist.dart';
import 'dart:async';
import 'dart:convert';



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

  int getplayState()
  {
    return 0;
  }
  int getStopState()
  {
    return 1;
  }
  int getLoadingState()
  {
    return 2;
  }
  int getConnectState()
  {
    return 3;
  }

  int getNextState()
  {
    switch(_connectState)
    {
      case 0:
        return getLoadingState();
      case 1:
        return getplayState();
      case 2:
        return getConnectState();
      case 3:
        return getplayState();
    }

    return getplayState();
  }

  void onChangeConnectionState(int index){
    if(index != _currentindex)
    {
      setState(() {
        _connectState = getplayState();
      });

      Timer(const Duration(milliseconds: 100), () => 
        setState(() {
          _currentindex = index;
          _connectState = getLoadingState();
        })
      );

    }
    else{
      setState(() {
        // _proxylist.removeAt(index);
        _connectState = (_connectState+1) % 3;      
      });
    }

    onNotifySelectItem(index);
  }

  void onNotifySelectItem(int index){
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

  const ListTileExample({Key? key, this.connectState = 0, this.currentProxyurl = "file:///assets/images/brazile.png", this.index=-1, this.currentindex=0, this.proxylist = const [] , required this.notifyChangeConnectionState, required this.notifySelectItem })
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
                              child: currentindex != index? const Icon(Icons.play_arrow) : (connectState == 0 ? const Icon(Icons.play_arrow) : (connectState == 1 ? const Icon(Icons.stop) : Image.asset("assets/images/loading.gif", width: 30))),
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
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              const Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                Text("SPEED", style: TextStyle(color: Colors.blueAccent),),
                Text("contents", style: TextStyle(color: Colors.blueAccent),)
              ],),
              
              Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                 CircleAvatar(radius: 40,backgroundImage: currentProxyurl==''?  NetworkImage(currentProxyurl) : NetworkImage(currentProxyurl)),
                const Text("contents", style: TextStyle(color: Colors.blueAccent),)
              ],),

              const Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                Text("SPEED", style: TextStyle(color: Colors.blueAccent),),
                Text("contents", style: TextStyle(color: Colors.blueAccent),)
              ],)
            ],
          )

        ),
      
    );
  }
}