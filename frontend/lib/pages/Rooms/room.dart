import 'package:meeting_app/models/vote/vote_proposal.dart';
import 'package:meeting_app/models/vote/vote_results.dart';
import 'package:meeting_app/models/vote/vote_session.dart';
import 'package:meeting_app/services/api_service.dart';
import 'package:meeting_app/widgets/Rooms/AI_sidebar/edit_vote_card.dart';
import 'package:meeting_app/widgets/Rooms/AI_sidebar/vote_results_card.dart';
import 'package:meeting_app/widgets/Rooms/AI_sidebar/ai_vote_card.dart';
import 'package:meeting_app/widgets/Rooms/AI_sidebar/ai_summary_card.dart';

import 'dart:async';
import 'dart:convert';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:livekit_client/livekit_client.dart';
import 'package:meeting_app/utils/exts.dart';
import 'package:meeting_app/widgets/Rooms/participant.dart';
import 'package:meeting_app/widgets/Rooms/participant_info.dart';
import 'package:meeting_app/utils/utils.dart';

import '../../widgets/Rooms/controls.dart';
import '../../widgets/Rooms/AI_sidebar/ai_assistant_sidebar.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';


class RoomPage extends StatefulWidget {
  final Room room;
  final EventsListener<RoomEvent> listener;

  const RoomPage(
    this.room,
    this.listener, {
    super.key,
  });


  @override
  State<StatefulWidget> createState() => _RoomPageState();
}

class _RoomPageState extends State<RoomPage> {
  List<ParticipantTrack> participantTracks = [];
  EventsListener<RoomEvent> get _listener => widget.listener;
  bool get fastConnection => widget.room.engine.fastConnectOptions != null;

  // Vote lifecycle state
  VoteProposal? _currentVoteProposal;
  VoteSession? _currentVoteSession;
  VoteResults? _currentVoteResults;

  bool _isSidebarVisible = false;
  bool _isAgentPresent = false;

  // GlobalKey for AiSummaryCard to access its state
  final GlobalKey _aiSummaryCardKey = GlobalKey();

  bool _allowPop = false;
  @override
  void initState() {
    super.initState();
    // add callback for a `RoomEvent` as opposed to a `ParticipantEvent`
    widget.room.addListener(_onRoomDidUpdate);
    // add callbacks for finer grained events
    _setUpListeners();
    _sortParticipants();
    WidgetsBindingCompatible.instance?.addPostFrameCallback((_) {
      if (!fastConnection) {
        _askPublish();
      }
    });

    if (lkPlatformIs(PlatformType.android)) {
      Hardware.instance.setSpeakerphoneOn(true);
    }

    if (lkPlatformIsDesktop()) {
      onWindowShouldClose = () async {
        unawaited(widget.room.disconnect());
        await _listener.waitFor<RoomDisconnectedEvent>(
            duration: const Duration(seconds: 5));
      };
    }
  }

  @override
  void dispose() {
    // always dispose listener
    (() async {
      widget.room.removeListener(_onRoomDidUpdate);
      await _listener.dispose();
      await widget.room.dispose();
    })();
    onWindowShouldClose = null;
    super.dispose();
  }

