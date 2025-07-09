import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:music_player/application/bloc/player_bloc.dart';

class HealthIndicator extends StatelessWidget {
  const HealthIndicator({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PlayerBloc, PlayerState>(
      builder: (context, state) {
        final level = state.decibelLevel;
        final (color, text) = _getStatus(level);

        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: color.withOpacity(0.2),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: color),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.hearing, color: color, size: 18),
              const SizedBox(width: 8),
              Text(
                text,
                style: TextStyle(color: color, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        );
      },
    );
  }

  (Color, String) _getStatus(double db) {
    if (db > -20) { // -20 dB (yaklaşık 90dB SPL) -> Tehlikeli
      return (Colors.red, "Tehlikeli Seviye!");
    } else if (db > -30) { // -30 dB (yaklaşık 80dB SPL) -> Dikkat
      return (Colors.orange, "Yüksek Ses");
    } else if (db > -40) { // -40 dB (yaklaşık 70dB SPL) -> Güvenli
      return (Colors.yellow, "Konforlu");
    } else {
      return (Colors.green, "Güvenli Seviye");
    }
  }
}