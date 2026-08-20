import 'package:flutter/material.dart';

class AvoidHabit {
  final String id;
  final String name;
  final String blurb;
  final IconData icon;
  final int minutesCost;
  final double moneyCost;
  final bool premium;
  final List<String> replacements;
  final List<String> situations;

  const AvoidHabit({
    required this.id,
    required this.name,
    required this.blurb,
    required this.icon,
    required this.minutesCost,
    required this.moneyCost,
    this.premium = false,
    required this.replacements,
    required this.situations,
  });

  static const doomscrolling = AvoidHabit(
    id: 'doom',
    name: 'DOOMSCROLLING',
    blurb: 'Endless feeds, zero fulfillment',
    icon: Icons.gps_fixed,
    minutesCost: 25,
    moneyCost: 0,
    replacements: ['Read 10 pages', 'Walk outside', 'Text a friend', 'Stretch 3 minutes'],
    situations: ['In bed late', 'Bored between tasks', 'Waiting in line', 'After a hard meeting'],
  );

  static const shopping = AvoidHabit(
    id: 'shop',
    name: 'IMPULSE SHOPPING',
    blurb: 'Cart full, regret later',
    icon: Icons.shopping_bag_outlined,
    minutesCost: 18,
    moneyCost: 24,
    replacements: ['Wishlist instead', 'Walk outside', 'Wait 24 hours', 'Review last buy'],
    situations: ['Sale popup', 'Bored at lunch', 'Payday scroll', 'Late-night cart'],
  );

  static const caffeine = AvoidHabit(
    id: 'caffeine',
    name: 'LATE CAFFEINE',
    blurb: 'Wired at 1 AM, wrecked by 8',
    icon: Icons.local_cafe_outlined,
    minutesCost: 40,
    moneyCost: 5,
    replacements: ['Herbal tea', 'Warm shower', 'Lights down', 'Paper book'],
    situations: ['After 4 PM', 'Study crunch', 'Social coffee', 'Need a push'],
  );

  static const lateNight = AvoidHabit(
    id: 'late',
    name: 'STAYING UP',
    blurb: 'One more episode becomes three',
    icon: Icons.nightlight_outlined,
    minutesCost: 45,
    moneyCost: 0,
    premium: true,
    replacements: ['Alarm now', 'Charge phone away', 'Write tomorrow’s first task'],
    situations: ['Just one more', 'Can’t sleep yet', 'Weekend drift'],
  );

  static const sugar = AvoidHabit(
    id: 'sugar',
    name: 'SUGAR BINGE',
    blurb: 'Crash after the spike',
    icon: Icons.icecream_outlined,
    minutesCost: 15,
    moneyCost: 8,
    premium: true,
    replacements: ['Sparkling water', 'Walk 8 minutes', 'Protein snack'],
    situations: ['After dinner', 'Stress desk', 'Office treats'],
  );

  static const gossip = AvoidHabit(
    id: 'gossip',
    name: 'TOXIC SCROLL',
    blurb: 'Comments you will regret',
    icon: Icons.forum_outlined,
    minutesCost: 20,
    moneyCost: 0,
    premium: true,
    replacements: ['Mute thread', 'Draft, don’t send', 'Go outside'],
    situations: ['Group chat heat', 'News pile-on', 'Late replies'],
  );

  static const List<AvoidHabit> all = [doomscrolling, shopping, caffeine, lateNight, sugar, gossip];
  static const List<AvoidHabit> free = [doomscrolling, shopping, caffeine];

  static AvoidHabit byId(String id) {
    for (final h in all) {
      if (h.id == id) return h;
    }
    return doomscrolling;
  }
}

class TriggerEntry {
  final String id;
  final String habitId;
  final DateTime at;
  final String situation;
  final int urge;
  final String replacement;
  final int replacementMinutes;
  final String outcome;
  final bool rescued;

  const TriggerEntry({
    required this.id,
    required this.habitId,
    required this.at,
    required this.situation,
    required this.urge,
    required this.replacement,
    required this.replacementMinutes,
    required this.outcome,
    this.rescued = false,
  });

  AvoidHabit get habit => AvoidHabit.byId(habitId);

  String get urgeLabel {
    if (urge >= 9) return 'Very strong';
    if (urge >= 7) return 'Strong';
    if (urge >= 4) return 'Medium';
    return 'Low';
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'habitId': habitId,
        'at': at.toIso8601String(),
        'situation': situation,
        'urge': urge,
        'replacement': replacement,
        'replacementMinutes': replacementMinutes,
        'outcome': outcome,
        'rescued': rescued,
      };

  factory TriggerEntry.fromJson(Map<String, dynamic> json) => TriggerEntry(
        id: json['id'] as String,
        habitId: json['habitId'] as String? ?? 'doom',
        at: DateTime.tryParse(json['at'] as String? ?? '') ?? DateTime.now(),
        situation: json['situation'] as String? ?? '',
        urge: (json['urge'] as num?)?.toInt() ?? 5,
        replacement: json['replacement'] as String? ?? '',
        replacementMinutes: (json['replacementMinutes'] as num?)?.toInt() ?? 0,
        outcome: json['outcome'] as String? ?? '',
        rescued: json['rescued'] as bool? ?? false,
      );
}

class DayHold {
  final String date;
  final Set<String> heldIds;

  const DayHold({required this.date, required this.heldIds});

  Map<String, dynamic> toJson() => {'date': date, 'heldIds': heldIds.toList()};

  factory DayHold.fromJson(Map<String, dynamic> json) => DayHold(
        date: json['date'] as String,
        heldIds: ((json['heldIds'] as List?) ?? const []).cast<String>().toSet(),
      );
}
