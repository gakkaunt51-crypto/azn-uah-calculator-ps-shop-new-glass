import 'package:decimal/decimal.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:azn_uah_calculator/calculator.dart';

void main() {
  final sender = {
    'percent_fee': '0',
    'fixed_fee_azn': '0',
    'fee_mode': 'add_on',
    'conversion_fee_percent': '0',
    'min_fee_azn': '0',
  };
  final receiver = {
    'percent_fee': '0',
    'fixed_fee_uah': '0',
    'min_fee_uah': '0',
  };

  test('zero fees returns enough UAH', () {
    final result = calculate('1000', '100', '2.0', sender, receiver);
    expect(result.received >= result.target, isTrue);
    expect(result.total.toString(), '550');
  });

  test('sender percentage and receiver fee are included', () {
    final s = {...sender, 'percent_fee': '2'};
    final t = {...receiver, 'percent_fee': '1', 'fixed_fee_uah': '2'};
    final result = calculate('1000', '100', '2.0', s, t);
    expect(result.received >= result.target, isTrue);
    expect(result.senderFee > Decimal.zero, isTrue);
    expect(result.receiverFee > Decimal.zero, isTrue);
  });

  test('receiver commission is based on purchase, not service', () {
    final t = {...receiver, 'percent_fee': '1.5', 'fixed_fee_uah': '0'};
    final first = calculate('1000', '100', '2.0', sender, t);
    final second = calculate('1000', '500', '2.0', sender, t);
    expect((first.receiverFee - second.receiverFee).abs() < Decimal.parse('0.03'), isTrue);
    expect(first.received >= first.target, isTrue);
    expect(second.received >= second.target, isTrue);
  });

  test('receiver minimum and maximum fees are respected', () {
    final minimum = calculate('100', '20', '2', sender, {
      ...receiver,
      'percent_fee': '0',
      'min_fee_uah': '5',
    });
    expect(minimum.receiverFee, Decimal.parse('5'));

    final maximum = calculate('1000', '20', '2', sender, {
      ...receiver,
      'percent_fee': '10',
      'max_fee_uah': '8',
    });
    expect(maximum.receiverFee, Decimal.parse('8'));
  });

  test('conversion fee applies to purchase and service together', () {
    final noBuffer = calculate('1000', '200', '2', sender, receiver);
    final withBuffer = calculate('1000', '200', '2', {
      ...sender,
      'conversion_fee_percent': '1',
    }, receiver);
    expect(withBuffer.total > noBuffer.total, isTrue);
  });


  test('receiver percentage fee excludes service amount exactly', () {
    final t = {...receiver, 'percent_fee': '2', 'fixed_fee_uah': '0'};
    final purchaseOnly = calculate('1000', '0', '2', sender, t);
    final withService = calculate('1000', '500', '2', sender, t);
    expect((purchaseOnly.receiverFee - Decimal.parse('20.40')).abs() < Decimal.parse('0.05'), isTrue);
    expect((withService.receiverFee - Decimal.parse('20.40')).abs() < Decimal.parse('0.05'), isTrue);
    expect(withService.received >= withService.target, isTrue);
  });

  test('negative amounts are rejected', () {
    expect(() => calculate('-1', '0', '2', sender, receiver),
        throwsFormatException);
  });
}
