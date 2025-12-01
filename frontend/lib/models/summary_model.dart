import 'dart:convert';

class SummaryResponse {
  final Metadata metadata;
  final FinalSummary finalSummary;
  final List<Speaker> speakers;
  final List<Utterance> utterances;

  SummaryResponse({
    required this.metadata,
    required this.finalSummary,
    required this.speakers,
    required this.utterances,
  });

  factory SummaryResponse.fromJson(Map<String, dynamic> json) {
    return SummaryResponse(
      metadata: Metadata.fromJson(json['metadata']),
      finalSummary: FinalSummary.fromJson(json['final_summary']),
      speakers: (json['participants'] as List?)
              ?.map((e) => Speaker.fromJson(e))
              .toList() ??
          [],
      utterances: (json['utterances'] as List?)
              ?.map((e) => Utterance.fromJson(e))
              .toList() ??
          [],
    );
  }
}

class Metadata {
  final String roomname;
  final String date;
  final int participantsNum;

  Metadata({
    required this.roomname,
    required this.date,
    required this.participantsNum,
  });

  factory Metadata.fromJson(Map<String, dynamic> json) {
    return Metadata(
      roomname: json['roomname'] ?? '',
      date: json['date'] ?? '',
      participantsNum: json['participant_num'] ?? 0,
    );
  }
}

class FinalSummary {
  final String mainTopic;
  final String domain;
  final String summary;
  final List<Decision> decisions;
  final List<ActionItem> actionItems;
  final List<Topic> topics;

  FinalSummary({
    required this.mainTopic,
    required this.domain,
    required this.summary,
    required this.decisions,
    required this.actionItems,
    required this.topics,
  });

  factory FinalSummary.fromJson(Map<String, dynamic> json) {
    return FinalSummary(
      mainTopic: json['main_topic'] ?? '',
      domain: json['domain'] ?? '',
      summary: json['summary'] ?? '',
      decisions: (json['decisions'] as List?)
              ?.map((e) => Decision.fromJson(e))
              .toList() ??
          <Decision>[],
      actionItems: (json['action_items'] as List?)
              ?.map((e) => ActionItem.fromString(e.toString()))
              .toList() ??
          <ActionItem>[],
      topics: (json['topics'] as List?)
              ?.map((e) => Topic.fromJson(e))
              .toList() ??
          <Topic>[],
    );
  }
}

class ActionItem {
  final String task;
  final String assignee;
  final String dueDate;
  final String relatedSubTopicId;

  ActionItem({
    required this.task,
    required this.assignee,
    required this.dueDate,
    required this.relatedSubTopicId,
  });

  factory ActionItem.fromString(String raw) {
    String content = raw.trim();
    if (content.startsWith('{')) content = content.substring(1);
    if (content.endsWith('}')) content = content.substring(0, content.length - 1);

    final taskMatch = RegExp(r'task:\s*(.*?),\s*assignee:').firstMatch(content);
    final assigneeMatch = RegExp(r'assignee:\s*(.*?),\s*due_date:').firstMatch(content);
    final dueDateMatch = RegExp(r'due_date:\s*(.*?),\s*related_sub_topic_id:').firstMatch(content);
    final relatedIdMatch = RegExp(r'related_sub_topic_id:\s*(.*)').firstMatch(content);

    return ActionItem(
      task: taskMatch?.group(1)?.trim() ?? content,
      assignee: assigneeMatch?.group(1)?.trim() ?? '',
      dueDate: dueDateMatch?.group(1)?.trim() ?? '',
      relatedSubTopicId: relatedIdMatch?.group(1)?.trim() ?? '',
    );
  }
}

class Decision {
  final String content;
  final String relatedSubTopicId;

  Decision({
    required this.content,
    required this.relatedSubTopicId,
  });

  factory Decision.fromJson(Map<String, dynamic> json) {
    return Decision(
      content: json['content'] ?? '',
      relatedSubTopicId: json['related_sub_topic_id'] ?? '',
    );
  }
}

