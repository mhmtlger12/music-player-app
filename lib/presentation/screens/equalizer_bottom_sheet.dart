import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:music_player/services/audio_player_service.dart';
import 'dart:ui';

class EqualizerBottomSheet extends StatefulWidget {
  const EqualizerBottomSheet({super.key});

  @override
  State<EqualizerBottomSheet> createState() => _EqualizerBottomSheetState();
}

class _EqualizerBottomSheetState extends State<EqualizerBottomSheet> {
  final AudioPlayerService _audioPlayerService = AudioPlayerService();

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: const BorderRadius.only(
        topLeft: Radius.circular(20.0),
        topRight: Radius.circular(20.0),
      ),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.grey.shade900.withOpacity(0.8),
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(20.0),
              topRight: Radius.circular(20.0),
            ),
          ),
          child: FutureBuilder<AndroidEqualizerParameters>(
            future: _audioPlayerService.getEqualizerParameters(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return const Center(child: CircularProgressIndicator());
              }
              final parameters = snapshot.data!;
              final bands = parameters.bands;
              return ListView.builder(
                itemCount: bands.length,
                itemBuilder: (context, index) {
                  final band = bands[index];
                  return Row(
                    children: [
                      Text(
                        '${band.centerFrequency.round()} Hz',
                        style: const TextStyle(color: Colors.white),
                      ),
                      Expanded(
                        child: StreamBuilder<double>(
                          stream: band.gainStream,
                          builder: (context, snapshot) {
                            return Slider(
                              value: snapshot.data ?? 0.0,
                              min: parameters.minDecibels,
                              max: parameters.maxDecibels,
                              onChanged: (value) {
                                _audioPlayerService.setBandGain(index, value);
                              },
                            );
                          },
                        ),
                      ),
                    ],
                  );
                },
              );
            },
          ),
        ),
      ),
    );
  }
}