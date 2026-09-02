import 'dart:async';

import 'package:flutter/services.dart';
import 'package:moodiary/components/dashboard/dashboard_logic.dart';
import 'package:moodiary/pages/home/diary/diary_logic.dart';
import 'package:moodiary/pages/home/home_logic.dart';
import 'package:moodiary/presentation/pref.dart';
import 'package:moodiary/presentation/secure_storage.dart';
import 'package:moodiary/router/app_routes.dart';
import 'package:moodiary/utils/file_util.dart';
import 'package:moodiary/utils/notice_util.dart';
import 'package:refreshed/refreshed.dart';

import 'setting_state.dart';

class SettingLogic extends GetxController {
  final SettingState state = SettingState();
  late final homeLogic = Bind.find<HomeLogic>();

  @override
  void onInit() {
    super.onInit();
  }

  @override
  void onReady() {
    unawaited(getDataUsage());
    unawaited(checkHasUserKey());
    super.onReady();
  }

  Future<void> checkHasUserKey() async {
    state.hasUserKey.value =
        (await SecureStorageUtil.getValue('userKey')) != null;
  }

  //获取当前占用储存空间
  Future<void> getDataUsage() async {
    final sizeMap = await FileUtil.countSize();
    state.dataUsage = '${sizeMap['size']} ${sizeMap['unit']}';
    update(['DataUsage']);
    if (sizeMap['bytes'] > (1024 * 1024 * 100)) {
      await FileUtil.clearCache();
      await getDataUsage();
      NoticeUtil.showToast('缓存已自动清理');
    }
  }

  Future<void> deleteCache() async {
    await FileUtil.clearCache();
    await getDataUsage();
    NoticeUtil.showToast('清理成功');
  }

  //本地化
  Future<void> local(bool value) async {
    await PrefUtil.setValue<bool>('local', value);
    state.local = value;
    update(['Local']);
  }

  //立即锁定
  Future<void> lockNow(bool value) async {
    await PrefUtil.setValue<bool>('lockNow', value);
    state.lockNow = value;
    update(['Lock']);
  }

  void toAnalysePage() {
    HapticFeedback.selectionClick();
    Get.toNamed(AppRoutes.analysePage);
  }

  Future<void> toMap() async {
    // 地图已换 OSM 瓦片，免 key
    HapticFeedback.selectionClick();
    Get.toNamed(AppRoutes.mapPage);
  }

  Future<void> toAi() async {
    // GLM 密钥已本地化（glm_secret.dart），无需运行时检查
    HapticFeedback.selectionClick();
    Get.toNamed(AppRoutes.assistantPage);
  }

  Future<void> toCategoryManager() async {
    HapticFeedback.selectionClick();
    await Get.toNamed(AppRoutes.categoryManagerPage);
    Bind.find<DashboardLogic>().getCategoryCount();
  }

  Future<void> changeBackendPrivacy(bool value) async {
    await PrefUtil.setValue<bool>('backendPrivacy', value);
    state.backendPrivacy.value = value;
  }

  //进入回收站
  void toRecyclePage() {
    Get.toNamed(AppRoutes.recyclePage);
  }

  //进入字体大小设置页
  void toFontSizePage() {
    Get.toNamed(AppRoutes.fontPage);
  }

  void toLaboratoryPage() {
    Get.toNamed(AppRoutes.laboratoryPage);
  }

  void toAboutPage() {
    Get.toNamed(AppRoutes.aboutPage);
  }

  void toDiarySettingPage() {
    Get.toNamed(AppRoutes.diarySettingPage);
  }

  void toBackupAndSyncPage() {
    Get.toNamed(AppRoutes.backupSyncPage);
  }

  Future<void> setCustomTitle({required String title}) async {
    state.customTitle = title.trim();
    update(['CustomTitle']);
    await PrefUtil.setValue<String>('customTitleName', state.customTitle);
    Bind.find<DiaryLogic>().updateTitle();
  }

  Future<void> setUserKey({required String key}) async {
    if (key.isBlank) {
      NoticeUtil.showToast('密钥不能为空');
      return;
    }
    await SecureStorageUtil.setValue('userKey', key);
    state.hasUserKey.value = true;
  }

  Future<void> removeUserKey() async {
    await SecureStorageUtil.remove('userKey');
    state.hasUserKey.value = false;
  }
}
