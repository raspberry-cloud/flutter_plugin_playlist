part of flutter_plugin_playlist;

/**
 * Callback function for the on(eventName) handlers
 */
typedef AudioPlayerEventHandler = Function(String eventname, {dynamic args});

/**
 * @internal
 * The collection of event handlers currently held by the plugin
 */
class AudioPlayerEventHandlers {
  Map<String, List<AudioPlayerEventHandler>> _map = new Map();

  List<AudioPlayerEventHandler> operator [](String key) {
    return _map[key];
  }

  void operator []=(String key, List<AudioPlayerEventHandler> value) {
    _map[key] = value;
  }

}

/**
 * Options governing the overall behavior of the audio player plugin
 */
class AudioPlayerOptions {
  /**
   * Should the plugin's javascript dump the status message stream to the javascript console?
   */
  final bool verbose;
  /**
   * If true, when pausing a live stream, play will continue from the LIVE POSITION (e.g. the stream
   * jumps forward to the current point in time, rather than picking up where it left off when you paused).
   * If false, the stream will continue where you paused. The drawback of doing this is that when the audio
   * buffer fills, it will jump forward to the current point in time, cause a disjoint in playback.
   *
   * Default is true.
   */
  final bool resetStreamOnPause;

  const AudioPlayerOptions({
    this.resetStreamOnPause,
    this.verbose
  });

  Map<String, dynamic> toJson() {
    return {
      'verbose': verbose,
      'resetStreamOnPause': resetStreamOnPause
    };
  }
}

/**
 * Options governing how the items are managed when using setPlaylistItems
 * to update the playlist. This is typically useful if you are retaining items
 * that were in the previous list.
 */
class PlaylistItemOptions {
  /**
   * If true, the plugin will continue playback from the current playback position after
   * setting the items to the playlist.
   */
  final retainPosition;
  /**
   * If retainPosition is true, this value will tell the plugin the exact time to start from,
   * rather than letting the plugin decide based on current playback.
   */
  final num playFromPosition;
  /**
   * If retainPosition is true, this value will tell the plugin the uid of the "current" item to start from,
   * rather than letting the plugin decide based on current playback.
   */
  final  num playFromId;
  /**
   * If playback should immediately begin when calling setPlaylistItems on the plugin.
   * Default is false;
   */
  final  bool startPaused;

  const PlaylistItemOptions({
    this.playFromId,
    this.playFromPosition,
    this.retainPosition,
    this.startPaused,
  });

  Map<String, dynamic> toJson() {
    return {
      'playFromId': playFromId,
      'playFromPosition': playFromPosition,
      'retainPosition': retainPosition,
      'startPaused': startPaused
    };
  }
}

/**
 * An audio track for playback by the playlist.
 */
class AudioTrack {
  /**
   * This item is a streaming asset. Make sure this is set to true for stream URLs,
   * otherwise you will get odd behavior when the asset is paused.
   */
  final bool isStream;
  /**
   * trackId is optional and if not passed in, an auto-generated UUID will be used.
   */
  String trackId;
  /**
   * URL of the asset; can be local, a URL, or a streaming URL.
   * If the asset is a stream, make sure that isStream is set to true,
   * otherwise the plugin can't properly handle the item's buffer.
   */
  final String assetUrl;
  /**
   * The local or remote URL to an image asset to be shown for this track.
   * If this is null, the plugin's default image is used.
   * This field is not used on iOS (yet)
   */
  final String albumArt;
  /**
   * The track's artist
   */
  final String artist;
  /**
   * Album the track belongs to
   */
  final String album;
  /**
   * Title of the track
   */
  final String title;

  AudioTrack({
    this.trackId,
    this.isStream = false,
    @required this.album,
    this.albumArt,
    @required this.artist,
    @required this.assetUrl,
    @required this.title
  });

  factory AudioTrack.fromJson(dynamic json) {
    return AudioTrack(
      title: json['title'],
      album: json['album'],
      artist: json['artist'],
      assetUrl: json['assetUrl'],
      trackId: json['trackId'],
      albumArt: json['albumArt'],
      isStream: json['isStream']
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'trackId': trackId,
      'isStream': isStream,
      'album': album,
      'albumArt': albumArt,
      'artist': artist,
      'assetUrl': assetUrl,
      'title': title,
    };
  }
}

/**
 * Encapsulates the fields you can pass to the plugin to remove a track.
 * You can either remove a track by its ID if you know it, or by index if you know it;
 * Index will be preferred if both index and ID are passed.
 */
class AudioTrackRemoval {
  /**
   * The track ID to remove
   */
  final String trackId;
  /**
   * The index of a track to remove.
   */
  final num trackIndex;

  const AudioTrackRemoval({
    this.trackId,
    this.trackIndex
  });

  Map<String, dynamic> toJson() {
    return {
      'trackId': trackId,
      'trackIndex': trackIndex,
    };
  }
}

/**
 * Encapsulates the data received by an onStatus callback
 */
