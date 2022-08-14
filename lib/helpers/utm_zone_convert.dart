int lonLatToUTMZone(double lon, double lat) {
  if (lat > 55 && lat < 64 && lon > 2 && lon < 6) {
    return 32;
  }
  if (lat > 71 && lon >= 6 && lon < 9) {
    return 31;
  }
  if (lat > 71 && ((lon >= 9 && lon < 12) || (lon >= 18 && lon < 21))) {
    return 33;
  }
  if (lat > 71 && ((lon >= 21 && lon < 24) || (lon >= 30 && lon < 33))) {
    return 35;
  }
  // Rest of the world
  if (lon >= -180 && lon <= 180) {
    return (((lon + 180) / 6).floor() % 60) + 1;
  }
  return -1;
}
