library my_prj.globals;

import 'dart:io';

String getApiBaseUrl() {
  if (Platform.isIOS) {
    // return "http://localhost:9000/b/v1/api/v1.0";
    return "https://plg.parknjetseatac.com/b/api";
  } else if (Platform.isAndroid) {
    return "https://plg.parknjetseatac.com/b/api";
  } else {
    throw UnsupportedError("Unsupported platform");
  }
}