class OnStatusCallbackData {
  /**
   * The ID of this track. If the track is null or has completed, this value is "NONE"
   * If the playlist is completed, this value is "INVALID"
   */
  final String trackId;
  /**
   * The type of status update
   */
  final int type;
  /**
   * The status payload. For all updates except ERROR, the data package is described by OnStatusCallbackUpdateData.
   * For Errors, the data is shaped as OnStatusErrorCallbackData
   * OnStatusCallbackUpdateData | OnStatusTrackChangedData | OnStatusErrorCallbackData
   */
  final dynamic value;

  const OnStatusCallbackData({
    this.trackId,
    this.value,
    this.type
  });

  Map<String, dynamic> toJson() {
    return {
      'trackId': trackId,
      'value': value,
      'type': type,
    };
  }
}

/**
 * Reports information about the playlist state when a track changes.
 * Includes the new track, its index, and the state of the playlist.
 */
class OnStatusTrackChangedData {
  /**
   * The new track that has been selected. May be null if you are at the end of the playlist,
   * or the playlist has been emptied.
   */
  final AudioTrack currentItem;
  /**
   * The 0-based index of the new track. If the playlist has ended or been cleared, this will be -1.
   */
  final num currentIndex;
  /**
   * Indicates whether the playlist is now currently at the last item in the list.
   */
  final bool isAtEnd;
  /**
   * Indicates whether the playlist is now at the first item in the list
   */
  final bool isAtBeginning;
  /**
   * Indicates if there are additional playlist items after the current item.
   */
  final bool hasNext;
  /**
   * Indicates if there are any items before this one in the playlist.
   */
  final bool hasPrevious;

  const OnStatusTrackChangedData({
    this.currentIndex,
    this.currentItem,
    this.hasNext,
    this.hasPrevious,
    this.isAtBeginning,
    this.isAtEnd,
  });

  Map<String, dynamic> toJson() {
    return {
      'currentIndex': currentIndex,
      'currentItem': currentItem,
      'hasNext': hasNext,
      'hasPrevious': hasPrevious,
      'isAtBeginning': isAtBeginning,
      'isAtEnd': isAtEnd,
    };
  }
}

/**
 * Contains the current track status as of the moment an onStatus update event is emitted.
 */
class OnStatusCallbackUpdateData {
  /**
   * The ID of this track corresponding to this event. If the track is null or has completed, this value is "NONE".
   * This will happen when skipping to the beginning or end of the playlist.
   * If the playlist is completed, this value is "INVALID"
   */
  final String trackId;
  /**
   * Boolean indicating whether this is a streaming track.
   */
  final bool isStream;
  /**
   * The current index of the track in the playlist.
   */
  final num currentIndex;
  /**
   * The current status of the track, as a string. This is used
   * to summarize the various event states that a track can be in; e.g. "playing" is true for any number
   * of track statuses. The Javascript interface takes care of this for you; this field is here only for reference.
   * 'unknown' | 'ready' | 'error' | 'playing' | 'loading' | 'paused'
   */
  final String status;
  /**
   * Current playback position of the reported track.
   */
  final num currentPosition;
  /**
   * The known duration of the reported track. For streams or malformed MP3's, this value will be 0.
   */
  final num duration;
  /**
   * Progress of track playback, as a percent, in the range 0 - 100
   */
  final num playbackPercent;
  /**
   * Buffering progress of the track, as a percent, in the range 0 - 100
   */
  final num bufferPercent;
  /**
   * The starting position of the buffering progress. For now, this is always reported as 0.
   */
  final num bufferStart;
  /**
   * The maximum position, in seconds, of the track buffer. For now, only the buffer with the maximum
   * playback position is reported, even if there are other segments (due to seeking, for example).
   * Practically speaking you don't need to worry about that, as in both implementations the
   * minor gaps are automatically filled in by the underlying players.
   */
  final num bufferEnd;

  const OnStatusCallbackUpdateData({
    this.status,
    this.bufferEnd,
    this.bufferPercent,
    this.bufferStart,
    this.currentIndex,
    this.currentPosition,
    this.duration,
    this.isStream,
    this.playbackPercent,
    this.trackId
  });

  Map<String, dynamic> toJson() {
    return {
      'status': status,
      'bufferEnd': bufferEnd,
      'bufferPercent': bufferPercent,
      'bufferStart': bufferStart,
      'currentIndex': currentIndex,
      'currentPosition': currentPosition,
      'duration': duration,
      'isStream': isStream,
      'playbackPercent': playbackPercent,
      'trackId': trackId,
    };
  }
}

/**
 * Represents an error reported by the onStatus callback.
 */
class OnStatusErrorCallbackData {
  /**
   * Error code
   */
  final RmxAudioErrorType code;
  /**
   * The error, as a message
   */
  final String message;

  const OnStatusErrorCallbackData({
    this.code,
    this.message
  });

  Map<String, dynamic> toJson() {
    return {
      'code': code,
      'message': message,
    };
  }

}

/**
 * Function declaration for onStatus event handlers
 */
typedef OnStatusCallback = Function(OnStatusCallbackData info);
/**
 * Function declaration for the successCallback fields of the Cordova functions
 */
typedef SuccessCallback = Function({dynamic args});
/**
 * Function declaration for the errorCallback fields of the Cordova functions
 */
typedef ErrorCallback = Function(dynamic error);