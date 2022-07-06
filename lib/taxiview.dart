import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class TaxiView extends HookWidget {
  @override
  Widget build(BuildContext context) {
    final _isLoaded = useState(false);

    String address = dotenv.get("FRONT_ADDRESS");

    return SafeArea(
        child: Stack(children: [
      WebView(
          initialUrl: address,
          javascriptMode: JavascriptMode.unrestricted,
          gestureNavigationEnabled: true,
          onPageFinished: (finish) {
            _isLoaded.value = true;
          }),
      _isLoaded.value ? Stack() : Center(child: CircularProgressIndicator())
    ]));
  }
}
