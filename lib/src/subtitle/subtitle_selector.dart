import 'package:flutter/material.dart';
import '../../smart_player_kit.dart';

/// Bottom sheet — subtitle language select karo
class SubtitleSelector extends StatelessWidget {
  final SubtitleController controller;
  final SmartPlayerTheme theme;

  const SubtitleSelector({
    super.key,
    required this.controller,
    required this.theme,
  });

  /// Bottom sheet show karo
  static void show(
      BuildContext context, {
        required SubtitleController controller,
        required SmartPlayerTheme theme,
      }) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.black87,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) => SubtitleSelector(controller: controller, theme: theme),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: controller,
      builder: (context, _) {
        return Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  const Icon(Icons.subtitles, color: Colors.white, size: 20),
                  const SizedBox(width: 8),
                  Text('Subtitles / CC',
                      style: theme.titleTextStyle),
                ],
              ),
              const SizedBox(height: 16),

              // Off option
              _TrackTile(
                label: 'Off',
                isSelected: !controller.isEnabled,
                onTap: () {
                  controller.disable();
                  Navigator.pop(context);
                },
                theme: theme,
              ),

              const Divider(color: Colors.white12, height: 16),

              // Language options
              ...List.generate(controller.tracks.length, (i) {
                final track = controller.tracks[i];
                return _TrackTile(
                  label: track.label,
                  sublabel: track.languageCode.toUpperCase(),
                  isSelected: controller.activeIndex == i,
                  isLoading: controller.isLoading && controller.activeIndex == i,
                  onTap: () {
                    controller.selectTrack(i);
                    Navigator.pop(context);
                  },
                  theme: theme,
                );
              }),

              const SizedBox(height: 8),
            ],
          ),
        );
      },
    );
  }
}

class _TrackTile extends StatelessWidget {
  final String label;
  final String? sublabel;
  final bool isSelected;
  final bool isLoading;
  final VoidCallback onTap;
  final SmartPlayerTheme theme;

  const _TrackTile({
    required this.label,
    this.sublabel,
    required this.isSelected,
    this.isLoading = false,
    required this.onTap,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: AnimatedSwitcher(
        duration: const Duration(milliseconds: 200),
        child: isLoading
            ? SizedBox(
          width: 20,
          height: 20,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            color: theme.primaryColor,
          ),
        )
            : Icon(
          isSelected ? Icons.check_circle : Icons.circle_outlined,
          color: isSelected ? theme.primaryColor : Colors.white38,
          size: 20,
        ),
      ),
      title: Text(
        label,
        style: TextStyle(
          color: isSelected ? Colors.white : Colors.white70,
          fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
        ),
      ),
      subtitle: sublabel != null
          ? Text(sublabel!,
          style: const TextStyle(color: Colors.white38, fontSize: 11))
          : null,
      onTap: onTap,
    );
  }
}