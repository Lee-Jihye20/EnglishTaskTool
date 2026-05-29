import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import '../services/translation_service.dart';
import '../widgets/app_header.dart';
import '../widgets/dismiss_keyboard.dart';

/// 単語の並べ替え基準。
enum SortMode { defaultOrder, alphabetical, frequency }

/// 1つの単語とその出現回数。
class WordEntry {
  final String word;
  final int count;
  final int firstIndex; // デフォルト順（出現順）用

  const WordEntry({
    required this.word,
    required this.count,
    required this.firstIndex,
  });
}

/// 単語整理ボタンから開くCanvas相当の画面。
/// 英文中の単語を抽出して一意化し、並べ替え・検索・タップ翻訳を行う。
class WordListPage extends StatefulWidget {
  final String sourceText;
  final TranslationService translator;

  const WordListPage({
    super.key,
    required this.sourceText,
    required this.translator,
  });

  @override
  State<WordListPage> createState() => _WordListPageState();
}

class _WordListPageState extends State<WordListPage> {
  late final List<WordEntry> _allWords;
  final TextEditingController _search = TextEditingController();

  SortMode _sortMode = SortMode.defaultOrder;
  bool _ascending = true;
  String _query = '';

  // 単語ごとの翻訳キャッシュ。
  final Map<String, String> _translationCache = {};

  @override
  void initState() {
    super.initState();
    _allWords = _extractWords(widget.sourceText);
    _search.addListener(() {
      setState(() => _query = _search.text.trim().toLowerCase());
    });
  }

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  /// 英文から単語を抽出し、小文字で正規化して一意化、出現回数を数える。
  List<WordEntry> _extractWords(String text) {
    // アポストロフィを含む単語（don't, it's 等）も1語として扱う。
    final matches =
        RegExp(r"[A-Za-z]+(?:'[A-Za-z]+)?").allMatches(text.toLowerCase());

    final counts = <String, int>{};
    final firstIndex = <String, int>{};
    var index = 0;
    for (final m in matches) {
      final w = m.group(0)!;
      counts[w] = (counts[w] ?? 0) + 1;
      firstIndex.putIfAbsent(w, () => index++);
    }

    return counts.entries
        .map((e) => WordEntry(
              word: e.key,
              count: e.value,
              firstIndex: firstIndex[e.key]!,
            ))
        .toList();
  }

  List<WordEntry> get _visibleWords {
    var list = _allWords
        .where((w) => _query.isEmpty || w.word.contains(_query))
        .toList();

    int cmp(WordEntry a, WordEntry b) {
      switch (_sortMode) {
        case SortMode.alphabetical:
          return a.word.compareTo(b.word);
        case SortMode.frequency:
          final byCount = a.count.compareTo(b.count);
          return byCount != 0 ? byCount : a.word.compareTo(b.word);
        case SortMode.defaultOrder:
          return a.firstIndex.compareTo(b.firstIndex);
      }
    }

    list.sort((a, b) => _ascending ? cmp(a, b) : -cmp(a, b));
    return list;
  }

