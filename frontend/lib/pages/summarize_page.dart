import 'dart:convert';
import 'package:flutter/material.dart';
import '../models/summary_model.dart';

class SummarizePage extends StatefulWidget {
  final String sessionName;
  final String content;

  const SummarizePage({
    super.key,
    required this.sessionName,
    required this.content,
  });

  @override
  State<SummarizePage> createState() => _SummarizePageState();
}

class _SummarizePageState extends State<SummarizePage> {
  SummaryResponse? _summary;
  String? _errorMessage;
  bool _showParticipants = false;
  bool _showDecisions = true;
  bool _showActionItems = true;

  @override
  void initState() {
    super.initState();
    _parseContent();
  }

  void _parseContent() {
    try {
      final jsonMap = jsonDecode(widget.content);
      setState(() {
        _summary = SummaryResponse.fromJson(jsonMap);
      });
    } catch (e) {
      setState(() {
        _errorMessage = "Failed to parse summary: $e";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("${widget.sessionName} 회의록"),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0.5,
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_errorMessage != null) {
      return Center(child: Text(_errorMessage!));
    }
    if (_summary == null) {
      return const Center(child: CircularProgressIndicator());
    }

    final summary = _summary!;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildBasicInfoCard(summary),
          const SizedBox(height: 24),
          _buildTopicsList(summary.finalSummary.topics),
        ],
      ),
    );
  }

  Widget _buildBasicInfoCard(SummaryResponse summary) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(summary),
            const Divider(height: 32),
            _buildOverallSummary(summary.finalSummary),
            if (summary.finalSummary.decisions.isNotEmpty) ...[
              const Divider(height: 32),
              _buildGlobalDecisions(summary.finalSummary.decisions),
            ],
            if (summary.finalSummary.actionItems.isNotEmpty) ...[
              const Divider(height: 32),
              _buildGlobalActionItems(summary.finalSummary.actionItems),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(SummaryResponse summary) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          summary.finalSummary.mainTopic,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.blueAccent,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.blue.shade50,
            borderRadius: BorderRadius.circular(4),
            border: Border.all(color: Colors.blue.shade100),
          ),
          child: Text(
            summary.finalSummary.domain,
            style: TextStyle(
              fontSize: 12,
              color: Colors.blue.shade700,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Icon(Icons.calendar_today, size: 14, color: Colors.grey[600]),
            const SizedBox(width: 4),
            Text(
              summary.metadata.date,
              style: TextStyle(fontSize: 13, color: Colors.grey[700]),
            ),
            const SizedBox(width: 16),
            Icon(Icons.people, size: 14, color: Colors.grey[600]),
            const SizedBox(width: 4),
            Text(
              "${summary.metadata.participantsNum}명",
              style: TextStyle(fontSize: 13, color: Colors.grey[700]),
            ),
            const SizedBox(width: 4),
            InkWell(
              onTap: () {
                setState(() {
                  _showParticipants = !_showParticipants;
                });
              },
              child: Padding(
                padding: const EdgeInsets.all(4.0),
                child: Icon(
                  _showParticipants ? Icons.expand_less : Icons.expand_more,
                  size: 20,
                  color: Colors.grey[600],
                ),
              ),
            ),
          ],
        ),
        if (_showParticipants)
          Padding(
            padding: const EdgeInsets.only(top: 12.0),
            child: Wrap(
              spacing: 8.0,
              runSpacing: 8.0,
              children: summary.speakers
                  .map((s) => Chip(
                        label: Text(s.name,
                            style: const TextStyle(fontSize: 12)),
                        visualDensity: VisualDensity.compact,
                        backgroundColor: Colors.white,
                        side: BorderSide(color: Colors.grey.shade300),
                        padding: EdgeInsets.zero,
                        labelPadding:
                            const EdgeInsets.symmetric(horizontal: 8),
                      ))
                  .toList(),
            ),
          ),
      ],
    );
  }

  Widget _buildOverallSummary(FinalSummary summary) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "전체 요약",
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Text(
          summary.summary,
          style: const TextStyle(fontSize: 15, height: 1.5),
        ),
      ],
    );
  }

  Widget _buildGlobalDecisions(List<Decision> decisions) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "결정 사항 (${decisions.length})",
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            IconButton(
              icon: Icon(
                  _showDecisions ? Icons.expand_less : Icons.expand_more),
              onPressed: () {
                setState(() {
                  _showDecisions = !_showDecisions;
                });
              },
            ),
          ],
        ),
        if (_showDecisions) ...[
          const SizedBox(height: 8),
          ...decisions.map((d) => Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.check_circle_outline,
                        color: Colors.green, size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        d.content,
                        style: const TextStyle(fontSize: 15),
                      ),
                    ),
                  ],
                ),
              )),
        ],
      ],
    );
  }

  Widget _buildGlobalActionItems(List<ActionItem> actionItems) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "Action Items (${actionItems.length})",
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            IconButton(
              icon: Icon(
                  _showActionItems ? Icons.expand_less : Icons.expand_more),
              onPressed: () {
                setState(() {
                  _showActionItems = !_showActionItems;
                });
              },
            ),
          ],
        ),
        if (_showActionItems) ...[
          const SizedBox(height: 8),
          ...actionItems.map((item) => Padding(
                padding: const EdgeInsets.only(bottom: 12.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.task_alt, color: Colors.orange, size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.task,
                            style: const TextStyle(
                                fontSize: 15, fontWeight: FontWeight.w500),
                          ),
                          const SizedBox(height: 4),
                          Wrap(
                            spacing: 8,
                            children: [
                              _buildTag("담당자: ${item.assignee}", Colors.grey),
                              _buildTag("기한: ${item.dueDate}", Colors.redAccent),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              )),
        ],
      ],
    );
  }

  Widget _buildTag(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(
        text,
        style: TextStyle(fontSize: 11, color: color),
      ),
    );
  }

  Widget _buildTopicsList(List<Topic> topics) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "상세 토픽 (${topics.length})",
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        ...topics.map((topic) => _TopicCard(topic: topic)),
      ],
    );
  }
}

