import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/chat_service.dart';
import '../../../core/services/gemini_service.dart';

// Chat Service Provider
final chatServiceProvider = Provider<ChatService>((ref) {
  return ChatService(ref.read(geminiServiceProvider), ref);
});

// Chat state class
class ChatState {
  final List<ChatMessage> messages;
  final bool typing;
  final bool initialized;

  ChatState({this.messages = const [], this.typing = false, this.initialized = false});

  ChatState copyWith({List<ChatMessage>? messages, bool? typing, bool? initialized}) {
    return ChatState(
      messages: messages ?? this.messages,
      typing: typing ?? this.typing,
      initialized: initialized ?? this.initialized,
    );
  }
}

// Chat Controller
class ChatController extends Notifier<ChatState> {
  late ChatService _chatService;

  @override
  ChatState build() {
    _chatService = ref.read(chatServiceProvider);
    _initialize();
    return ChatState();
  }

  void _initialize() {
    _chatService.initialize();
    _chatService.messagesStream.listen((messages) {
      state = state.copyWith(messages: messages);
    });
    _chatService.typingStream.listen((typing) {
      state = state.copyWith(typing: typing);
    });
    state = state.copyWith(initialized: true);
  }

  void sendMessage(String message) {
    _chatService.sendMessage(message);
  }

  void clearChat() {
    _chatService.clearChat();
  }

  List<String> getSuggestedQuestions() {
    return _chatService.getSuggestedQuestions();
  }

  String exportChatHistory() {
    return _chatService.exportChatHistory();
  }
}

// Chat Controller Provider
final chatControllerProvider = NotifierProvider<ChatController, ChatState>(() {
  return ChatController();
});

// Selected chat message provider
final selectedChatMessageProvider = Provider<ChatMessage?>((ref) => null);

// Chat history provider
final chatHistoryProvider = Provider<List<ChatMessage>>((ref) {
  final chatState = ref.watch(chatControllerProvider);
  return chatState.messages;
});

// Chat typing state provider
final chatTypingProvider = Provider<bool>((ref) {
  final chatState = ref.watch(chatControllerProvider);
  return chatState.typing;
});