  /// for more information, see [event types](https://docs.livekit.io/client/events/#events)
  void _setUpListeners() => _listener
    ..on<RoomDisconnectedEvent>((event) async {
      if (event.reason != null) {
        print('Room disconnected: reason => ${event.reason}');
      }
      WidgetsBindingCompatible.instance?.addPostFrameCallback(
          (timeStamp) => Navigator.popUntil(context, (route) => route.isFirst));
    })
    ..on<ParticipantEvent>((event) {
      // sort participants on many track events as noted in documentation linked above
      _sortParticipants();
    })
    ..on<RoomRecordingStatusChanged>((event) {
      context.showRecordingStatusChangedDialog(event.activeRecording);
    })
    ..on<RoomAttemptReconnectEvent>((event) {
      print(
          'Attempting to reconnect ${event.attempt}/${event.maxAttemptsRetry}, '
          '(${event.nextRetryDelaysInMs}ms delay until next attempt)');
    })
    ..on<LocalTrackSubscribedEvent>((event) {
      print('Local track subscribed: ${event.trackSid}');
    })
    ..on<LocalTrackPublishedEvent>((_) => _sortParticipants())
    ..on<LocalTrackUnpublishedEvent>((_) => _sortParticipants())
    ..on<TrackSubscribedEvent>((_) => _sortParticipants())
    ..on<TrackUnsubscribedEvent>((_) => _sortParticipants())
    ..on<TrackE2EEStateEvent>(_onE2EEStateEvent)
    ..on<ParticipantNameUpdatedEvent>((event) {
      print(
          'Participant name updated: ${event.participant.identity}, name => ${event.name}');
      _sortParticipants();
    })
    ..on<ParticipantMetadataUpdatedEvent>((event) {
      print(
          'Participant metadata updated: ${event.participant.identity}, metadata => ${event.metadata}');
    })
    ..on<RoomMetadataChangedEvent>((event) {
      print('Room metadata changed: ${event.metadata}');
    })
    ..on<DataReceivedEvent>((event) {
      try {
        String decodedString = utf8.decode(event.data);
        Map<String, dynamic> jsonData = jsonDecode(decodedString);
        
        switch (jsonData['type']) {
          case 'VOTE_CREATED':
            setState(() {
              _currentVoteProposal = VoteProposal.fromJson(jsonData);
              _currentVoteSession = null;
              _currentVoteResults = null;
              _isSidebarVisible = true;
            });
            break;
          case 'VOTE_STARTED':
            setState(() {
              _currentVoteProposal = null;
              _currentVoteSession = VoteSession.fromJson(jsonData);
              _currentVoteResults = null;
              _isSidebarVisible = true;
            });
            break;
          case 'VOTE_ENDED':
             setState(() {
              _currentVoteProposal = null;
              _currentVoteSession = null;
              _currentVoteResults = VoteResults.fromJson(jsonData);
              _isSidebarVisible = true;
            });
             break;
          case 'RECAP_GENERATED':
            // Handle recap data from Agent
            final recapData = jsonData['data'] as Map<String, dynamic>?;
            if (recapData != null) {
              // Reset loading state and show recap dialog
              final state = _aiSummaryCardKey.currentState;
              if (state != null) {
                (state as dynamic).resetLoadingState();
                (state as dynamic).showRecapDialog(context, recapData);
              }
            }
            break;
          default:
            context.showDataReceivedDialog(decodedString);
            break;
        }

      } catch (e) {
        print("Error decoding or handling data: $e");
      }
    })
    ..on<AudioPlaybackStatusChanged>((event) async {
      if (!widget.room.canPlaybackAudio) {
        print('Audio playback failed for iOS Safari ..........');
        bool? yesno = await context.showPlayAudioManuallyDialog();
        if (yesno == true) {
          await widget.room.startAudio();
        }
      }
    });

  void _askPublish() async {
    final result = await context.showPublishDialog();
    if (result != true) return;
    // video will fail when running in ios simulator
    try {
      await widget.room.localParticipant?.setCameraEnabled(true);
    } catch (error) {
      print('could not publish video: $error');
      await context.showErrorDialog(error);
    }
    try {
      await widget.room.localParticipant?.setMicrophoneEnabled(true);
    } catch (error) {
      print('could not publish audio: $error');
      await context.showErrorDialog(error);
    }
  }

  void _onRoomDidUpdate() {
    _sortParticipants();
  }

  void _onE2EEStateEvent(TrackE2EEStateEvent e2eeState) {
    print('e2ee state: $e2eeState');
  }

