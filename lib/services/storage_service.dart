/// Abstract contract for Firebase Storage file uploads.
abstract class StorageService {
  Future<String> uploadProfilePicture({
    required String userId,
    required String filePath,
  });

  Future<String> uploadNoticeAttachment({
    required String noticeId,
    required String filePath,
  });

  Future<String> uploadComplaintImage({
    required String complaintId,
    required String filePath,
  });

  Future<void> deleteFile(String fileUrl);
}

/// Mock implementation for Phase 1.
class MockStorageService implements StorageService {
  @override
  Future<String> uploadProfilePicture({
    required String userId,
    required String filePath,
  }) async {
    await Future.delayed(const Duration(milliseconds: 500));
    return 'https://example.com/uploads/$userId.jpg';
  }

  @override
  Future<String> uploadNoticeAttachment({
    required String noticeId,
    required String filePath,
  }) async {
    await Future.delayed(const Duration(milliseconds: 500));
    return 'https://example.com/attachments/$noticeId.pdf';
  }

  @override
  Future<String> uploadComplaintImage({
    required String complaintId,
    required String filePath,
  }) async {
    await Future.delayed(const Duration(milliseconds: 500));
    return 'https://example.com/complaints/$complaintId.jpg';
  }

  @override
  Future<void> deleteFile(String fileUrl) async {
    await Future.delayed(const Duration(milliseconds: 300));
  }
}
