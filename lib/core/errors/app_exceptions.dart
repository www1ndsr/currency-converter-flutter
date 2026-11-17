abstract class AppException implements Exception {
  final String userMessage;
  final String? technicalDetails;

  const AppException(this.userMessage, [this.technicalDetails]);

  @override
  String toString() => technicalDetails == null
      ? userMessage
      : '$userMessage ($technicalDetails)';
}

class NetworkException extends AppException {
  const NetworkException([String? details])
      : super(
          'Не удалось подключиться к серверу Национального банка Молдовы. Проверьте подключение к интернету.',
          details,
        );
}

class TimeoutException extends AppException {
  const TimeoutException([String? details])
      : super(
          'Время ожидания ответа от сервера BNM истекло.',
          details,
        );
}

class XmlParseException extends AppException {
  const XmlParseException([String? details])
      : super(
          'Не удалось обработать полученные данные от источника котировок.',
          details,
        );
}

class EmptyDataException extends AppException {
  const EmptyDataException([String? details])
      : super(
          'Данные о курсах валют за указанную дату отсутствуют.',
          details,
        );
}

class CacheNotFoundException extends AppException {
  const CacheNotFoundException([String? details])
      : super(
          'Локальные сохранённые данные о курсах отсутствуют. Требуется подключение к сети для первичной загрузки.',
          details,
        );
}

class ValidationException extends AppException {
  const ValidationException(super.userMessage, [super.technicalDetails]);
}
