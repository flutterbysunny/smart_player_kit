import 'package:flutter/foundation.dart';
import 'subtitle_track.dart';
import 'subtitle_parser.dart';

class SubtitleController extends ChangeNotifier {
  List<SubtitleTrack> _tracks = [];
  int _activeIndex = -1;
  List<SubtitleCue> _cues = [];
  SubtitleCue? _currentCue;
  bool _isLoading = false;
  String? _error;

  List<SubtitleTrack> get tracks   => _tracks;
  int get activeIndex              => _activeIndex;
  SubtitleCue? get currentCue      => _currentCue;
  bool get isLoading               => _isLoading;
  bool get hasSubtitles            => _tracks.isNotEmpty;
  // ✅ Fix: sirf _activeIndex check karo — _cues pe depend mat karo
  bool get isEnabled               => _activeIndex >= 0;
  String? get error                => _error;
  int get cueCount                 => _cues.length;

  void setTracks(List<SubtitleTrack> tracks, {int defaultIndex = -1}) {
    _tracks = tracks;
    _activeIndex = defaultIndex;
    _currentCue = null;
    _cues = [];

    if (defaultIndex >= 0 && defaultIndex < tracks.length) {
      _loadTrack(defaultIndex);
    }
    notifyListeners();
  }

  Future<void> selectTrack(int index) async {
    if (index == _activeIndex) return;
    if (index < -1 || index >= _tracks.length) return;

    _activeIndex = index;
    _currentCue = null;
    _cues = [];
    _error = null;
    notifyListeners();

    if (index >= 0) await _loadTrack(index);
  }

  Future<void> disable() async {
    _activeIndex = -1;
    _currentCue = null;
    notifyListeners();
  }

  /// Inline cues wapas enable karo (disable ke baad)
  void enableInline() {
    if (_cues.isNotEmpty) {
      _activeIndex = 0;
      notifyListeners();
    }
  }

  Future<void> _loadTrack(int index) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _cues = await SubtitleParser.loadFromUrl(_tracks[index]);
      if (_cues.isEmpty) {
        _error = 'Subtitle file mein koi cues nahi mile';
      }
    } catch (e) {
      _cues = [];
      _error = e.toString();
      debugPrint('SubtitleController error: $e');
    }

    _isLoading = false;
    notifyListeners();
  }

  /// Direct string se load karo — URL ki zaroorat nahi
  void parseAndLoad(String content, SubtitleFormat format) {
    if (content.trim().isNotEmpty) {
      _cues = SubtitleParser.parse(content, format);
    }
    // ✅ Enable — activeIndex 0
    _activeIndex = 0;
    _currentCue = null;
    debugPrint('SubtitleController: ${_cues.length} cues loaded ✅');
    notifyListeners();
  }

  /// Position update — sirf isEnabled ho tab dikhao
  void updatePosition(Duration position) {
    // ✅ Fix: isEnabled false = cue clear karo, subtitle band
    if (!isEnabled) {
      if (_currentCue != null) {
        _currentCue = null;
        notifyListeners();
      }
      return;
    }

    if (_cues.isEmpty) return;

    SubtitleCue? found;
    for (final cue in _cues) {
      if (cue.isActiveAt(position)) {
        found = cue;
        break;
      }
    }

    if (found?.text != _currentCue?.text) {
      _currentCue = found;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _cues = [];
    _tracks = [];
    _currentCue = null;
    super.dispose();
  }
}