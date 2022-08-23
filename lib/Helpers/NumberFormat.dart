class NumberFormat {
  static String format(int number) {
    if (number > 999 && number < 99999) {
      return "${(number / 1000).toStringAsFixed(1)}K";
    } else if (number > 99999 && number < 999999) {
      return "${(number / 1000).toStringAsFixed(0)}K";
    } else if (number > 999999 && number < 999999999) {
      return "${(number / 1000000).toStringAsFixed(1)}M";
    } else if (number > 999999999) {
      return "${(number / 1000000000).toStringAsFixed(1)}B";
    } else {
      return number.toString();
    }
  }
}