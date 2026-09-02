import 'dart:io';

import 'package:dio_cache_interceptor_hive_store/dio_cache_interceptor_hive_store.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_cache/flutter_map_cache.dart';
import 'package:flutter_map_marker_cluster/flutter_map_marker_cluster.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:moodiary/components/base/button.dart';
import 'package:moodiary/components/bubble/bubble_view.dart';
import 'package:moodiary/main.dart';
import 'package:moodiary/utils/file_util.dart';
import 'package:moodiary/utils/http_util.dart';
import 'package:refreshed/refreshed.dart';

import 'map_logic.dart';

class MapPage extends StatelessWidget {
  const MapPage({super.key});

  @override
  Widget build(BuildContext context) {
    final logic = Bind.find<MapLogic>();
    final state = Bind.find<MapLogic>().state;
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.settingFunctionTrailMap),
        leading: const PageBackButton(),
      ),
      body: GetBuilder<MapLogic>(
        builder: (_) {
          return state.currentLatLng != null
              ? FlutterMap(
                mapController: logic.mapController,
                options: MapOptions(
                  initialCenter: state.currentLatLng!,
                  minZoom: 4.0,
                  initialZoom: 4.5,
                  maxZoom: 18.0,
                ),
                children: [
                  TileLayer(
                    urlTemplate: 'https://webrd01.is.autonavi.com/appmaptile?lang=zh_cn&size=1&scale=1&style=8&x={x}&y={y}&z={z}',
                    tileProvider: CachedTileProvider(
                      store: HiveCacheStore(
                        FileUtil.getRealPath('hive_cache', ''),
                        hiveBoxName: 'HiveCache',
                      ),
                      dio: HttpUtil().dio,
                    ),
                    tileSize: 256,
                    userAgentPackageName: 'com.yhcf123.lakeisle',
                  ),
                  MarkerClusterLayerWidget(
                    options: MarkerClusterLayerOptions(
                      markers: List.generate(state.diaryMapItemList.length, (
                        index,
                      ) {
                        return Marker(
                          point: state.diaryMapItemList[index].latLng,
                          child: GestureDetector(
                            onTap: () async {
                              await logic.toDiaryPage(
                                isarId: state.diaryMapItemList[index].id,
                              );
                            },
                            child:
                                state
                                        .diaryMapItemList[index]
                                        .coverImageName
                                        .isNotEmpty
                                    ? Bubble(
                                      backgroundColor: colorScheme.tertiary,
                                      borderRadius: 8,
                                      child: Container(
                                        width: 48,
                                        height: 48,
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(
                                            4,
                                          ),
                                          image: DecorationImage(
                                            image: FileImage(
                                              File(
                                                FileUtil.getRealPath(
                                                  'image',
                                                  state
                                                      .diaryMapItemList[index]
                                                      .coverImageName,
                                                ),
                                              ),
                                            ),
                                            fit: BoxFit.cover,
                                          ),
                                        ),
                                      ),
                                    )
                                    : FaIcon(
                                      FontAwesomeIcons.locationDot,
                                      color: colorScheme.tertiary,
                                    ),
                          ),
                          width:
                              state
                                      .diaryMapItemList[index]
                                      .coverImageName
                                      .isNotEmpty
                                  ? 56
                                  : 30,
                          height:
                              state
                                      .diaryMapItemList[index]
                                      .coverImageName
                                      .isNotEmpty
                                  ? 64
                                  : 30,
                        );
                      }),
                      rotate: true,
                      maxZoom: 18.0,
                      forceIntegerZoomLevel: true,
                      showPolygon: false,
                      builder: (context, markers) {
                        return Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            color: colorScheme.tertiaryContainer,
                            border: Border.all(
                              color: colorScheme.tertiary,
                              width: 2,
                            ),
                          ),
                          child: Center(
                            child: Text(
                              markers.length.toString(),
                              style: TextStyle(
                                color: colorScheme.onTertiaryContainer,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              )
              : const Center(child: CircularProgressIndicator());
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          logic.toCurrentPosition();
        },
        child: const FaIcon(FontAwesomeIcons.locationCrosshairs),
      ),
    );
  }
}
