import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../models/device.dart';
import '../providers/device_provider.dart';

class DeviceListScreen extends ConsumerStatefulWidget {
  const DeviceListScreen({super.key});

  @override
  ConsumerState<DeviceListScreen> createState() => _DeviceListScreenState();
}

class _DeviceListScreenState extends ConsumerState<DeviceListScreen> {
  @override
  void initState() {
    super.initState();
    // 화면 진입 시 디바이스 목록 조회
    Future.microtask(() {
      ref.read(deviceListProvider.notifier).fetchDevices();
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final deviceState = ref.watch(deviceListProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('디바이스 관리'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: '새로고침',
            onPressed: () {
              ref.read(deviceListProvider.notifier).fetchDevices();
            },
          ),
        ],
      ),
      body: _buildBody(theme, deviceState),
    );
  }

  Widget _buildBody(ThemeData theme, DeviceListState deviceState) {
    if (deviceState.isLoading && deviceState.devices.isEmpty) {
      return const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('디바이스 목록을 불러오는 중...'),
          ],
        ),
      );
    }

    if (deviceState.error != null && deviceState.devices.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.error_outline,
              size: 48,
              color: theme.colorScheme.error,
            ),
            const SizedBox(height: 16),
            Text(
              '디바이스 목록을 불러올 수 없습니다.',
              style: theme.textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(
              deviceState.error!,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            OutlinedButton.icon(
              onPressed: () {
                ref.read(deviceListProvider.notifier).fetchDevices();
              },
              icon: const Icon(Icons.refresh),
              label: const Text('다시 시도'),
            ),
          ],
        ),
      );
    }

    if (deviceState.devices.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.devices,
              size: 64,
              color: theme.colorScheme.onSurfaceVariant.withOpacity(0.4),
            ),
            const SizedBox(height: 16),
            Text(
              '등록된 디바이스가 없습니다.',
              style: theme.textTheme.titleMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () async {
        await ref.read(deviceListProvider.notifier).fetchDevices();
      },
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 요약 헤더
            _buildSummaryHeader(theme, deviceState.devices),
            const SizedBox(height: 20),
            // 디바이스 카드 목록
            Expanded(
              child: ListView.separated(
                itemCount: deviceState.devices.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  return _DeviceCard(
                    device: deviceState.devices[index],
                    onEdit: () => _showEditDialog(deviceState.devices[index]),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryHeader(ThemeData theme, List<Device> devices) {
    final activeCount =
        devices.where((d) => d.status == DeviceStatus.ACTIVE).length;
    final inactiveCount =
        devices.where((d) => d.status == DeviceStatus.INACTIVE).length;
    final offlineCount =
        devices.where((d) => d.status == DeviceStatus.OFFLINE).length;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: theme.colorScheme.outlineVariant.withOpacity(0.5),
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.devices,
            color: theme.colorScheme.primary,
            size: 28,
          ),
          const SizedBox(width: 12),
          Text(
            '전체 ${devices.length}대',
            style: theme.textTheme.titleMedium?.copyWith(
              color: theme.colorScheme.onSurface,
            ),
          ),
          const Spacer(),
          _StatusChip(
            label: '활성 $activeCount',
            color: DeviceStatus.ACTIVE.color,
            bgColor: DeviceStatus.ACTIVE.backgroundColor,
          ),
          const SizedBox(width: 8),
          _StatusChip(
            label: '비활성 $inactiveCount',
            color: DeviceStatus.INACTIVE.color,
            bgColor: DeviceStatus.INACTIVE.backgroundColor,
          ),
          const SizedBox(width: 8),
          _StatusChip(
            label: '오프라인 $offlineCount',
            color: DeviceStatus.OFFLINE.color,
            bgColor: DeviceStatus.OFFLINE.backgroundColor,
          ),
        ],
      ),
    );
  }

  void _showEditDialog(Device device) {
    showDialog(
      context: context,
      builder: (ctx) => _DeviceEditDialog(
        device: device,
        onSave: (name, status) {
          ref.read(deviceListProvider.notifier).updateDevice(
                device.id,
                deviceName: name,
                status: status,
              );
        },
      ),
    );
  }
}

// ─────────────────────────────────────────────────
// 상태 칩 위젯
// ─────────────────────────────────────────────────

class _StatusChip extends StatelessWidget {
  final String label;
  final Color color;
  final Color bgColor;

