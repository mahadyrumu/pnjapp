library my_prj.globals;

double getTextScale(currentDeviceScale, maxScale) {
  if (currentDeviceScale <= 1.0) {
    return 1.0;
  } else if (currentDeviceScale > 1.0 && currentDeviceScale < maxScale) {
    return currentDeviceScale;
  } else {
    return maxScale;
  }
}

double getHintTextScale(currentDeviceScale, maxScale, baseFontSize) {
  if (currentDeviceScale <= 1.0) {
    return baseFontSize * 1.0;
  } else {
    return baseFontSize * maxScale;
  }
}
