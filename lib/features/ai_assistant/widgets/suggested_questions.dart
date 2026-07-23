import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../services/chat_service.dart';

class SuggestedQuestions extends StatelessWidget {
  final ChatService chatService;
  final Function(String) onQuestionSelected;

  const SuggestedQuestions({
    super.key,
    required this.chatService,
    required this.onQuestionSelected,
  });

  @override
  Widget build(BuildContext context) {
    final questions = chatService.getSuggestedQuestions();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0x0DFFFFFF),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0x1AFFFFFF)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.lightbulb,
                color: Colors.yellow[400],
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'Suggested Questions',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: questions.map((question) {
              return _buildQuestionChip(context, question);
            }).toList(),
          ),
        ],
      ),
    ).animate(target: 1, duration: const Duration(milliseconds: 500));
  }

  Widget _buildQuestionChip(BuildContext context, String question) {
    return ActionChip(
      label: Text(
        question,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
          color: Colors.white,
        ),
      ),
      onPressed: () => onQuestionSelected(question),
      backgroundColor: Colors.blue[600],
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      labelStyle: Theme.of(context).textTheme.bodySmall?.copyWith(
        color: Colors.white,
        fontWeight: FontWeight.w500,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      elevation: 2,
      shadowColor: Colors.blue[400],
    );
  }
}