import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:webview_flutter/webview_flutter.dart' as ram;
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:flutter_user_agent/flutter_user_agent.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:get_ip/get_ip.dart';

Future main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Permission.camera.request();
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => new _MyAppState();
}

class _MyAppState extends State<MyApp> {

  String _userAgent = '<unknown>';
  String _webUserAgent = '<unknown>';
  String localHostID = '<unknown>';


  @override
  void initState() {
    super.initState();
    initUserAgentState();
    print('\n\n\n\nYES ***********************');
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        home: InAppWebViewPage()
    );
  }

  void getLocalHostID() {
    Future<String> getLocalHostID() async {
      String ipAddress = await GetIp.ipAddress;
      print("\n\nRETRIEVED IPADDRESS >>>>>>>>> "+ipAddress); //192.168.232.2
      localHostID = ipAddress;
    }
  }

  void initUserAgentState() {
    Future<void> initUserAgentState() async {
      String userAgent, webViewUserAgent;
      print('\nTRYING USER AGENT ');
      // Platform messages may fail, so we use a try/catch PlatformException.
      try {
        userAgent = await FlutterUserAgent.getPropertyAsync('userAgent');
        await FlutterUserAgent.init();
        webViewUserAgent = FlutterUserAgent.webViewUserAgent;
        print('''
        applicationVersion => ${FlutterUserAgent.getProperty('applicationVersion')}
        systemName         => ${FlutterUserAgent.getProperty('systemName')}
        userAgent          => $userAgent
        webViewUserAgent   => $webViewUserAgent
        packageUserAgent   => ${FlutterUserAgent.getProperty('packageUserAgent')}
      ''');
      } on PlatformException {
        print('\n\n\n\nERROR HAPPENED ');
        userAgent = webViewUserAgent = '<error>';

      }

      // If the widget was removed from the tree while the asynchronous platform
      // message was in flight, we want to discard the reply rather than calling
      // setState to update our non-existent appearance.
      if (!mounted) return;

      setState(() {
        _userAgent = userAgent;
        _webUserAgent = webViewUserAgent;
      });
    }
  }
}

class InAppWebViewPage extends StatefulWidget {
  @override
  _InAppWebViewPageState createState() => new _InAppWebViewPageState();
}

class _InAppWebViewPageState extends State<InAppWebViewPage> {

  ContextMenu contextMenu;
  InAppWebViewController _webViewController;
  String navigationMenu = "InAppWebView";
  String activateURL = null;
  double progress = 0;