  const _StatusChip({
    required this.label,
    required this.color,
    required this.bgColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 13,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────
// 디바이스 카드 위젯
// ─────────────────────────────────────────────────

class _DeviceCard extends StatelessWidget {
  final Device device;
  final VoidCallback onEdit;

  const _DeviceCard({
    required this.device,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: theme.colorScheme.outlineVariant.withOpacity(0.5),
        ),
      ),
      child: InkWell(
        onTap: onEdit,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              // 디바이스 아이콘
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: theme.colorScheme.primaryContainer.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  device.type.icon,
                  size: 28,
                  color: theme.colorScheme.primary,
                ),
              ),
              const SizedBox(width: 16),
              // 디바이스 정보
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            device.deviceName ?? device.deviceCode,
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 8),
                        _DeviceStatusBadge(status: device.status),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        _InfoTag(
                          icon: device.type.icon,
                          label: device.type.label,
                        ),
                        const SizedBox(width: 12),
                        _InfoTag(
                          icon: device.os.icon,
                          label: device.os.label,
                        ),
                        if (device.appVersion != null) ...[
                          const SizedBox(width: 12),
                          _InfoTag(
                            icon: Icons.info_outline,
                            label: 'v${device.appVersion}',
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(
                          Icons.access_time,
                          size: 14,
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          device.lastSeenAt != null
                              ? '마지막 접속: ${_formatDateTime(device.lastSeenAt!)}'
                              : '접속 기록 없음',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              // 편집 아이콘
              Icon(
                Icons.chevron_right,
                color: theme.colorScheme.onSurfaceVariant.withOpacity(0.5),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDateTime(DateTime dt) {
    final now = DateTime.now();
    final diff = now.difference(dt);

    if (diff.inMinutes < 1) return '방금 전';
    if (diff.inMinutes < 60) return '${diff.inMinutes}분 전';
    if (diff.inHours < 24) return '${diff.inHours}시간 전';
    if (diff.inDays < 7) return '${diff.inDays}일 전';

    return DateFormat('yyyy-MM-dd HH:mm').format(dt.toLocal());
  }
}

// ─────────────────────────────────────────────────
// 상태 배지 위젯
// ─────────────────────────────────────────────────

class _DeviceStatusBadge extends StatelessWidget {
  final DeviceStatus status;

  const _DeviceStatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: status.backgroundColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            status.icon,
            size: 14,
            color: status.color,
          ),
          const SizedBox(width: 4),
          Text(
            status.label,
            style: TextStyle(
              color: status.color,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────
// 정보 태그 위젯
// ─────────────────────────────────────────────────

class _InfoTag extends StatelessWidget {
  final IconData icon;
  final String label;

  const _InfoTag({
    required this.icon,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          size: 14,
          color: theme.colorScheme.onSurfaceVariant,
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────
// 디바이스 수정 다이얼로그
// ─────────────────────────────────────────────────

class _DeviceEditDialog extends StatefulWidget {
  final Device device;
  final void Function(String? name, DeviceStatus? status) onSave;

  const _DeviceEditDialog({
    required this.device,
    required this.onSave,
  });

  @override
  State<_DeviceEditDialog> createState() => _DeviceEditDialogState();
}

class _DeviceEditDialogState extends State<_DeviceEditDialog> {
  late final TextEditingController _nameController;
  late DeviceStatus _selectedStatus;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(
      text: widget.device.deviceName ?? '',
    );
    _selectedStatus = widget.device.status;
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Row(
        children: [
          Icon(
            Icons.edit,
            color: theme.colorScheme.primary,
            size: 24,
          ),
          const SizedBox(width: 8),
          const Text('디바이스 수정'),
        ],
      ),
      content: SizedBox(
        width: 400,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 디바이스 코드 (읽기 전용)
            Text(
              '디바이스 코드',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 4),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerHighest
                    .withOpacity(0.5),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                widget.device.deviceCode,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                  fontFamily: 'monospace',
                ),
              ),
            ),
            const SizedBox(height: 20),

            // 디바이스 이름
            Text(
              '디바이스 이름',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 4),
            TextField(
              controller: _nameController,
              decoration: InputDecoration(
                hintText: '디바이스 이름을 입력하세요',
                prefixIcon: const Icon(Icons.label_outline),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // 상태 선택
            Text(
              '상태',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: DeviceStatus.values.map((status) {
                final isSelected = status == _selectedStatus;
                return Expanded(
                  child: Padding(
                    padding: EdgeInsets.only(
                      right: status != DeviceStatus.values.last ? 8.0 : 0,
                    ),
                    child: _StatusSelectButton(
                      status: status,
                      isSelected: isSelected,
                      onTap: () {
                        setState(() => _selectedStatus = status);
                      },
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('취소'),
        ),
        ElevatedButton(
          onPressed: () {
            final name = _nameController.text.trim();
            widget.onSave(
              name.isNotEmpty ? name : null,
              _selectedStatus != widget.device.status
                  ? _selectedStatus
                  : null,
            );
            Navigator.pop(context);
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: theme.colorScheme.primary,
            foregroundColor: theme.colorScheme.onPrimary,
          ),
          child: const Text('저장'),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────
// 상태 선택 버튼
// ─────────────────────────────────────────────────

class _StatusSelectButton extends StatelessWidget {
  final DeviceStatus status;
  final bool isSelected;
  final VoidCallback onTap;

  const _StatusSelectButton({
    required this.status,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected
                ? status.backgroundColor
                : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: isSelected
                  ? status.color
                  : Theme.of(context)
                      .colorScheme
                      .outlineVariant
                      .withOpacity(0.5),
              width: isSelected ? 2 : 1,
            ),
          ),
          child: Column(
            children: [
              Icon(
                status.icon,
                size: 20,
                color: isSelected
                    ? status.color
                    : Theme.of(context).colorScheme.onSurfaceVariant,
              ),
              const SizedBox(height: 4),
              Text(
                status.label,
                style: TextStyle(
                  color: isSelected
                      ? status.color
                      : Theme.of(context).colorScheme.onSurfaceVariant,
                  fontSize: 12,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