class Topic {
  final String subTopic;
  final String type;
  final String startId;
  final String endId;
  final String subTopicId;
  final String shortSummary;
  final dynamic details;

  Topic({
    required this.subTopic,
    required this.type,
    required this.startId,
    required this.endId,
    required this.subTopicId,
    required this.shortSummary,
    required this.details,
  });

  factory Topic.fromJson(Map<String, dynamic> json) {
    String type = json['type'] ?? '';
    dynamic detailsJson = json['details'];
    dynamic parsedDetails;

    if (detailsJson != null) {
      switch (type) {
        case 'shared_info':
          parsedDetails = SharedInfoDetails.fromJson(detailsJson);
          break;
        case 'problem_solving':
          parsedDetails = ProblemSolvingDetails.fromJson(detailsJson);
          break;
        case 'team_building':
          parsedDetails = TeamBuildingDetails.fromJson(detailsJson);
          break;
        case 'planning':
          parsedDetails = PlanningDetails.fromJson(detailsJson);
          break;
        case 'retrospective':
          parsedDetails = RetrospectiveDetails.fromJson(detailsJson);
          break;
        case 'operational_review':
          parsedDetails = OperationalReviewDetails.fromJson(detailsJson);
          break;
        case 'decision_making':
          parsedDetails = DecisionMakingDetails.fromJson(detailsJson);
          break;
        case 'brainstorming':
          parsedDetails = BrainstormingDetails.fromJson(detailsJson);
          break;
        default:
          parsedDetails = detailsJson;
      }
    }

    return Topic(
      subTopic: json['sub_topic'] ?? '',
      type: type,
      startId: json['start_id'] ?? '',
      endId: json['end_id'] ?? '',
      subTopicId: json['sub_topic_id'] ?? '',
      shortSummary: json['short_summary'] ?? '',
      details: parsedDetails,
    );
  }
}

// --- Detail Classes ---

class SharedInfoDetails {
  final List<String> presentationSummary;
  final List<String> keyTakeaways;
  final List<String> qaSummary;

  SharedInfoDetails({
    required this.presentationSummary,
    required this.keyTakeaways,
    required this.qaSummary,
  });

  factory SharedInfoDetails.fromJson(Map<String, dynamic> json) {
    return SharedInfoDetails(
      presentationSummary: _toList(json['presentation_summary']),
      keyTakeaways: _toList(json['key_takeaways']),
      qaSummary: _toList(json['qa_summary']),
    );
  }
}

class ProblemSolvingDetails {
  final String problemDefinition;
  final String rootCauseAnalysis;
  final List<String> solutionAlternatives;

  ProblemSolvingDetails({
    required this.problemDefinition,
    required this.rootCauseAnalysis,
    required this.solutionAlternatives,
  });

  factory ProblemSolvingDetails.fromJson(Map<String, dynamic> json) {
    return ProblemSolvingDetails(
      problemDefinition: json['problem_definition'] ?? '',
      rootCauseAnalysis: json['root_cause_analysis'] ?? '',
      solutionAlternatives: _toList(json['solution_alternatives']),
    );
  }
}

class TeamBuildingDetails {
  final String activitySummary;
  final List<String> teamFeedback;

  TeamBuildingDetails({
    required this.activitySummary,
    required this.teamFeedback,
  });

  factory TeamBuildingDetails.fromJson(Map<String, dynamic> json) {
    return TeamBuildingDetails(
      activitySummary: json['activity_summary'] ?? '',
      teamFeedback: _toList(json['team_feedback']),
    );
  }
}

class PlanningDetails {
  final List<String> goalsObjectives;
  final List<Milestone> roadmapMilestones;
  final String resourceAllocation;

  PlanningDetails({
    required this.goalsObjectives,
    required this.roadmapMilestones,
    required this.resourceAllocation,
  });

  factory PlanningDetails.fromJson(Map<String, dynamic> json) {
    return PlanningDetails(
      goalsObjectives: _toList(json['goals_objectives']),
      roadmapMilestones: (json['roadmap_milestones'] as List?)
              ?.map((e) => Milestone.fromJson(e))
              .toList() ??
          [],
      resourceAllocation: json['resource_allocation'] ?? '',
    );
  }
}

