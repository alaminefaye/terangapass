class NearbyApiResult {
  const NearbyApiResult({
    required this.data,
    this.fallbackOutOfRadius = false,
    this.categoryCounts = const {},
    this.inRadiusTotal,
  });

  final List<dynamic> data;
  final bool fallbackOutOfRadius;
  final Map<String, int> categoryCounts;
  final int? inRadiusTotal;
}

class PointsOfInterestApiResult {
  const PointsOfInterestApiResult({
    required this.data,
    this.total,
    this.returned,
    this.limit,
    this.categoryCounts = const {},
    this.categoryCountsByKey = const {},
  });

  final List<dynamic> data;
  final int? total;
  final int? returned;
  final int? limit;
  final Map<String, int> categoryCounts;
  final Map<String, int> categoryCountsByKey;
}
