import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:moodiary/common/models/hunyuan.dart';
import 'package:moodiary/common/values/glm_secret.dart';

/// GLM 对话接口（OpenAI 兼容协议，SSE 流式）
/// 替代原腾讯混元通道：密钥本地化，响应字段为小写驼峰，需单独适配
class GlmApi {
  static const _url = 'https://open.bigmodel.cn/api/paas/v4/chat/completions';

  /// 返回流：每段是模型吐出的一段正文文字
  static Future<Stream<String>?> chat(
      List<Message> messages, int model) async {
    const key = GlmSecret.apiKey;
    if (key.isEmpty || key.startsWith('在此')) {
      return null;
    }
    // 模型分档：0 免费档，1 轻量，2 旗舰
    final modelName = switch (model) {
      1 => 'glm-4-air',
      2 => 'glm-4-plus',
      _ => 'glm-4-flash',
    };
    final dio = Dio();
    final resp = await dio.post<ResponseBody>(
      _url,
      options: Options(
        responseType: ResponseType.stream,
        headers: {'Authorization': 'Bearer $key'},
      ),
      data: {
        'model': modelName,
        'messages': messages
            .map((m) => {'role': m.role, 'content': m.content})
            .toList(),
        'stream': true,
      },
    );
    // SSE 逐行解析：data: {"choices":[{"delta":{"content":"..."}}]}
    return resp.data!.stream
        .cast<List<int>>()
        .transform(utf8.decoder)
        .transform(const LineSplitter())
        .where((line) => line.startsWith('data:'))
        .map((line) {
      final payload = line.substring(5).trim();
      if (payload == '[DONE]') return '';
      try {
        final j = jsonDecode(payload);
        return j['choices'][0]['delta']['content'] as String? ?? '';
      } catch (_) {
        return '';
      }
    }).where((s) => s.isNotEmpty);
  }
}