  void _sortParticipants() {
    List<ParticipantTrack> userMediaTracks = [];
    List<ParticipantTrack> screenTracks = [];
    final participantsWithUserMedia = <Participant>{};

    bool agentFound = false;

    for (var participant in widget.room.remoteParticipants.values) {
      if (participant.identity.toLowerCase().contains("agent")) {
        agentFound = true;
        continue;
      }
      
      for (var t in participant.videoTrackPublications) {
        if (t.isScreenShare) {
          screenTracks.add(ParticipantTrack(
            participant: participant,
            type: ParticipantTrackType.kScreenShare,
          ));
        } else {
          userMediaTracks.add(ParticipantTrack(participant: participant));
          participantsWithUserMedia.add(participant);
        }
      }
    }
    
    _isAgentPresent = agentFound;

    for (var participant in widget.room.remoteParticipants.values) {
      if (participant.identity.toLowerCase().contains("agent")) continue;
      if (!participantsWithUserMedia.contains(participant)) {
        userMediaTracks.add(ParticipantTrack(participant: participant));
      }
    }

    // sort speakers for the grid
    userMediaTracks.sort((a, b) {
      // loudest speaker first
      if (a.participant.isSpeaking && b.participant.isSpeaking) {
        if (a.participant.audioLevel > b.participant.audioLevel) {
          return -1;
        } else {
          return 1;
        }
      }

      // last spoken at
      final aSpokeAt = a.participant.lastSpokeAt?.millisecondsSinceEpoch ?? 0;
      final bSpokeAt = b.participant.lastSpokeAt?.millisecondsSinceEpoch ?? 0;

      if (aSpokeAt != bSpokeAt) {
        return aSpokeAt > bSpokeAt ? -1 : 1;
      }

      // video on
      if (a.participant.hasVideo != b.participant.hasVideo) {
        return a.participant.hasVideo ? -1 : 1;
      }

      // joinedAt
      return a.participant.joinedAt.millisecondsSinceEpoch -
          b.participant.joinedAt.millisecondsSinceEpoch;
    });

    final localParticipant = widget.room.localParticipant;
    if (localParticipant != null) {
      final localParticipantTracks = localParticipant.videoTrackPublications;
      bool hasUserMedia = false;
      for (var t in localParticipantTracks) {
        if (t.isScreenShare) {
          screenTracks.add(ParticipantTrack(
            participant: localParticipant,
            type: ParticipantTrackType.kScreenShare,
          ));
        } else {
          hasUserMedia = true;
        }
      }
      userMediaTracks.add(
            ParticipantTrack(participant: localParticipant));
    }

    setState(() {
      participantTracks = [...screenTracks, ...userMediaTracks];
    });
  }

  int _getCrossAxisCount() {
    if (participantTracks.length == 1) {
      return 1;
    }
    if (participantTracks.length <= 4) {
      return 2;
    } else if (participantTracks.length <= 9) {
      return 3;
    }
    return 4;
  }

  void _toggleSidebar() {
    setState(() {
      _isSidebarVisible = !_isSidebarVisible;
    });
  }

  List<Widget> _buildSidebarWidgets() {
    final localParticipant = widget.room.localParticipant;
    final voteProposal = _currentVoteProposal;

    List<Widget> sidebarWidgets = [];
    
    // Always show AiSummaryCard
    sidebarWidgets.add(Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: AiSummaryCard(
        key: _aiSummaryCardKey,
        room: widget.room,
      ),
    ));

    if (localParticipant != null) {
      // Proposer sees the edit card
      if (voteProposal != null && voteProposal.proposerId == localParticipant.identity) {
        sidebarWidgets.add(Padding(
          padding: const EdgeInsets.only(bottom: 16.0),
          child: EditVoteCard(
            proposal: voteProposal,
            onCancel: () => setState(() => _currentVoteProposal = null),
            onStart: (topic, options) {
              ApiService.startVote(
                roomName: widget.room.name ?? "Unknown Room",
                topic: topic,
                options: options,
                proposerId: voteProposal.proposerId,
              );
              setState(() => _currentVoteProposal = null);
            },
          ),
        ));
      }

      // All users see the voting card
      if (_currentVoteSession != null) {
        sidebarWidgets.add(Padding(
          padding: const EdgeInsets.only(bottom: 16.0),
          child: AiVoteCard(
            voteSession: _currentVoteSession!,
            voterId: localParticipant.identity,
            isProposer: localParticipant.identity == _currentVoteSession!.proposerId,
            onRemove: () => setState(() => _currentVoteSession = null),
          ),
        ));
      }

      // All users see the results card
      if (_currentVoteResults != null) {
        sidebarWidgets.add(Padding(
          padding: const EdgeInsets.only(bottom: 16.0),
          child: VoteResultsCard(
            results: _currentVoteResults!,
            onDismiss: () => setState(() => _currentVoteResults = null),
          ),
        ));
      }
    }
    return sidebarWidgets;
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
        canPop: _allowPop,

