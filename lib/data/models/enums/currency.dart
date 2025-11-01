enum Currency {
  usd('USD', '\$', 'US Dollar'),
  eur('EUR', '€', 'Euro'),
  gbp('GBP', '£', 'British Pound'),
  jpy('JPY', '¥', 'Japanese Yen'),
  cad('CAD', 'C\$', 'Canadian Dollar'),
  aud('AUD', 'A\$', 'Australian Dollar'),
  chf('CHF', 'CHF', 'Swiss Franc'),
  cny('CNY', '¥', 'Chinese Yuan'),
  inr('INR', '₹', 'Indian Rupee'),
  krw('KRW', '₩', 'South Korean Won'),
  brl('BRL', 'R\$', 'Brazilian Real'),
  mxn('MXN', '\$', 'Mexican Peso'),
  nzd('NZD', 'NZ\$', 'New Zealand Dollar'),
  sek('SEK', 'kr', 'Swedish Krona'),
  nok('NOK', 'kr', 'Norwegian Krone'),
  dkk('DKK', 'kr', 'Danish Krone'),
  pln('PLN', 'zł', 'Polish Złoty'),
  rub('RUB', '₽', 'Russian Ruble'),
  zar('ZAR', 'R', 'South African Rand'),
  sgd('SGD', 'S\$', 'Singapore Dollar'),
  php('PHP', '₱', 'Philippine Peso'),
  ngn('NGN', '₦', 'Nigerian Naira'),
  kes('KES', 'KSh', 'Kenyan Shilling'),
  egp('EGP', 'E£', 'Egyptian Pound'),
  mad('MAD', 'MAD', 'Moroccan Dirham'),
  ghs('GHS', 'GH₵', 'Ghanaian Cedi'),
  tzs('TZS', 'TSh', 'Tanzanian Shilling'),
  ugx('UGX', 'USh', 'Ugandan Shilling'),
  eth('ETB', 'Br', 'Ethiopian Birr'),
  xof('XOF', 'CFA', 'West African CFA Franc'),
  xaf('XAF', 'FCFA', 'Central African CFA Franc'),
  // Middle East
  aed('AED', 'د.إ', 'UAE Dirham'),
  sar('SAR', 'ر.س', 'Saudi Riyal'),
  ils('ILS', '₪', 'Israeli Shekel'),
  qar('QAR', 'ر.ق', 'Qatari Riyal'),
  // Asia-Pacific
  idr('IDR', 'Rp', 'Indonesian Rupiah'),
  thb('THB', '฿', 'Thai Baht'),
  vnd('VND', '₫', 'Vietnamese Dong'),
  myr('MYR', 'RM', 'Malaysian Ringgit'),
  hkd('HKD', 'HK\$', 'Hong Kong Dollar'),
  pkr('PKR', '₨', 'Pakistani Rupee'),
  bdt('BDT', '৳', 'Bangladeshi Taka'),
  twd('TWD', 'NT\$', 'Taiwan Dollar'),
  lkr('LKR', 'Rs', 'Sri Lankan Rupee'),
  // South America
  ars('ARS', '\$', 'Argentine Peso'),
  clp('CLP', '\$', 'Chilean Peso'),
  cop('COP', '\$', 'Colombian Peso'),
  // Europe & Middle East
  try_('TRY', '₺', 'Turkish Lira'),
  czk('CZK', 'Kč', 'Czech Koruna'),
  huf('HUF', 'Ft', 'Hungarian Forint');

  const Currency(this.code, this.symbol, this.name);

  final String code;
  final String symbol;
  final String name;

  /// Get currency by code (case insensitive)
  static Currency? fromCode(String code) {
    try {
      return Currency.values.firstWhere(
        (currency) => currency.code.toLowerCase() == code.toLowerCase(),
      );
    } catch (e) {
      return null;
    }
  }

  /// Get default currency based on locale
  static Currency getDefaultForLocale(String? locale) {
    if (locale == null) return Currency.usd;

    final lowerLocale = locale.toLowerCase();

    // Map common locales to currencies
    if (lowerLocale.contains('us') || lowerLocale.contains('en_us')) return Currency.usd;
    if (lowerLocale.contains('gb') || lowerLocale.contains('en_gb')) return Currency.gbp;
    if (lowerLocale.contains('eu') || lowerLocale.contains('de') || lowerLocale.contains('fr') || lowerLocale.contains('it') || lowerLocale.contains('es')) return Currency.eur;
    if (lowerLocale.contains('jp')) return Currency.jpy;
    if (lowerLocale.contains('ca') || lowerLocale.contains('en_ca')) return Currency.cad;
    if (lowerLocale.contains('au') || lowerLocale.contains('en_au')) return Currency.aud;
    if (lowerLocale.contains('ch')) return Currency.chf;
    if (lowerLocale.contains('cn') || lowerLocale.contains('zh')) return Currency.cny;
    if (lowerLocale.contains('in')) return Currency.inr;
    if (lowerLocale.contains('kr')) return Currency.krw;
    if (lowerLocale.contains('br') || lowerLocale.contains('pt_br')) return Currency.brl;
    if (lowerLocale.contains('mx') || lowerLocale.contains('es_mx')) return Currency.mxn;
    if (lowerLocale.contains('nz')) return Currency.nzd;
    if (lowerLocale.contains('se')) return Currency.sek;
    if (lowerLocale.contains('no')) return Currency.nok;
    if (lowerLocale.contains('dk')) return Currency.dkk;
    if (lowerLocale.contains('pl')) return Currency.pln;
    if (lowerLocale.contains('ru')) return Currency.rub;
    if (lowerLocale.contains('za')) return Currency.zar;
    if (lowerLocale.contains('sg')) return Currency.sgd;
    if (lowerLocale.contains('ph')) return Currency.php;
    if (lowerLocale.contains('ng')) return Currency.ngn;
    if (lowerLocale.contains('ke')) return Currency.kes;
    if (lowerLocale.contains('eg')) return Currency.egp;
    if (lowerLocale.contains('ma')) return Currency.mad;
    if (lowerLocale.contains('gh')) return Currency.ghs;
    if (lowerLocale.contains('tz')) return Currency.tzs;
    if (lowerLocale.contains('ug')) return Currency.ugx;
    if (lowerLocale.contains('et')) return Currency.eth;
    // West African CFA Franc countries: Benin, Burkina Faso, Côte d'Ivoire, Guinea-Bissau, Mali, Niger, Senegal, Togo
    if (lowerLocale.contains('bj') || lowerLocale.contains('bf') || lowerLocale.contains('ci') ||
        lowerLocale.contains('gw') || lowerLocale.contains('ml') || lowerLocale.contains('ne') ||
        lowerLocale.contains('sn') || lowerLocale.contains('tg')) return Currency.xof;
    // Central African CFA Franc countries: Cameroon, Central African Republic, Chad, Republic of Congo, Equatorial Guinea, Gabon
    if (lowerLocale.contains('cm') || lowerLocale.contains('cf') || lowerLocale.contains('td') ||
        lowerLocale.contains('cg') || lowerLocale.contains('gq') || lowerLocale.contains('ga')) return Currency.xaf;
    // Middle East
    if (lowerLocale.contains('ae')) return Currency.aed;
    if (lowerLocale.contains('sa')) return Currency.sar;
    if (lowerLocale.contains('il')) return Currency.ils;
    if (lowerLocale.contains('qa')) return Currency.qar;
    // Asia-Pacific
    if (lowerLocale.contains('id')) return Currency.idr;
    if (lowerLocale.contains('th')) return Currency.thb;
    if (lowerLocale.contains('vn') || lowerLocale.contains('vi')) return Currency.vnd;
    if (lowerLocale.contains('my')) return Currency.myr;
    if (lowerLocale.contains('hk')) return Currency.hkd;
    if (lowerLocale.contains('pk')) return Currency.pkr;
    if (lowerLocale.contains('bd')) return Currency.bdt;
    if (lowerLocale.contains('tw')) return Currency.twd;
    if (lowerLocale.contains('lk')) return Currency.lkr;
    // South America
    if (lowerLocale.contains('ar')) return Currency.ars;
    if (lowerLocale.contains('cl')) return Currency.clp;
    if (lowerLocale.contains('co')) return Currency.cop;
    // Europe & Turkey
    if (lowerLocale.contains('tr')) return Currency.try_;
    if (lowerLocale.contains('cz')) return Currency.czk;
    if (lowerLocale.contains('hu')) return Currency.huf;

    // Default to USD if no match found
    return Currency.usd;
  }

  @override
  String toString() => '$symbol ($code)';
}
