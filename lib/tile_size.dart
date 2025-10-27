import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TileSizeController {
  TileSizeController._();
  
  static final TileSizeController instance = TileSizeController._();
  
  final ValueNotifier<double> scale = ValueNotifier<double>(1.0);
  final ValueNotifier<double> gridScale = ValueNotifier<double>(1.0);
  
  static const _kTextKey = 'tile_text_scale_v3';
  static const _kGridKey = 'tile_grid_scale_v3';
  
  Future<void> load() async {
    try {
      final p = await SharedPreferences.getInstance();
      final textScale = p.getDouble(_kTextKey);
      final gridScaleValue = p.getDouble(_kGridKey);
      if (textScale != null && textScale > 0) scale.value = textScale.clamp(1.0, 3.0);
      if (gridScaleValue != null && gridScaleValue > 0) gridScale.value = gridScaleValue.clamp(0.8, 2.0);
    } catch (_) {}
  }
  
  Future<void> _save() async {
    try {
      final p = await SharedPreferences.getInstance();
      await p.setDouble(_kTextKey, scale.value);
      await p.setDouble(_kGridKey, gridScale.value);
    } catch (_) {}
  }
  
  static Future<void> showSizeSheet(BuildContext context) {
    final ctrl = TileSizeController.instance;
    final bottomPadding = MediaQuery.of(context).padding.bottom + 24;
    
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      showDragHandle: true,
      builder: (ctx) {
        return Padding(
          padding: EdgeInsets.fromLTRB(16, 8, 16, 16 + bottomPadding),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Display Size', style: Theme.of(ctx).textTheme.titleMedium),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Text('Text Size'),
                    const Spacer(),
                    ValueListenableBuilder<double>(
                      valueListenable: ctrl.scale,
                      builder: (_, v, __) => Text('${(v * 100).round()}%'),
                    ),
                  ],
                ),
                ValueListenableBuilder<double>(
                  valueListenable: ctrl.scale,
                  builder: (_, v, __) => Slider(
                    value: v.clamp(1.0, 2.9),
                    min: 1.0,
                    max: 2.9,
                    divisions: 20,
                    label: '${(v * 100).round()}%',
                    onChanged: (nv) => ctrl.scale.value = nv,
                    onChangeEnd: (_) => ctrl._save(),
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    const Text('Tile Size'),
                    const Spacer(),
                    ValueListenableBuilder<double>(
                      valueListenable: ctrl.gridScale,
                      builder: (_, v, __) => Text('${(v * 100).round()}%'),
                    ),
                  ],
                ),
                ValueListenableBuilder<double>(
                  valueListenable: ctrl.gridScale,
                  builder: (_, v, __) => Slider(
                    value: v.clamp(0.5, 2.0),
                    min: 0.5,
                    max: 2.0,
                    divisions: 12,
                    label: '${(v * 100).round()}%',
                    onChanged: (nv) => ctrl.gridScale.value = nv,
                    onChangeEnd: (_) => ctrl._save(),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}