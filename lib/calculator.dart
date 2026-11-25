import 'package:decimal/decimal.dart';

Decimal d(Object? v, [String field = 'value']) {
  try {
    return Decimal.parse((v ?? '0').toString().replaceAll(',', '.'));
  } catch (_) {
    throw FormatException('Некорректное значение: $field');
  }
}

Decimal _divide(Decimal numerator, Decimal denominator) =>
    (numerator / denominator).toDecimal(
      scaleOnInfinitePrecision: 24,
      toBigInt: (value) => value.ceil(),
    );

Decimal _fee(Decimal amount, Decimal percent, Decimal fixed,
    Decimal minimum, Decimal? maximum) {
  var value = amount * percent + fixed;
  if (value < minimum) value = minimum;
  if (maximum != null && value > maximum) value = maximum;
  return value;
}

Decimal _ceilCent(Decimal value) {
  final cents = (value * Decimal.fromInt(100)).ceil();
  return _divide(cents, Decimal.fromInt(100));
}

class Calculation {
  final Decimal purchase, service, target, rate, conversionPercent;
  final Decimal receiverGross, receiverFee, senderPrincipal, senderFee;
  final Decimal total, received, roundingExtra;

  const Calculation({
    required this.purchase,
    required this.service,
    required this.target,
    required this.rate,
    required this.conversionPercent,
    required this.receiverGross,
    required this.receiverFee,
    required this.senderPrincipal,
    required this.senderFee,
    required this.total,
    required this.received,
    required this.roundingExtra,
  });
}

Calculation calculate(Object purchase, Object service, Object rate,
    Map<String, dynamic> sender, Map<String, dynamic> receiver) {
  final p = d(purchase, 'сумма покупки');
  final c = d(service, 'стоимость услуги');
  final r = d(rate, 'курс');
  final zero = Decimal.zero;
  if (p < zero || c < zero) {
    throw FormatException('Суммы не могут быть отрицательными.');
  }
  if (p + c <= zero) {
    throw FormatException('Целевая сумма должна быть больше нуля.');
  }
  if (r <= zero) throw FormatException('Курс должен быть больше нуля.');

  final sp = _divide(d(sender['percent_fee']), Decimal.fromInt(100));
  final sf = d(sender['fixed_fee_azn']);
  final smin = d(sender['min_fee_azn']);
  final smax = sender['max_fee_azn'] == null || sender['max_fee_azn'] == ''
      ? null
      : d(sender['max_fee_azn']);
  final xp = _divide(d(sender['conversion_fee_percent']), Decimal.fromInt(100));
  if (sp < zero || sf < zero || smin < zero || xp < zero ||
      sp >= Decimal.one || xp >= Decimal.one) {
    throw FormatException('Некорректный тариф отправителя: проверьте проценты и комиссии.');
  }
  if (smax != null && smax < smin) {
    throw FormatException('Максимальная комиссия отправителя меньше минимальной.');
  }

  final rp = _divide(d(receiver['percent_fee']), Decimal.fromInt(100));
  final rf = d(receiver['fixed_fee_uah']);
  final rmin = d(receiver['min_fee_uah']);
  final rmax = receiver['max_fee_uah'] == null || receiver['max_fee_uah'] == ''
      ? null
      : d(receiver['max_fee_uah']);
  if (rp < zero || rf < zero || rmin < zero || rp >= Decimal.one) {
    throw FormatException('Некорректный тариф получателя.');
  }
  if (rmax != null && rmax < rmin) {
    throw FormatException('Максимальная комиссия получателя меньше минимальной.');
  }

  final mode = sender['fee_mode'] ?? 'add_on';
  if (mode != 'add_on' && mode != 'deducted') {
    throw FormatException('Неизвестный режим комиссии отправителя.');
  }

  // Получатель удерживает комиссию только с покупки. Стоимость услуги
  // остаётся на карте получателя и не участвует в банковской комиссии.
  final effectiveRate = r * (Decimal.one - xp);
  var purchaseGross = _divide(p + rf, Decimal.one - rp);
  final grossPurchaseFee = purchaseGross * rp + rf;
  if (rmin > grossPurchaseFee) {
    purchaseGross += rmin - grossPurchaseFee;
  }
  if (rmax != null && grossPurchaseFee > rmax) {
    purchaseGross = p + rmax;
  }
  final requiredAfterConversion = purchaseGross + c;

  final principalEstimate = _divide(requiredAfterConversion, effectiveRate);
  Decimal estimate;
  if (mode == 'add_on') {
    estimate = principalEstimate +
        _fee(principalEstimate, sp, sf, smin, smax);
  } else {
    estimate = _divide(principalEstimate + sf, Decimal.one - sp);
    final minimumEstimate = principalEstimate + smin;
    if (estimate < minimumEstimate) estimate = minimumEstimate;
  }

  var total = _ceilCent(estimate);
  final cent = Decimal.parse('0.01');
  for (var i = 0; i < 2000000; i++) {
    late Decimal senderFee;
    late Decimal principalSent;
    if (mode == 'add_on') {
      var base = total;
      for (var j = 0; j < 50; j++) {
        senderFee = _fee(base, sp, sf, smin, smax);
        base = total - senderFee;
      }
      principalSent = base;
      senderFee = total - principalSent;
    } else {
      senderFee = _fee(total, sp, sf, smin, smax);
      principalSent = total - senderFee;
    }

    final converted = principalSent * effectiveRate;
    // Комиссия получателя начисляется только на часть, предназначенную для покупки.
    final purchaseShare = converted - c;
    final receiverFee = purchaseShare > zero
        ? _fee(purchaseShare, rp, rf, rmin, rmax)
        : _fee(p, rp, rf, rmin, rmax);
    final received = converted - receiverFee;
    if (received >= p + c) {
      return Calculation(
        purchase: p,
        service: c,
        target: p + c,
        rate: r,
        conversionPercent: xp * Decimal.fromInt(100),
        receiverGross: converted,
        receiverFee: receiverFee,
        senderPrincipal: principalSent,
        senderFee: senderFee,
        total: total,
        received: received,
        roundingExtra: total - estimate,
      );
    }
    total += cent;
  }
  throw FormatException('Не удалось найти сумму отправки: проверьте тарифы.');
}
