import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'subtitle_track.dart';

/// Ek parsed subtitle cue
class SubtitleCue {
  final Duration start;
  final Duration end;
  final String text;

  const SubtitleCue({
    required this.start,
    required this.end,
    required this.text,
  });

  bool isActiveAt(Duration position) =>
      position >= start && position <= end;
}

/// SRT aur WEBVTT parser + HTTP fetcher
class SubtitleParser {

  /// ✅ Fix: URL se actual HTTP fetch karo
  static Future<List<SubtitleCue>> loadFromUrl(SubtitleTrack track) async {
    try {
      final uri = Uri.parse(track.url);
      final response = await http.get(uri, headers: {
        'Accept': 'text/vtt, text/plain, */*',
      }).timeout(const Duration(seconds: 10));

      if (response.statusCode != 200) {
        debugPrint('SmartPlayer Subtitle: HTTP ${response.statusCode} — ${track.url}');
        return [];
      }

      // Encoding detect karo
      final content = utf8.decode(response.bodyBytes, allowMalformed: true);

      if (content.trim().isEmpty) {
        debugPrint('SmartPlayer Subtitle: Empty response');
        return [];
      }

      final cues = parse(content, track.format);
      debugPrint('SmartPlayer Subtitle: ${cues.length} cues loaded ✅');
      return cues;
    } catch (e) {
      debugPrint('SmartPlayer Subtitle fetch error: $e');
      return [];
    }
  }

  /// String content parse karo (SRT ya VTT)
  static List<SubtitleCue> parse(String content, SubtitleFormat format) {
    // ✅ Fix: \r\n aur \r normalize karo
    final cleaned = content
        .replaceAll('\r\n', '\n')
        .replaceAll('\r', '\n')
        .trim();

    // Auto-detect format agar VTT header mile
    final actualFormat = cleaned.startsWith('WEBVTT')
        ? SubtitleFormat.webvtt
        : format;

    switch (actualFormat) {
      case SubtitleFormat.srt:
        return _parseSrt(cleaned);
      case SubtitleFormat.webvtt:
        return _parseVtt(cleaned);
    }
  }

  // ─── SRT Parser ───────────────────────────────────────────────────────────

  static List<SubtitleCue> _parseSrt(String content) {
    final cues = <SubtitleCue>[];
    final blocks = content.split(RegExp(r'\n{2,}'));

    for (final block in blocks) {
      final lines = block.trim().split('\n');
      if (lines.length < 2) continue;

      // Line 0 sequence number ho sakti hai — skip karo agar sirf digit hai
      int timeLineIdx = 0;
      if (RegExp(r'^\d+$').hasMatch(lines[0].trim())) {
        timeLineIdx = 1;
      }

      if (timeLineIdx >= lines.length) continue;

      final timeLine = lines[timeLineIdx];
      if (!timeLine.contains('-->')) continue;

      final times = _parseSrtTime(timeLine);
      if (times == null) continue;

      final text = lines.sublist(timeLineIdx + 1).join('\n').trim();
      final clean = _stripHtml(text);
      if (clean.isEmpty) continue;

      cues.add(SubtitleCue(start: times.$1, end: times.$2, text: clean));
    }

    debugPrint('SmartPlayer SRT: ${cues.length} cues parsed');
    return cues;
  }

  /// "00:01:23,456 --> 00:01:26,789"
  static (Duration, Duration)? _parseSrtTime(String line) {
    final m = RegExp(
      r'(\d{1,2}):(\d{2}):(\d{2}),(\d{3})\s*-->\s*(\d{1,2}):(\d{2}):(\d{2}),(\d{3})',
    ).firstMatch(line);
    if (m == null) return null;

    return (
    Duration(
      hours: int.parse(m.group(1)!),
      minutes: int.parse(m.group(2)!),
      seconds: int.parse(m.group(3)!),
      milliseconds: int.parse(m.group(4)!),
    ),
    Duration(
      hours: int.parse(m.group(5)!),
      minutes: int.parse(m.group(6)!),
      seconds: int.parse(m.group(7)!),
      milliseconds: int.parse(m.group(8)!),
    ),
    );
  }

  // ─── WEBVTT Parser ────────────────────────────────────────────────────────

  static List<SubtitleCue> _parseVtt(String content) {
    final cues = <SubtitleCue>[];

    // WEBVTT header + optional metadata skip karo
    String body = content;
    if (body.startsWith('WEBVTT')) {
      final firstNewline = body.indexOf('\n');
      body = firstNewline >= 0 ? body.substring(firstNewline + 1) : '';
    }

    final blocks = body.split(RegExp(r'\n{2,}'));

    for (final block in blocks) {
      final lines = block.trim().split('\n');
      if (lines.isEmpty) continue;

      // NOTE / STYLE / REGION blocks skip karo
      if (lines[0].startsWith('NOTE') ||
          lines[0].startsWith('STYLE') ||
          lines[0].startsWith('REGION')) {
        continue;
      }

      // --> wali line dhundo
      int timeIdx = -1;
      for (int i = 0; i < lines.length; i++) {
        if (lines[i].contains('-->')) {
          timeIdx = i;
          break;
        }
      }
      if (timeIdx < 0) continue;

      final times = _parseVttTime(lines[timeIdx]);
      if (times == null) continue;

      final text = lines.sublist(timeIdx + 1).join('\n').trim();
      final clean = _stripHtml(text);
      if (clean.isEmpty) continue;

      cues.add(SubtitleCue(start: times.$1, end: times.$2, text: clean));
    }

    debugPrint('SmartPlayer VTT: ${cues.length} cues parsed');
    return cues;
  }

  /// "00:01:23.456 --> 00:01:26.789 align:center"
  /// "01:23.456 --> 01:26.789"  (MM:SS.mmm format bhi)
  static (Duration, Duration)? _parseVttTime(String line) {
    final parts = line.split('-->');
    if (parts.length < 2) return null;

    final start = _parseVttTimestamp(parts[0].trim());
    // position cues (align:center etc.) hata ke sirf time lo
    final endStr = parts[1].trim().split(RegExp(r'\s+')).first;
    final end = _parseVttTimestamp(endStr);

    if (start == null || end == null) return null;
    return (start, end);
  }

  static Duration? _parseVttTimestamp(String t) {
    // HH:MM:SS.mmm
    var m = RegExp(r'^(\d{1,2}):(\d{2}):(\d{2})\.(\d{3})$').firstMatch(t);
    if (m != null) {
      return Duration(
        hours: int.parse(m.group(1)!),
        minutes: int.parse(m.group(2)!),
        seconds: int.parse(m.group(3)!),
        milliseconds: int.parse(m.group(4)!),
      );
    }
    // MM:SS.mmm
    m = RegExp(r'^(\d{1,2}):(\d{2})\.(\d{3})$').firstMatch(t);
    if (m != null) {
      return Duration(
        minutes: int.parse(m.group(1)!),
        seconds: int.parse(m.group(2)!),
        milliseconds: int.parse(m.group(3)!),
      );
    }
    return null;
  }

  // ─── HTML strip ───────────────────────────────────────────────────────────

  static String _stripHtml(String text) {
    return text
        .replaceAll(RegExp(r'<[^>]+>'), '')
        .replaceAll('&amp;', '&')
        .replaceAll('&lt;', '<')
        .replaceAll('&gt;', '>')
        .replaceAll('&nbsp;', ' ')
        .replaceAll('&quot;', '"')
        .replaceAll('&#39;', "'")
        .trim();
  }
}