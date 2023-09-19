import 'package:flutter/widgets.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

ValueNotifier<int> useLoadCount(
    InAppWebViewController? _controller, ValueNotifier<String> url) {
  final loadCount = useState<int>(0);

  useEffect(() {
    if (url.value != '' && _controller != null) {
      _controller
          .loadUrl(urlRequest: URLRequest(url: Uri.parse(url.value)))
          .then((value) {});
    }
  }, [loadCount.value]);

  return loadCount;
}
