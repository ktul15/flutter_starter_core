import 'package:flutter_test/flutter_test.dart';
import 'package:mobilions_core/mobilions_core.dart';

void main() {
  group('ApiResult', () {
    test('Success exposes data and folds via when', () {
      const ApiResult<int> result = Success(42);

      expect(result.isSuccess, isTrue);
      expect(result.isFailure, isFalse);
      expect(result.dataOrNull, 42);
      expect(result.errorOrNull, isNull);

      final folded = result.when(
        success: (d) => 'ok:$d',
        failure: (e) => 'err:${e.message}',
      );
      expect(folded, 'ok:42');
    });

    test('Failure exposes error and folds via when', () {
      const error = ApiException(
        type: ApiErrorType.server,
        message: 'boom',
        statusCode: 500,
      );
      const ApiResult<int> result = Failure(error);

      expect(result.isFailure, isTrue);
      expect(result.dataOrNull, isNull);
      expect(result.errorOrNull, error);

      final folded = result.when(
        success: (d) => 'ok:$d',
        failure: (e) => 'err:${e.message}',
      );
      expect(folded, 'err:boom');
    });

    test('map transforms Success and passes Failure through', () {
      const ApiResult<int> ok = Success(2);
      expect(ok.map((d) => d * 10).dataOrNull, 20);

      const ApiResult<int> fail = Failure(
        ApiException(type: ApiErrorType.unknown, message: 'x'),
      );
      final mapped = fail.map((d) => d * 10);
      expect(mapped.isFailure, isTrue);
      expect(mapped.errorOrNull?.message, 'x');
    });
  });
}
