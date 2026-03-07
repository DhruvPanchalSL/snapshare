class TransferModel {
  final String code;
  final String fileUrl;
  final String fileName;
  final int fileSize;
  final String mimeType;
  final DateTime createdAt;
  final DateTime expiresAt;
  final String uploaderUid;
  final String storagePath; // Supabase storage path for deletion

  TransferModel({
    required this.code,
    required this.fileUrl,
    required this.fileName,
    required this.fileSize,
    required this.mimeType,
    required this.createdAt,
    required this.expiresAt,
    required this.uploaderUid,
    required this.storagePath,
  });

  bool get isExpired => DateTime.now().isAfter(expiresAt);

  Duration get timeRemaining {
    final remaining = expiresAt.difference(DateTime.now());
    return remaining.isNegative ? Duration.zero : remaining;
  }

  String get fileSizeFormatted {
    if (fileSize < 1024) return '$fileSize B';
    if (fileSize < 1024 * 1024)
      return '${(fileSize / 1024).toStringAsFixed(1)} KB';
    return '${(fileSize / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  String get fileIcon {
    final ext = fileName.split('.').last.toLowerCase();
    if (['jpg', 'jpeg', 'png', 'gif', 'webp', 'heic'].contains(ext))
      return '🖼️';
    if (ext == 'pdf') return '📄';
    if (ext == 'apk') return '📦';
    if (['mp4', 'mov', 'avi', 'mkv'].contains(ext)) return '🎬';
    if (['mp3', 'wav', 'aac'].contains(ext)) return '🎵';
    if (['zip', 'rar', '7z'].contains(ext)) return '🗜️';
    if (['doc', 'docx'].contains(ext)) return '📝';
    if (['xls', 'xlsx'].contains(ext)) return '📊';
    return '📁';
  }

  Map<String, dynamic> toFirestore() => {
    'code': code,
    'fileUrl': fileUrl,
    'fileName': fileName,
    'fileSize': fileSize,
    'mimeType': mimeType,
    'createdAt': createdAt.toIso8601String(),
    'expiresAt': expiresAt.toIso8601String(),
    'uploaderUid': uploaderUid,
    'storagePath': storagePath,
  };

  factory TransferModel.fromFirestore(Map<String, dynamic> data) {
    return TransferModel(
      code: data['code'],
      fileUrl: data['fileUrl'],
      fileName: data['fileName'],
      fileSize: data['fileSize'],
      mimeType: data['mimeType'],
      createdAt: DateTime.parse(data['createdAt']),
      expiresAt: DateTime.parse(data['expiresAt']),
      uploaderUid: data['uploaderUid'],
      storagePath: data['storagePath'] ?? '',
    );
  }
}