class _TopicCard extends StatefulWidget {
  final Topic topic;

  const _TopicCard({required this.topic});

  @override
  State<_TopicCard> createState() => _TopicCardState();
}

class _TopicCardState extends State<_TopicCard> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    widget.topic.subTopic,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                _buildTypeBadge(widget.topic.type),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              widget.topic.shortSummary,
              style: TextStyle(fontSize: 14, color: Colors.grey[700]),
            ),
            const SizedBox(height: 12),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton.icon(
                onPressed: () {
                  setState(() {
                    _isExpanded = !_isExpanded;
                  });
                },
                icon: Icon(_isExpanded ? Icons.expand_less : Icons.expand_more),
                label: Text(_isExpanded ? "접기" : "상세 보기"),
                style: TextButton.styleFrom(
                  foregroundColor: Colors.blue,
                  padding: EdgeInsets.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
              ),
            ),
            if (_isExpanded) ...[
              const Divider(height: 24),
              _buildTopicDetails(widget.topic),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildTypeBadge(String type) {
    Color color;
    String label;

    switch (type) {
      case 'shared_info':
        color = Colors.blue;
        label = "정보 공유";
        break;
      case 'problem_solving':
        color = Colors.red;
        label = "문제 해결";
        break;
      case 'decision_making':
        color = Colors.green;
        label = "의사 결정";
        break;
      case 'brainstorming':
        color = Colors.purple;
        label = "브레인스토밍";
        break;
      case 'team_building':
        color = Colors.orange;
        label = "팀 빌딩";
        break;
      case 'planning':
        color = Colors.teal;
        label = "계획 수립";
        break;
      case 'retrospective':
        color = Colors.amber;
        label = "회고";
        break;
      case 'operational_review':
        color = Colors.indigo;
        label = "운영 리뷰";
        break;
      default:
        color = Colors.grey;
        label = type;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.5)),
      ),
      child: Text(
        label,
        style: TextStyle(fontSize: 11, color: color, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildTopicDetails(Topic topic) {
    final details = topic.details;
    if (details == null) return const SizedBox.shrink();

    if (details is SharedInfoDetails) {
      return _buildSharedInfo(details);
    } else if (details is ProblemSolvingDetails) {
      return _buildProblemSolving(details);
    } else if (details is TeamBuildingDetails) {
      return _buildTeamBuilding(details);
    } else if (details is PlanningDetails) {
      return _buildPlanning(details);
    } else if (details is RetrospectiveDetails) {
      return _buildRetrospective(details);
    } else if (details is OperationalReviewDetails) {
      return _buildOperationalReview(details);
    } else if (details is DecisionMakingDetails) {
      return _buildDecisionMaking(details);
    } else if (details is BrainstormingDetails) {
      return _buildBrainstorming(details);
    }

    return const Text("상세 내용을 표시할 수 없습니다.");
  }

  // --- Detail Builders ---

  Widget _buildSharedInfo(SharedInfoDetails details) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (details.presentationSummary.isNotEmpty)
          _buildSectionList("발표 내용", details.presentationSummary),
        if (details.keyTakeaways.isNotEmpty)
          _buildSectionList("핵심 요약", details.keyTakeaways),
        if (details.qaSummary.isNotEmpty)
          _buildSectionList("Q&A", details.qaSummary),
      ],
    );
  }

  Widget _buildProblemSolving(ProblemSolvingDetails details) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionText("문제 정의", details.problemDefinition),
        _buildSectionText("원인 분석", details.rootCauseAnalysis),
        _buildSectionList("해결 방안", details.solutionAlternatives),
      ],
    );
  }

  Widget _buildTeamBuilding(TeamBuildingDetails details) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionText("활동 요약", details.activitySummary),
        _buildSectionList("팀 피드백", details.teamFeedback),
      ],
    );
  }

  Widget _buildPlanning(PlanningDetails details) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionList("목표", details.goalsObjectives),
        if (details.roadmapMilestones.isNotEmpty) ...[
          const SizedBox(height: 8),
          const Text("로드맵",
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          ...details.roadmapMilestones.map((m) => Padding(
                padding: const EdgeInsets.only(left: 8, bottom: 4),
                child: Row(
                  children: [
                    const Icon(Icons.flag, size: 16, color: Colors.teal),
                    const SizedBox(width: 8),
                    Text("${m.milestone} (~${m.dueDate})",
                        style: const TextStyle(fontSize: 14)),
                  ],
                ),
              )),
        ],
        _buildSectionText("리소스 할당", details.resourceAllocation),
      ],
    );
  }

  Widget _buildRetrospective(RetrospectiveDetails details) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionList("Keep (잘한 점)", details.keep),
        _buildSectionList("Problem (아쉬운 점)", details.problem),
        _buildSectionList("Try (시도할 점)", details.tryList),
      ],
    );
  }

  Widget _buildOperationalReview(OperationalReviewDetails details) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (details.progressSummary.isNotEmpty) ...[
          const Text("진행 상황",
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          ...details.progressSummary.map((item) => Padding(
                padding: const EdgeInsets.only(left: 8, bottom: 8),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildStatusBadge(item.status),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(item.item,
                              style:
                                  const TextStyle(fontWeight: FontWeight.w600)),
                          Text(item.note,
                              style: const TextStyle(
                                  fontSize: 13, color: Colors.grey)),
                        ],
                      ),
                    ),
                  ],
                ),
              )),
        ],
        _buildSectionList("블로커", details.blockers),
        _buildSectionList("다음 계획", details.nextPeriodPlan),
      ],
    );
  }

  Widget _buildDecisionMaking(DecisionMakingDetails details) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionText("결정 주제", details.decisionTopic),
        _buildSectionList("고려된 옵션", details.optionsConsidered),
        _buildSectionText("최종 결정", details.finalDecision),
        _buildSectionText("결정 근거", details.rationale),
      ],
    );
  }

  Widget _buildBrainstorming(BrainstormingDetails details) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionText("주제", details.topic),
        _buildSectionList("생성된 아이디어", details.ideasGenerated),
        _buildSectionList("주요 테마", details.keyThemes),
        _buildSectionList("선정된 아이디어", details.selectedIdeas),
      ],
    );
  }

  // --- Common Helpers ---

  Widget _buildSectionText(String title, String content) {
    if (content.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style:
                  const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text(content, style: const TextStyle(fontSize: 14, height: 1.4)),
        ],
      ),
    );
  }

  Widget _buildSectionList(String title, List<String> items) {
    if (items.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style:
                  const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          ...items.map((item) => Padding(
                padding: const EdgeInsets.only(left: 8, bottom: 4),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("• ", style: TextStyle(fontSize: 14)),
                    Expanded(
                        child: Text(item,
                            style: const TextStyle(fontSize: 14, height: 1.4))),
                  ],
                ),
              )),
        ],
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    Color color;
    switch (status.toLowerCase()) {
      case 'on track':
        color = Colors.green;
        break;
      case 'at risk':
        color = Colors.orange;
        break;
      case 'blocked':
        color = Colors.red;
        break;
      default:
        color = Colors.grey;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        status,
        style: TextStyle(fontSize: 10, color: color, fontWeight: FontWeight.bold),
      ),
    );
  }
}
