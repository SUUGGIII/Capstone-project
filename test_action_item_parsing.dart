import 'dart:convert';

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
  
  @override
  String toString() {
    return 'ActionItem(task: $task, assignee: $assignee, dueDate: $dueDate, relatedSubTopicId: $relatedSubTopicId)';
  }
}

void main() {
  final jsonList = [
      {
        "task": "3.2장 관련 내용 다음 페이지로 이동 및 전체 문서 구조 정리",
        "assignee": "정일준",
        "due_date": "미정",
        "related_sub_topic_id": "3"
      },
      {
        "task": "노션에 '용어 정리' 페이지를 생성하고 통일된 기술 용어 목록을 작성",
        "assignee": "도건호",
        "due_date": "미정",
        "related_sub_topic_id": "4"
      }
  ];

  print("Testing parsing...");
  try {
    final actionItems = jsonList.map((e) {
      print("Raw string: ${e.toString()}");
      return ActionItem.fromString(e.toString());
    }).toList();
    
    actionItems.forEach((item) => print(item));
  } catch (e) {
    print("Error: $e");
  }
}
