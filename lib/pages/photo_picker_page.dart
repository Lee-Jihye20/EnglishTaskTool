import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:photo_manager/photo_manager.dart';

import '../theme/app_theme.dart';

/// iOS のシステム写真ピッカー（Safe Area 崩れ）を避けるための
/// アプリ内写真選択画面。
class PhotoPickerPage extends StatefulWidget {
  const PhotoPickerPage({super.key});

  @override
  State<PhotoPickerPage> createState() => _PhotoPickerPageState();
}

class _PhotoPickerPageState extends State<PhotoPickerPage> {
  List<AssetEntity> _assets = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadAssets();
  }

  Future<void> _loadAssets() async {
    final permission = await PhotoManager.requestPermissionExtend();
    if (!permission.isAuth && !permission.hasAccess) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = '写真ライブラリへのアクセスが許可されていません。\n設定アプリから許可してください。';
      });
      return;
    }

    final paths = await PhotoManager.getAssetPathList(
      type: RequestType.image,
      onlyAll: true,
    );
    if (paths.isEmpty) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = '写真が見つかりませんでした。';
      });
      return;
    }

    final assets = await paths.first.getAssetListPaged(page: 0, size: 300);
    if (!mounted) return;
    setState(() {
      _assets = assets;
      _loading = false;
    });
  }

  Future<void> _onAssetTap(AssetEntity asset) async {
    final file = await asset.file;
    if (!mounted) return;
    if (file == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('画像を読み込めませんでした。')),
      );
      return;
    }
    Navigator.of(context).pop(File(file.path));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(
              height: AppTheme.minTouchTarget,
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close),
                    color: AppTheme.ink,
                    tooltip: 'キャンセル',
                  ),
                  const Expanded(
                    child: Text(
                      '写真を選択',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.ink,
                      ),
                    ),
                  ),
                  const SizedBox(width: AppTheme.minTouchTarget),
                ],
              ),
            ),
            const Divider(height: 1, color: AppTheme.line),
            Expanded(child: _buildBody()),
          ],
        ),
      ),
    );
  }

  Widget _buildBody() {
    if (_loading) {
      return const Center(child: CircularProgressIndicator(strokeWidth: 2));
    }
    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(
            _error!,
            textAlign: TextAlign.center,
            style: const TextStyle(color: AppTheme.inkSoft, height: 1.5),
          ),
        ),
      );
    }
    if (_assets.isEmpty) {
      return const Center(
        child: Text(
          '表示できる写真がありません。',
          style: TextStyle(color: AppTheme.inkSoft),
        ),
      );
    }

    return GridView.builder(
      padding: const EdgeInsets.all(2),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 2,
        mainAxisSpacing: 2,
      ),
      itemCount: _assets.length,
      itemBuilder: (context, index) {
        final asset = _assets[index];
        return _PhotoTile(
          asset: asset,
          onTap: () => _onAssetTap(asset),
        );
      },
    );
  }
}

class _PhotoTile extends StatelessWidget {
  final AssetEntity asset;
  final VoidCallback onTap;

  const _PhotoTile({required this.asset, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppTheme.line,
      child: InkWell(
        onTap: onTap,
        child: FutureBuilder<Uint8List?>(
          future: asset.thumbnailDataWithSize(
            const ThumbnailSize.square(300),
          ),
          builder: (context, snapshot) {
            if (snapshot.hasData && snapshot.data != null) {
              return Image.memory(
                snapshot.data!,
                fit: BoxFit.cover,
                width: double.infinity,
                height: double.infinity,
              );
            }
            return const Center(
              child: Icon(Icons.image_outlined, color: AppTheme.inkSoft),
            );
          },
        ),
      ),
    );
  }
}
