// 기능: 회의 관련 문서들을 관리하고 표시하는 페이지를 구현함. 문서 검색, 필터링, 최근 문서, 내 문서, 공유 문서 등 다양한 카테고리별 문서 탐색 기능을 제공하며, 개별 문서 항목을 시각적으로 구성함.
// 호출: flutter/material.dart의 다양한 기본 위젯(TextField, ListTile, DropdownButton, Card 등)을 사용하여 UI를 구성함. 다른 커스텀 위젯이나 파일을 직접 호출하지 않음.
// 호출됨: home_page.dart 파일에서 DocumentsPage 위젯 형태로 호출되어 메인 화면의 탭 중 하나로 사용됨.
import 'package:flutter/material.dart';

class DocumentsPage extends StatelessWidget {
  const DocumentsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('파일 업로드 기능은 준비 중입니다.')),
          );
        },
        backgroundColor: Colors.blue,
        child: const Icon(Icons.upload_file, color: Colors.white),
      ),
      body: Column(
        children: [
          _buildHeader(context),
          _buildFilterChips(),
          Expanded(
            child: _buildDocumentList(),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '문서',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            decoration: InputDecoration(
              hintText: '문서 검색',
              prefixIcon: const Icon(Icons.search, color: Colors.grey),
              filled: true,
              fillColor: Colors.grey[100],
              contentPadding: const EdgeInsets.symmetric(vertical: 10),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChips() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Row(
        children: [
          _buildChip('전체', true),
          const SizedBox(width: 8),
          _buildChip('최근', false),
          const SizedBox(width: 8),
          _buildChip('공유됨', false),
          const SizedBox(width: 8),
          _buildChip('즐겨찾기', false),
        ],
      ),
    );
  }

  Widget _buildChip(String label, bool isSelected) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: isSelected ? Colors.blue[50] : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isSelected ? Colors.blue : Colors.grey[300]!,
        ),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: isSelected ? Colors.blue[700] : Colors.grey[700],
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
      ),
    );
  }

  Widget _buildDocumentList() {
    final List<Map<String, dynamic>> documents = [
      {
        'title': '2025 캡스톤 프로젝트 기획안.pdf',
        'date': '2025-11-28',
        'size': '2.4 MB',
        'icon': Icons.picture_as_pdf,
        'color': Colors.red,
      },
      {
        'title': 'UI/UX 디자인 가이드.pptx',
        'date': '2025-11-25',
        'size': '15.8 MB',
        'icon': Icons.slideshow,
        'color': Colors.orange,
      },
      {
        'title': '회의록_20251120.docx',
        'date': '2025-11-20',
        'size': '45 KB',
        'icon': Icons.description,
        'color': Colors.blue,
      },
      {
        'title': 'backend_api_specs.json',
        'date': '2025-11-15',
        'size': '12 KB',
        'icon': Icons.code,
        'color': Colors.green,
      },
      {
        'title': '팀 예산안.xlsx',
        'date': '2025-11-10',
        'size': '1.2 MB',
        'icon': Icons.table_chart,
        'color': Colors.green[700],
      },
    ];

    return ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      itemCount: documents.length,
      separatorBuilder: (context, index) => const Divider(height: 1),
      itemBuilder: (context, index) {
        final doc = documents[index];
        return ListTile(
          contentPadding: const EdgeInsets.symmetric(vertical: 8),
          leading: Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: (doc['color'] as Color).withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(doc['icon'], color: doc['color'], size: 28),
          ),
          title: Text(
            doc['title'],
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 16,
            ),
          ),
          subtitle: Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(
              '${doc['date']} • ${doc['size']}',
              style: TextStyle(color: Colors.grey[500], fontSize: 13),
            ),
          ),
          trailing: IconButton(
            icon: const Icon(Icons.more_vert, color: Colors.grey),
            onPressed: () {},
          ),
          onTap: () {},
        );
      },
    );
  }
}
