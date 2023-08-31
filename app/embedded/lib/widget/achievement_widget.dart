import 'package:flutter/material.dart';

class CircleGrid extends StatelessWidget {
  final List<bool> unlockStatus;
  final bool isHighLevel;

  CircleGrid({ required this.unlockStatus, required this.isHighLevel});

  @override
  Widget build(BuildContext context) {

    final List<String> titles = [
      '이제부터 1일',
      '첫 하트',
      '첫 좋아요',
      '수동 물주기',
      '멀리서도 괜찮아',
      '일주일간 함께',
      '레벨 초기화',
      '최고 레벨 달성',
      '한달동안 꾸준히',
      '하트 1000',
      '좋아요 1000',
      '모든 업적 달성'
    ];

    return Column(
      children: [
        GridView.builder(
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
          ),
          itemCount: 6,
          itemBuilder: (context, index) {
            return CircleItem(
              text: titles[index + (isHighLevel ? 6 : 0)],
              lockedImagePath: 'assets/achievement/${index + 1 + (isHighLevel ? 6 : 0)}.png',
              unlockedImagePath: 'assets/not_achievement/lock.png',
              isUnlocked: unlockStatus[index + (isHighLevel ? 6 : 0)],
            );
          },
        ),
      ],
    );
  }
}

class CircleItem extends StatelessWidget {
  final String text;
  final String lockedImagePath;
  final String unlockedImagePath;
  final bool isUnlocked;

  CircleItem({
    required this.text,
    required this.lockedImagePath,
    required this.unlockedImagePath,
    required this.isUnlocked,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white,
          ),
          child: Padding(
            padding: const EdgeInsets.all(10.0),
            child: Image.asset(isUnlocked ? lockedImagePath : unlockedImagePath),
          )
        ),
        SizedBox(height: 10),
        Text(text, style: TextStyle(color: Colors.white)),
      ],
    );
  }
}