  Future<void> _showTranslation(WordEntry entry) async {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => _WordTranslationSheet(
        entry: entry,
        cached: _translationCache[entry.word],
        translate: () async {
          final cached = _translationCache[entry.word];
          if (cached != null) return cached;
          final result = await widget.translator
              .translate(entry.word, source: 'en', target: 'ja');
          _translationCache[entry.word] = result;
          return result;
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final words = _visibleWords;

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBreadcrumbBar(
        segments: ['攻略APP', '単語整理', '単語一覧（${_allWords.length}語）'],
      ),
      body: DismissKeyboard(
        child: Column(
          children: [
            _Controls(
              search: _search,
              sortMode: _sortMode,
              ascending: _ascending,
              onSortChanged: (m) => setState(() => _sortMode = m),
              onToggleOrder: () => setState(() => _ascending = !_ascending),
            ),
            Expanded(
              child: words.isEmpty
                  ? const Center(
                      child: Text(
                        '該当する単語がありません。',
                        style: TextStyle(color: AppTheme.inkSoft),
                      ),
                    )
                  : ListView.separated(
                      keyboardDismissBehavior:
                          ScrollViewKeyboardDismissBehavior.onDrag,
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                      itemCount: words.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 8),
                      itemBuilder: (_, i) => _WordTile(
                        entry: words[i],
                        onTap: () => _showTranslation(words[i]),
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Controls extends StatelessWidget {
  final TextEditingController search;
  final SortMode sortMode;
  final bool ascending;
  final ValueChanged<SortMode> onSortChanged;
  final VoidCallback onToggleOrder;

  const _Controls({
    required this.search,
    required this.sortMode,
    required this.ascending,
    required this.onSortChanged,
    required this.onToggleOrder,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      decoration: const BoxDecoration(
        color: AppTheme.surface,
        border: Border(bottom: BorderSide(color: AppTheme.line)),
      ),
      child: Column(
        children: [
          // 検索ボックス
          TextField(
            controller: search,
            decoration: const InputDecoration(
              prefixIcon: Icon(Icons.search, color: AppTheme.inkSoft),
              hintText: '単語を検索',
              isDense: true,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _SortChip(
                        label: 'デフォルト',
                        selected: sortMode == SortMode.defaultOrder,
                        onTap: () => onSortChanged(SortMode.defaultOrder),
                      ),
                      const SizedBox(width: 8),
                      _SortChip(
                        label: 'ABC順',
                        selected: sortMode == SortMode.alphabetical,
                        onTap: () => onSortChanged(SortMode.alphabetical),
                      ),
                      const SizedBox(width: 8),
                      _SortChip(
                        label: '使用回数順',
                        selected: sortMode == SortMode.frequency,
                        onTap: () => onSortChanged(SortMode.frequency),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 8),
              // 昇順 / 降順 トグル
              _MinTouchInkWell(
                onTap: onToggleOrder,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  decoration: BoxDecoration(
                    border: Border.all(color: AppTheme.ink),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        ascending ? Icons.arrow_upward : Icons.arrow_downward,
                        size: 16,
                        color: AppTheme.ink,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        ascending ? '昇順' : '降順',
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.ink,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SortChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _SortChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return _MinTouchInkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(22),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: selected ? AppTheme.ink : Colors.transparent,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(
            color: selected ? AppTheme.ink : AppTheme.line,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: selected ? AppTheme.surface : AppTheme.ink,
          ),
        ),
      ),
    );
  }
}

class _MinTouchInkWell extends StatelessWidget {
  final VoidCallback onTap;
  final Widget child;
  final BorderRadius? borderRadius;

  const _MinTouchInkWell({
    required this.onTap,
    required this.child,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: borderRadius ?? BorderRadius.circular(10),
        child: ConstrainedBox(
          constraints: const BoxConstraints(
            minWidth: AppTheme.minTouchTarget,
            minHeight: AppTheme.minTouchTarget,
          ),
          child: Center(child: child),
        ),
      ),
    );
  }
}

class _WordTile extends StatelessWidget {
  final WordEntry entry;
  final VoidCallback onTap;

  const _WordTile({required this.entry, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppTheme.surface,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          constraints: const BoxConstraints(minHeight: AppTheme.minTouchTarget),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppTheme.line),
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  entry.word,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.ink,
                  ),
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppTheme.background,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppTheme.line),
                ),
                child: Text(
                  '×${entry.count}',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.inkSoft,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              const Icon(Icons.translate, size: 18, color: AppTheme.inkSoft),
            ],
          ),
        ),
      ),
    );
  }
}

/// 単語タップ時に表示する翻訳ポップアップ（modalPopUp相当）。
class _WordTranslationSheet extends StatelessWidget {
  final WordEntry entry;
  final String? cached;
  final Future<String> Function() translate;

  const _WordTranslationSheet({
    required this.entry,
    required this.cached,
    required this.translate,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
        24,
        20,
        24,
        24 + MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppTheme.line,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 18),
          Text(
            entry.word,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w800,
              color: AppTheme.ink,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '出現回数 ${entry.count} 回',
            style: const TextStyle(fontSize: 13, color: AppTheme.inkSoft),
          ),
          const Divider(height: 28, color: AppTheme.line),
          const Text(
            '日本語訳',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: AppTheme.inkSoft,
            ),
          ),
          const SizedBox(height: 8),
          FutureBuilder<String>(
            future: translate(),
            initialData: cached,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting &&
                  !snapshot.hasData) {
                return const Padding(
                  padding: EdgeInsets.symmetric(vertical: 8),
                  child: Row(
                    children: [
                      SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                      SizedBox(width: 12),
                      Text('翻訳中…',
                          style: TextStyle(color: AppTheme.inkSoft)),
                    ],
                  ),
                );
              }
              if (snapshot.hasError) {
                return const Text(
                  '翻訳に失敗しました。通信環境を確認してください。',
                  style: TextStyle(color: AppTheme.ink),
                );
              }
              return Text(
                (snapshot.data == null || snapshot.data!.isEmpty)
                    ? '訳が取得できませんでした。'
                    : snapshot.data!,
                style: const TextStyle(fontSize: 18, color: AppTheme.ink),
              );
            },
          ),
        ],
      ),
    );
  }
}
