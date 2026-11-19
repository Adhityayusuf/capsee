import 'package:capsee/services/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;

void main() {
  test('parseResponse preserves the not-chili error code', () {
    final response = http.Response(
      '{"detail":{"code":"not_chili_plant","message":"Foto bukan cabai."}}',
      422,
    );

    expect(
      () => parseResponse(response),
      throwsA(
        isA<ApiException>()
            .having((error) => error.code, 'code', apiCodeNotChiliPlant)
            .having((error) => error.pesan, 'message', 'Foto bukan cabai.'),
      ),
    );
  });
}
