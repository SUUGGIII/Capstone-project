// 기능: "Zoom Scheduler" 기능의 주요 장점을 사용자에게 홍보하고, 14일 무료 체험, 구매, 자세히 알아보기 등의 액션을 유도하는 마케팅 페이지를 구현함.
// 호출: flutter/material.dart의 다양한 기본 위젯(ElevatedButton, TextButton 등)을 사용하여 UI를 구성함. 현재는 다른 커스텀 위젯이나 파일을 직접 호출하지 않음.
// 호출됨: home_page.dart 파일에서 SchedulerPage 위젯 형태로 호출되어 메인 화면의 탭 중 하나로 사용되거나, meeting_page.dart에서 "예약" 버튼 클릭 시 NavigationProvider를 통해 전환될 것으로 추정됨.
import 'package:flutter/material.dart';

class SchedulerPage extends StatelessWidget {
  const SchedulerPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(32.0),
      alignment: Alignment.topLeft,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Zoom Scheduler로 예약 과정을 간소화할 준비가 되셨나요?',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 24),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildFeatureItem('가용성을 단일 링크로 간단히 공유'),
                    _buildFeatureItem('개인, 그룹, 예약 사람을 위한 회의 예약 설정'),
                    _buildFeatureItem('자동화되고 사용자 지정이 가능한 확인 및 미리 알림 생성'),
                    const SizedBox(height: 32),
                    Row(
                      children: [
                        ElevatedButton(
                          onPressed: () {},
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue[600],
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                          ),
                          child: const Text(
                            '14일 무료 체험',
                            style: TextStyle(color: Colors.white, fontSize: 16),
                          ),
                        ),
                        const SizedBox(width: 16),
                        TextButton(
                          onPressed: () {},
                          child: Text(
                            '지금 구매',
                            style: TextStyle(color: Colors.blue[600], fontSize: 16),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    TextButton(
                      onPressed: () {},
                      child: Text(
                        '자세히 알아보기',
                        style: TextStyle(color: Colors.blue[600], fontSize: 14),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 48),
              Container(
                width: 400,
                height: 250,
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(16),
                  image: const DecorationImage(
                    image: AssetImage('assets/scheduler_preview.png'),
                    fit: BoxFit.cover,
                  ),
                ),
                child: const Center(
                  child: Icon(
                    Icons.play_circle_fill,
                    size: 80,
                    color: Colors.white70,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureItem(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.check_circle, color: Colors.green[400], size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(fontSize: 16, color: Colors.black87),
            ),
          ),
        ],
      ),
    );
  }
}
