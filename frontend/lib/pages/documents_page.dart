// 기능: 회의 관련 문서들을 관리하고 표시하는 페이지를 구현함. 문서 검색, 필터링, 최근 문서, 내 문서, 공유 문서 등 다양한 카테고리별 문서 탐색 기능을 제공하며, 개별 문서 항목을 시각적으로 구성함.
// 호출: flutter/material.dart의 다양한 기본 위젯(TextField, ListTile, DropdownButton, Card 등)을 사용하여 UI를 구성함. 다른 커스텀 위젯이나 파일을 직접 호출하지 않음.
// 호출됨: home_page.dart 파일에서 DocumentsPage 위젯 형태로 호출되어 메인 화면의 탭 중 하나로 사용됨.
import 'package:flutter/material.dart';

class DocumentsPage extends StatelessWidget {
  const DocumentsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 250,
          color: Colors.grey[100],
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    '문서',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  IconButton(
                    icon: const Icon(Icons.add_circle_outline),
                    onPressed: () {},
                  ),
                ],
              ),
              const SizedBox(height: 16),
              TextField(
                decoration: InputDecoration(
                  hintText: '검색',
                  prefixIcon: const Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                    borderSide: BorderSide.none,
                  ),
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding: const EdgeInsets.symmetric(vertical: 8.0),
                ),
              ),
              const SizedBox(height: 16),
              ListTile(
                leading: const Icon(Icons.notifications_none),
                title: const Text('알림'),
                trailing: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: Colors.red,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: const Text('3', style: TextStyle(color: Colors.white, fontSize: 12)),
                ),
                onTap: () {},
              ),
              ListTile(
                leading: const Icon(Icons.access_time),
                title: const Text('최근'),
                onTap: () {},
              ),
              ListTile(
                leading: const Icon(Icons.folder_open),
                title: const Text('내 문서'),
                subtitle: const Text('새로운 기능'),
                onTap: () {},
              ),
              ListTile(
                leading: const Icon(Icons.share),
                title: const Text('나에게 공유됨'),
                onTap: () {},
              ),
              ListTile(
                leading: const Icon(Icons.bookmark_border),
                title: const Text('별표 표시됨'),
                onTap: () {},
              ),
              const Spacer(),
              const Divider(),
              const Text(
                '공유 폴더',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                '공유 폴더는 팀의 문서를 원활하게 공유하고 협업할 수 있는 공간입니다.',
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              ),
              const SizedBox(height: 8),
              TextButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.add, size: 18),
                label: const Text('새 공유 폴더 만들기'),
                style: TextButton.styleFrom(
                  padding: EdgeInsets.zero,
                  alignment: Alignment.centerLeft,
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border(bottom: BorderSide(color: Colors.grey.shade200)),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        decoration: InputDecoration(
                          hintText: '회의 이름 또는 ID 검색',
                          prefixIcon: const Icon(Icons.search),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8.0),
                            borderSide: BorderSide.none,
                          ),
                          filled: true,
                          fillColor: Colors.grey[50],
                          contentPadding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    DropdownButton<String>(
                      value: '모든 회의',
                      items: <String>['모든 회의', '내 회의', '공유 회의']
                          .map<DropdownMenuItem<String>>((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                      onChanged: (String? newValue) {},
                    ),
                    const SizedBox(width: 16),
                    DropdownButton<String>(
                      value: '7월 7, 2025 - 8월 6, 2025',
                      items: <String>['7월 7, 2025 - 8월 6, 2025', '이번 달', '지난 달']
                          .map<DropdownMenuItem<String>>((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                      onChanged: (String? newValue) {},
                    ),
                    const SizedBox(width: 16),
                    DropdownButton<String>(
                      value: '참가자',
                      items: <String>['참가자', '나', '다른 사람']
                          .map<DropdownMenuItem<String>>((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                      onChanged: (String? newValue) {},
                    ),
                  ],
                ),
              ),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.all(16.0),
                  children: [
                    _buildDocumentItem(
                      date: '7월 29, 화',
                      title: '철희님의 Zoom 회의',
                      time: '20:23 - 20:42',
                      participants: ['assets/profile_pic1.png', 'assets/profile_pic2.png'],
                      memo: '메모가 있습니다.',
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border(top: BorderSide(color: Colors.grey.shade200)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        IconButton(icon: const Icon(Icons.delete_outline), onPressed: () {}),
                        IconButton(icon: const Icon(Icons.folder_open_outlined), onPressed: () {}),
                      ],
                    ),
                    Row(
                      children: [
                        IconButton(icon: const Icon(Icons.help_outline), onPressed: () {}),
                        IconButton(icon: const Icon(Icons.more_horiz), onPressed: () {}),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDocumentItem({
    required String date,
    required String title,
    required String time,
    required List<String> participants,
    String? memo,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16.0),
      elevation: 0.5,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              date,
              style: const TextStyle(fontSize: 13, color: Colors.grey),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        time,
                        style: const TextStyle(fontSize: 14, color: Colors.grey),
                      ),
                      if (memo != null) ...[
                        const SizedBox(height: 4),
                        Text(
                          memo,
                          style: const TextStyle(fontSize: 14, color: Colors.grey),
                        ),
                      ],
                    ],
                  ),
                ),
                TextButton(
                  onPressed: () {},
                  child: const Text('세부 정보 보기 >', style: TextStyle(color: Colors.blue)),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                ...participants.map((img) => Padding(
                  padding: const EdgeInsets.only(right: 4.0),
                  child: CircleAvatar(
                    radius: 12,
                    backgroundImage: AssetImage(img),
                  ),
                )).toList(),
                const SizedBox(width: 8),
                Text(
                  '호스트: 현진',
                  style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
