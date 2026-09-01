/// Hiveから読み出した値は Map<dynamic, dynamic> になっていることがあるため、
/// 安全に Map<String, dynamic> へ変換するための小さなヘルパー関数。
Map<String, dynamic> asStringKeyedMap(dynamic raw) {
  if (raw is Map<String, dynamic>) return raw;
  if (raw is Map) return Map<String, dynamic>.from(raw);
  throw ArgumentError('Map型ではない値です: $raw');
}