        // didPop: 팝 성공 여부, result: 팝될 때 전달된 결과값(여기선 사용 안 함)
        onPopInvokedWithResult: (bool didPop, dynamic result) async {
          if (didPop) {
            return;
          }

          // [종료 로직 실행]

          // 1. 내가 전송 담당자라면 서버 저장
          if (_isEldestParticipant) {
            await _createSessionAndSaveParticipants();
          }

          // 2. LiveKit 연결 해제
          await widget.room.disconnect();

          // 3. 팝 허용 후 다시 뒤로가기 실행
          if (mounted) {
            setState(() {
              _allowPop = true;
            });

            // 현재 프레임 종료 후 실행
            WidgetsBinding.instance.addPostFrameCallback((_) {
              // result를 그대로 전달하거나 null 전달
              Navigator.of(context).pop(result);
            });
          }
        },
    child:Scaffold(
      body: Stack(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: Column(
                  children: [
                    Expanded(
                      child: participantTracks.isNotEmpty
                          ? Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: GridView.builder(
                                itemCount: participantTracks.length,
                                gridDelegate:
                                    SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: _getCrossAxisCount(),
                                  childAspectRatio: 16 / 9,
                                ),
                                itemBuilder: (BuildContext context, int index) {
                                  return ParticipantWidget.widgetFor(
                                      participantTracks[index]);
                                },
                              ),
                            )
                          : Container(),
                    ),
                    if (widget.room.localParticipant != null)
                      SafeArea(
                        top: false,
                        child: ControlsWidget(
                          widget.room,
                          widget.room.localParticipant!,
                          onToggleSidebar: _toggleSidebar,
                        ),
                      ),
                  ],
                ),
              ),
              if (_isSidebarVisible)
                AiAssistantSidebar(
                  children: _buildSidebarWidgets(),
                ),
            ],
          ),
          // Debugging: Agent Status Indicator
          Positioned(
            bottom: 20,
            right: 20,
            child: Tooltip(
              message: "Agent Status: ${_isAgentPresent ? 'Online' : 'Offline'}",
              child: Container(
                width: 15,
                height: 15,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _isAgentPresent ? Colors.green : Colors.red,
                  boxShadow: const [
                    BoxShadow(blurRadius: 4, color: Colors.black26)
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
     )
    );
  }
  // 1. 내가 방 만든 사람인지 판별하는 로직
  //이때 내가 제일 먼저 나가야한다 그렇지 않으면 중간에 나간 사람도 기록하는 로직 짜야함
  bool get _isEldestParticipant {
    final local = widget.room.localParticipant;
    if (local == null) return false;

    // joinedAt이 null이면 현재 시간으로 대체
    final myJoinTime = local.joinedAt ?? DateTime.now();

    for (final remote in widget.room.remoteParticipants.values) {
      final remoteJoinTime = remote.joinedAt;
      if (remoteJoinTime == null) continue;

      // 나보다 먼저 온 사람이 있으면 나는 담당자가 아님
      if (remoteJoinTime.isBefore(myJoinTime)) {
        return false;
      }

      // (혹시 시간이 같으면 ID로 순서 정하기)
      if (remoteJoinTime.isAtSameMomentAs(myJoinTime) &&
          remote.identity.compareTo(local.identity) < 0) {
        return false;
      }
    }
    // 나보다 먼저 온 사람이 없으므로 내가 최고참
    return true;
  }

  // 2. 세션 생성 및 전송 로직 (RoomPage 클래스 내부로 이동)
  Future<void> _createSessionAndSaveParticipants() async {
    // 실제 서버 주소로 변경하세요 (Android 에뮬레이터라면 10.0.2.2, 실제 기기라면 PC IP)
    const String serverUrl = 'http://localhost:8080/api/sessions';

    try {
      final prefs = await SharedPreferences.getInstance();
      final String? accessToken = prefs.getString('accessToken');

      if (accessToken == null) {
        print('인증 토큰 없음');
        return;
      }

      final List<Participant> allParticipants = [
        if (widget.room.localParticipant != null) widget.room.localParticipant!,
        ...widget.room.remoteParticipants.values
      ];

      final body = {
        'roomName': widget.room.name,
        'createdAt': DateTime.now().toIso8601String(),
        'participants': allParticipants.map((p) => {
          'identity': p.identity,
          'name': p.name,
          'joinedAt': p.joinedAt?.toIso8601String(),
        }).toList(),
      };

      print('⏳ 세션 저장 중...');
      final response = await http.post(
        Uri.parse(serverUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $accessToken',
        },
        body: jsonEncode(body),
      );

      if (response.statusCode >= 200 && response.statusCode < 300) {
        print('세션 저장 성공');
      } else {
        print('저장 실패: ${response.statusCode}');
      }
    } catch (e) {
      print('전송 중 에러: $e');
    }
  }
}