class Milestone {
  final String milestone;
  final String dueDate;

  Milestone({required this.milestone, required this.dueDate});

  factory Milestone.fromJson(Map<String, dynamic> json) {
    return Milestone(
      milestone: json['milestone'] ?? '',
      dueDate: json['due_date'] ?? '',
    );
  }
}

class RetrospectiveDetails {
  final List<String> keep;
  final List<String> problem;
  final List<String> tryList;

  RetrospectiveDetails({
    required this.keep,
    required this.problem,
    required this.tryList,
  });

  factory RetrospectiveDetails.fromJson(Map<String, dynamic> json) {
    return RetrospectiveDetails(
      keep: _toList(json['keep']),
      problem: _toList(json['problem']),
      tryList: _toList(json['try']),
    );
  }
}

class OperationalReviewDetails {
  final List<ProgressItem> progressSummary;
  final List<String> blockers;
  final List<String> nextPeriodPlan;

  OperationalReviewDetails({
    required this.progressSummary,
    required this.blockers,
    required this.nextPeriodPlan,
  });

  factory OperationalReviewDetails.fromJson(Map<String, dynamic> json) {
    return OperationalReviewDetails(
      progressSummary: (json['progress_summary'] as List?)
              ?.map((e) => ProgressItem.fromJson(e))
              .toList() ??
          [],
      blockers: _toList(json['blockers']),
      nextPeriodPlan: _toList(json['next_period_plan']),
    );
  }
}

class ProgressItem {
  final String item;
  final String status;
  final String note;

  ProgressItem({
    required this.item,
    required this.status,
    required this.note,
  });

  factory ProgressItem.fromJson(Map<String, dynamic> json) {
    return ProgressItem(
      item: json['item'] ?? '',
      status: json['status'] ?? '',
      note: json['note'] ?? '',
    );
  }
}

class DecisionMakingDetails {
  final String decisionBackground;
  final List<String> discussedAlternatives;
  final List<String> votingResults;

  DecisionMakingDetails({
    required this.decisionBackground,
    required this.discussedAlternatives,
    required this.votingResults,
  });

  factory DecisionMakingDetails.fromJson(Map<String, dynamic> json) {
    return DecisionMakingDetails(
      decisionBackground: json['decision_background'] ?? '',
      discussedAlternatives: _toList(json['discussed_alternatives']),
      votingResults: _toList(json['voting_results']),
    );
  }
}

class BrainstormingDetails {
  final String topic;
  final List<String> ideasGenerated;
  final List<String> keyThemes;
  final List<String> selectedIdeas;

  BrainstormingDetails({
    required this.topic,
    required this.ideasGenerated,
    required this.keyThemes,
    required this.selectedIdeas,
  });

  factory BrainstormingDetails.fromJson(Map<String, dynamic> json) {
    return BrainstormingDetails(
      topic: json['topic'] ?? '',
      ideasGenerated: _toList(json['ideas_generated']),
      keyThemes: _toList(json['key_themes']),
      selectedIdeas: _toList(json['selected_ideas']),
    );
  }
}

List<String> _toList(dynamic json) {
  if (json is List) {
    return json.map((e) => e.toString()).toList();
  }
  return [];
}

class Speaker {
  final String id;
  final String name;
  final String role;

  Speaker({required this.id, required this.name, required this.role});

  factory Speaker.fromJson(Map<String, dynamic> json) {
    return Speaker(
      id: json['USER_ID'] ?? '',
      name: json['name'] ?? '',
      role: json['role'] ?? '',
    );
  }
}

class Utterance {
  final String id;
  final String name;
  final String content;

  Utterance({required this.id, required this.name, required this.content});

  factory Utterance.fromJson(Map<String, dynamic> json) {
    return Utterance(
      id: json['id'].toString(),
      name: json['USER_ID'] ?? '',
      content: json['content'] ?? '',
    );
  }
}
