class PrinterConfig {
  final String macAddress;
  final String label;
  final String role;

  const PrinterConfig({
    required this.macAddress,
    this.label = '',
    this.role = 'receipt',
  });

  Map<String, dynamic> toJson() => {
    'macAddress': macAddress,
    'label': label,
    'role': role,
  };

  factory PrinterConfig.fromJson(Map<String, dynamic> json) => PrinterConfig(
    macAddress: json['macAddress'] as String,
    label: json['label'] as String? ?? '',
    role: json['role'] as String? ?? 'receipt',
  );
}
