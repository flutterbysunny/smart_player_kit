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
  bool get isEnabled               => _activeIndex >= 0 || _cues.isNotEmpty;
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
    _cues = [];
    notifyListeners();
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

  /// ✅ Fix: Direct string se load karo — URL ki zaroorat nahi
  /// Test ya inline subtitles ke liye use karo
  void parseAndLoad(String content, SubtitleFormat format) {
    _cues = SubtitleParser.parse(content, format);
    // isEnabled = true karne ke liye activeIndex 0 set karo
    _activeIndex = 0;
    _currentCue = null;
    debugPrint('SubtitleController: ${_cues.length} cues loaded from string ✅');
    notifyListeners();
  }

  /// ✅ Fix: Position update — linear scan (short videos ke liye reliable)
  void updatePosition(Duration position) {
    if (_cues.isEmpty) {
      if (_currentCue != null) {
        _currentCue = null;
        notifyListeners();
      }
      return;
    }

    SubtitleCue? found;

    // Linear scan — short video mein fast enough hai
    // Long videos ke liye binary search use karo
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