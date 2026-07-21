class AppException implements Exception {
  const AppException(this.message);
  final String message;

  @override
  String toString() => message;
}

class ServerException extends AppException {
  const ServerException(super.message);
}

class PollException extends AppException {
  const PollException(super.message);
}

class VoteException extends AppException {
  const VoteException(super.message);
}
