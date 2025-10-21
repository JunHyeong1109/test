import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class MealMatchSettingScreen extends StatefulWidget {
  const MealMatchSettingScreen({super.key});

  @override
  State<MealMatchSettingScreen> createState() => _MealMatchSettingScreenState();
}

class _MealMatchSettingScreenState extends State<MealMatchSettingScreen> {
  final _formKey = GlobalKey<FormState>();

  TimeOfDay? startTime;
  TimeOfDay? endTime;
  String? restaurant;
  String? duration;

  int _topTabIndex = 1; // '매칭 설정' 탭
  // int _currentIndex = 2;  // ✅ 하단탭은 Shell에서 관리하므로 제거

  String _fmt(TimeOfDay? t) => t == null
      ? '--:--'
      : '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';
  int _toMinutes(TimeOfDay t) => t.hour * 60 + t.minute;
  bool _isPast(TimeOfDay t) => _toMinutes(t) < _toMinutes(TimeOfDay.now());
  void _showError(String msg) =>
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));

  // ---------- 쿠퍼티노 시간 선택 ----------
  Future<TimeOfDay?> _pickTimeCupertino({
    required String title,
    TimeOfDay? initial,
  }) async {
    final now = DateTime.now();
    final init = DateTime(
      now.year,
      now.month,
      now.day,
      (initial ?? TimeOfDay.now()).hour,
      (initial ?? TimeOfDay.now()).minute,
    );

    TimeOfDay temp = initial ?? TimeOfDay.now();

    final picked = await showCupertinoModalPopup<TimeOfDay?>(
      context: context,
      builder: (popupContext) {
        return Container(
          height: 300,
          color: Colors.white,
          child: Column(
            children: [
              // 상단 바 (←, 제목, ✓)
              SizedBox(
                height: 44,
                child: Row(
                  children: [
                    CupertinoButton(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      onPressed: () => Navigator.pop(popupContext, null),
                      child: const Icon(
                        CupertinoIcons.back,
                        color: Colors.black87,
                      ),
                    ),
                    Expanded(
                      child: Center(
                        child: Text(
                          title,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: Colors.black87,
                          ),
                        ),
                      ),
                    ),
                    CupertinoButton(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      onPressed: () => Navigator.pop(popupContext, temp),
                      child: const Icon(
                        CupertinoIcons.check_mark,
                        color: Color(0xFFF29C50),
                      ),
                    ),
                  ],
                ),
              ),
              const Divider(height: 0),

              // ✅ 하이라이트 숨김용 Stack 래핑
              Expanded(
                child: Stack(
                  children: [
                    CupertinoTheme(
                      data: const CupertinoThemeData(
                        textTheme: CupertinoTextThemeData(
                          dateTimePickerTextStyle: TextStyle(
                            fontSize: 18,
                            color: Colors.black87,
                          ),
                        ),
                      ),
                      child: CupertinoDatePicker(
                        mode: CupertinoDatePickerMode.time,
                        initialDateTime: init,
                        use24hFormat: true,
                        minuteInterval: 1,
                        onDateTimeChanged: (dt) {
                          temp = TimeOfDay(hour: dt.hour, minute: dt.minute);
                        },
                      ),
                    ),
                    // 투명 오버레이: 선택 줄 가리기
                    IgnorePointer(
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Colors.white,
                              Colors.white.withValues(alpha: 0.0),
                              Colors.white.withValues(alpha: 0.0),
                              Colors.white,
                            ],
                            stops: const [0.0, 0.2, 0.8, 1.0],
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );

    return picked;
  }

  // ---------- 시간 선택 ----------
  Future<void> _pickStartTime() async {
    final picked = await _pickTimeCupertino(title: '시작 시간', initial: startTime);
    if (!mounted) return;
    if (picked == null) return;
    if (_isPast(picked)) {
      _showError('시작 시간은 현재 시간 이후만 선택할 수 있어요.');
      return;
    }
    setState(() {
      startTime = picked;
      if (endTime != null && _toMinutes(endTime!) < _toMinutes(startTime!)) {
        endTime = null;
      }
    });
  }

  Future<void> _pickEndTime() async {
    final picked = await _pickTimeCupertino(
      title: '종료 시간',
      initial: endTime ?? startTime,
    );
    if (!mounted) return;
    if (picked == null) return;
    if (_isPast(picked)) {
      _showError('종료 시간은 현재 시간 이후만 선택할 수 있어요.');
      return;
    }
    if (startTime != null && _toMinutes(picked) < _toMinutes(startTime!)) {
      _showError('종료 시간은 시작 시간 이후로 선택해야 해요.');
      return;
    }
    setState(() => endTime = picked);
  }

  void _submit() {
    if (_formKey.currentState?.validate() ?? false) {
      if (startTime == null || endTime == null) {
        _showError('시작/종료 시간을 모두 선택해주세요.');
        return;
      }
      _formKey.currentState!.save();
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('매칭 요청이 전송되었습니다!')));
    }
  }

  // ---------- UI (본문만 반환) ----------
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 12),
        _BuildTopTabs(
          index: _topTabIndex,
          onTap: (i) => setState(() => _topTabIndex = i),
        ),
        const SizedBox(height: 12),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
            child: Form(
              key: _formKey,
              child: Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: _pickStartTime,
                              child: Text(
                                startTime == null ? '시작 시간' : _fmt(startTime),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          const Text('~'),
                          const SizedBox(width: 12),
                          Expanded(
                            child: OutlinedButton(
                              onPressed: _pickEndTime,
                              child: Text(
                                endTime == null ? '종료 시간' : _fmt(endTime),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      _TextField(
                        label: '식당',
                        hint: '선택 입력',
                        onSaved: (v) => restaurant = v,
                      ),
                      const SizedBox(height: 12),
                      _TextField(
                        label: '식사 소요 시간',
                        hint: '예) 15분',
                        onSaved: (v) => duration = v,
                      ),
                      const SizedBox(height: 24),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFF29C50),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          onPressed: _submit,
                          child: const Text(
                            '매칭하기',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// 상단 탭 묶음
class _BuildTopTabs extends StatelessWidget {
  final int index;
  final ValueChanged<int> onTap;
  const _BuildTopTabs({required this.index, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        children: [
          Expanded(
            child: _TopTab(
              label: '채팅 관리',
              selected: index == 0,
              onTap: () => onTap(0),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: _TopTab(
              label: '매칭 설정',
              selected: index == 1,
              onTap: () => onTap(1),
            ),
          ),
        ],
      ),
    );
  }
}

class _TopTab extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  const _TopTab({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 36,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: selected ? const Color(0xFFFFE4CC) : Colors.transparent,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: const Color(0xFFF29C50)),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontWeight: selected ? FontWeight.bold : FontWeight.w500,
            color: Colors.black87,
          ),
        ),
      ),
    );
  }
}

class _TextField extends StatelessWidget {
  final String label;
  final String hint;
  final void Function(String?) onSaved;
  final TextInputType? keyboardType;
  const _TextField({
    required this.label,
    required this.hint,
    required this.onSaved,
    this.keyboardType,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        border: const OutlineInputBorder(),
      ),
      keyboardType: keyboardType,
      onSaved: onSaved,
    );
  }
}
