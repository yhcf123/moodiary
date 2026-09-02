import 'package:moodiary/common/models/hunyuan.dart';
import 'package:moodiary/common/values/keyboard_state.dart';
import 'package:refreshed/refreshed.dart';

class AssistantState {
  //对话上下文
  late Map<DateTime, Message> messages;

  //模型版本
  late RxInt modelVersion;

  late KeyboardState keyboardState;

  late int totalToken;

  /// 正在流式输出中（此时用纯文本渲染，避免半截Markdown崩组件）
  bool isStreaming = false;

  AssistantState() {
    messages = {};

    modelVersion = 0.obs;
    keyboardState = KeyboardState.closed;

    ///Initialize variables
  }
}