  @override
  void initState() {
    super.initState();

    //localHostID = await GetIp.ipAddress;

    if (Platform.isAndroid) ram.WebView.platform = ram.SurfaceAndroidWebView();

    /*contextMenu = ContextMenu(
        menuItems: [
          ContextMenuItem(androidId: 1, iosId: "1", title: "Special", action: () async {
            print("Menu item Special clicked!");
            var selectedText = await _webViewController.getSelectedText();
            await _webViewController.clearFocus();
            await _webViewController.evaluateJavascript(source: "window.alert('You have selected: $selectedText')");
          })
        ],
        options: ContextMenuOptions(
            hideDefaultSystemContextMenuItems: false
        ),
        onCreateContextMenu: (hitTestResult) async {
          print("onCreateContextMenu");
          print(hitTestResult.extra);
          print(await _webViewController.getSelectedText());
        },
        onHideContextMenu: () {
          print("onHideContextMenu");
        },
        onContextMenuActionItemClicked: (contextMenuItemClicked) async {
          var id = (Platform.isAndroid) ? contextMenuItemClicked.androidId : contextMenuItemClicked.iosId;
          print("onContextMenuActionItemClicked: " + id.toString() + " " + contextMenuItemClicked.title);
        }
    );*/
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          centerTitle: false,
          title: Text("Ram K - "+navigationMenu, style: TextStyle(fontFamily: "Agency FB",fontSize: 18),),
          flexibleSpace: Container(
            decoration: BoxDecoration(
                gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: <Color>[
                      Colors.transparent,
                      Colors.white
                    ])
            ),
          ),
        ),
        resizeToAvoidBottomInset: true,
        body: Container(
            child: Column(children: <Widget>[
              Expanded(

                child: Container(
                  child: InAppWebView(
                    initialUrl: "https://www.google.com",
                    //initialUrl: "http://172.21.96.1:10101/healthDX/checkout/index.html",
                    //initialUrl: "https://https://192.168.43.14:1010/SDxMembership/checkout/bt5_demo.html", // ACTUAL SDX
                    //initialUrl: "https://https://192.168.43.14:1010/SDxMembership/checkout/index.html", // ACTUAL SDX
                    //initialUrl: "https://coderthemes.com/hyper/modern/form-advanced.html", // BootStrap TEST
                    //initialUrl: "http://s3.amazonaws.com/inmobi-rm-app/CreativeUploads/mr/2k20/june/unilever_prod_test_v1/adtag_f2_s2.html", //GOOD UI
                    //initialFile: "assets/demo.html",
                    contextMenu: contextMenu,

                    initialOptions: InAppWebViewGroupOptions(
                      crossPlatform: InAppWebViewOptions(
                        debuggingEnabled: true,
                          clearCache: true,
                          userAgent : "Mozilla/5.0 (Linux; Android 10; GM1911 Build/QKQ1.190716.003; wv) AppleWebKit/537.36 (KHTML, like Gecko) Version/4.0 Chrome/83.0.4103.106 Mobile ",
                      ),

                      android: AndroidInAppWebViewOptions(
                        textZoom: 100,
                      ),
                    ),

                    onWebViewCreated: (InAppWebViewController controller) {
                      controller.getOptions().then((val) {
                        print(val);
                      });
                      _webViewController = controller;
                    },
                    onReceivedServerTrustAuthRequest: (controller, challenge) async {
                      print("**************** YES, Server requested the SelfSignin verification");
                      return ServerTrustAuthResponse(action: ServerTrustAuthResponseAction.PROCEED);
                    },
                    onLoadStart: (InAppWebViewController controller, String url) {
                      setState(() {
                        this.activateURL = url;
                      });
                    },
                    onLoadStop: (InAppWebViewController controller, String url) async {
                      setState(() {
                        this.activateURL = url;
                      });
                    },
                    onProgressChanged: (InAppWebViewController controller, int progress){
                      setState(() {
                        this.progress = progress / 100;
                      });
                    },
                  ),
                ),
              ),
            ])
        ),
      drawer: Drawer(
        child: Column(
          children: [
            Expanded(
              flex: 1,
              child: Container(
                width: MediaQuery.of(context).size.width * 0.85,
                child: DrawerHeader(
                  decoration: BoxDecoration(
                      image: DecorationImage(
                          image: AssetImage("assets/RK.png"),
                          fit: BoxFit.cover)),
                  child: new Container(
                    constraints: BoxConstraints(maxWidth: 50, maxHeight: 25),
                    child: new Container(
                      margin: const EdgeInsets.all(30.0),
                      padding: const EdgeInsets.all(10.0),
                      decoration: new BoxDecoration(
                        border: Border.all(
                            width: 0.0, color: Colors.grey.shade400
                        ),
                        borderRadius: BorderRadius.all(
                            Radius.circular(5.0) //                 <--- border radius here
                        ),
                          gradient: new LinearGradient(
                            colors: [Colors.black12, Colors.transparent],
                          )
                      ), //             <--- BoxDecoration here
                      child: Text(
                        "Ram K",
                        style: TextStyle(fontFamily: "Calibiri",fontSize: 30.0,
                          shadows: [
                            Shadow(
                              blurRadius: 4.0,
                              color: Colors.lime.shade200,
                              offset: Offset(2.0, 2.0),
                            ),
                          ],
                        ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis
                      ),
                    ),
                  )
                ),
              ),
            ),
            Expanded(
              //initialUrl: "http://172.21.96.1:10101/healthDX/checkout/index.html",
              //initialUrl: "https://https://192.168.43.14:1010/SDxMembership/checkout/bt5_demo.html", // ACTUAL SDX
              //initialUrl: "https://https://192.168.43.14:1010/SDxMembership/checkout/index.html", // ACTUAL SDX
              //initialUrl: "https://coderthemes.com/hyper/modern/form-advanced.html", // BootStrap TEST
              //initialUrl: "http://s3.amazonaws.com/inmobi-rm-app/CreativeUploads/mr/2k20/june/unilever_prod_test_v1/adtag_f2_s2.html", //GOOD UI
              flex: 2,
              child: ListView(children: [
                ListTile(
                  title: Text("GitHub Profile"),
                  onTap: () {
                    Navigator.pop(context);
                    setState(() {
                      navigationMenu = "Profile";
                      _webViewController.loadUrl(url: "https://github.com/RamKaruthapandian");
                    });
                  },
                ),
                ListTile(
                  title: Text("SiviSoft"),
                  onTap: () {
                    Navigator.of(context).pop();
                    setState(() {
                      navigationMenu = "SiviSoft";
                      _webViewController.loadUrl(url: "https://www.sivisoft.com");
                    });
                  },
                ),
                ListTile(
                  title: Text("BootStrap CheckOut"),
                  onTap: () {
                    Navigator.of(context).pop();
                    setState(() {
                      navigationMenu = "BootSrap Checkout";
                      _webViewController.loadUrl(url: "https://https://192.168.43.14:1010/SDxMembership/checkout/index.html");
                    });
                  },
                ),
                ListTile(
                  title: Text("BootStrap GNAT"),
                  onTap: () {
                    Navigator.of(context).pop();
                    setState(() {
                      navigationMenu = "GNAT Membership";
                      _webViewController.loadUrl(url: "https://https://192.168.43.14:1010/SDxMembership/GNAT/gnat_index2.html");
                    });
                  },
                ),
                ListTile(
                  title: Text("GNAT FAQ"),
                  onTap: () {
                    Navigator.of(context).pop();
                    setState(() {
                      navigationMenu = "GNAT FAQ";
                      _webViewController.loadUrl(url: "https://192.168.43.14:1010/SDxMembership/GNAT/gnat_faq.html");
                    });
                  },
                ),
                ListTile(
                  title: Text("Amazon InMobi Add"),
                  onTap: () {
                    Navigator.of(context).pop();
                    setState(() {
                      navigationMenu = "inMobi Add";
                      _webViewController.loadUrl(url: "http://s3.amazonaws.com/inmobi-rm-app/CreativeUploads/mr/2k20/june/unilever_prod_test_v1/adtag_f2_s2.html");
                    });
                  },
                ),
                ListTile(
                  title: Text("EShop"),
                  onTap: () {
                    Navigator.of(context).pop();
                    setState(() {
                      navigationMenu = "EShop";
                      _webViewController.loadUrl(url: "https://192.168.43.14:1010/SDxMembership/scheme/schemes.html");
                    });
                  },
                ),
                ListTile(
                  title: Text("Able pro"),
                  onTap: () {
                    Navigator.of(context).pop();
                    setState(() {
                      navigationMenu = "Able pro";
                      _webViewController.loadUrl(url: "http://127.0.0.1:8888/index.html");
                    });
                  },
                ),
              ]),
            )
          ],
        ),
      ),
    );
  }

  Future<String> getIPAddress() async{
    for (var interface in await NetworkInterface.list()) {
      print('== Interface: ${interface.name} ==');
      for (var addr in interface.addresses) {
        print(
            '${addr.address} ${addr.host} ${addr.isLoopback} ${addr.rawAddress} ${addr.type.name}');
      }
    }
    return "192.168.43.14";
  }


}