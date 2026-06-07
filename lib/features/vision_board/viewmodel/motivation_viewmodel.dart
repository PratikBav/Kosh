import 'dart:math';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final motivationViewModelProvider = StateNotifierProvider<MotivationViewModel, String>((ref) {
  return MotivationViewModel();
});

class MotivationViewModel extends StateNotifier<String> {
  MotivationViewModel() : super(_getRandomQuote());

  static const List<String> _quotes = [
    "Small savings become big dreams.",
    "Discipline compounds.",
    "Every rupee has a purpose.",
    "Your future is funded by today's choices.",
    "Consistency beats intensity.",
    "Invest in tools that multiply your value.",
    "A goal without a timeline is just a dream.",
    "Do not save what is left after spending, but spend what is left after saving.",
    "The best time to plant a tree was 20 years ago. The second best time is now.",
    "Don't tell me what you value, show me your budget.",
    "Wealth is not about having a lot of money; it's about having a lot of options.",
    "Every day is a bank account, and time is our currency.",
    "Financial freedom is available to those who learn about it and work for it.",
    "If you buy things you do not need, soon you will have to sell things you need.",
    "The habit of saving is itself an education.",
  ];

  static String _getRandomQuote() {
    // A daily seed based on the date could be implemented here 
    // to keep the same quote for the whole day, e.g., Random(DateTime.now().day)
    final today = DateTime.now();
    final seed = today.year * 10000 + today.month * 100 + today.day;
    final dailyRandom = Random(seed);
    
    return _quotes[dailyRandom.nextInt(_quotes.length)];
  }

  void refreshQuote() {
    // Manually refresh to a truly random quote
    final random = Random();
    state = _quotes[random.nextInt(_quotes.length)];
  }
}
