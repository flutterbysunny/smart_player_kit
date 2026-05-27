import 'package:flutter/material.dart';
import '../../smart_player_kit.dart';

/// Video ke upar subtitle text — Positioned wrapper ke saath use karo
class SubtitleOverlay extends StatelessWidget {
  final SubtitleController subtitleController;
  final SmartPlayerTheme theme;
  final double bottomOffset;

  const SubtitleOverlay({
    super.key,
    required this.subtitleController,
    required this.theme,
    this.bottomOffset = 0,
  });

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: subtitleController,
      builder: (context, _) {
        final cue = subtitleController.currentCue;
        if (cue == null) return const SizedBox.shrink();

        return Padding(
          padding: EdgeInsets.fromLTRB(16, 0, 16, bottomOffset),
          child: Center(
            child: Container(
              padding:
              const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              decoration: BoxDecoration(
                color: theme.subtitleBackgroundColor,
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                cue.text,
                style: theme.subtitleTextStyle,
                textAlign: TextAlign.center,
                maxLines: 4,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
        );
      },
    );
  }
}