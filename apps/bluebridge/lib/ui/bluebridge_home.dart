import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../domain/app_snapshot.dart';
import 'bluebridge_theme.dart';

enum _Page { overview, routes, devices, settings }

class BlueBridgeHome extends StatefulWidget {
  const BlueBridgeHome({super.key, required this.snapshot});

  final AppSnapshot snapshot;

  @override
  State<BlueBridgeHome> createState() => _BlueBridgeHomeState();
}

class _BlueBridgeHomeState extends State<BlueBridgeHome> {
  _Page _page = _Page.overview;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final desktop = constraints.maxWidth >= 860;
        if (desktop) {
          return Scaffold(
            body: Row(
              children: [
                _DesktopNavigation(page: _page, onSelected: _selectPage),
                Expanded(
                  child: _PageBody(page: _page, snapshot: widget.snapshot),
                ),
              ],
            ),
          );
        }

        return Scaffold(
          body: _PageBody(page: _page, snapshot: widget.snapshot),
          bottomNavigationBar: NavigationBar(
            selectedIndex: _page.index,
            onDestinationSelected: (index) => _selectPage(_Page.values[index]),
            backgroundColor: surface,
            indicatorColor: const Color(0xFFE8E8E4),
            destinations: const [
              NavigationDestination(
                icon: Icon(Icons.grid_view_outlined),
                selectedIcon: Icon(Icons.grid_view),
                label: '概览',
              ),
              NavigationDestination(
                icon: Icon(Icons.alt_route_outlined),
                selectedIcon: Icon(Icons.alt_route),
                label: '路由',
              ),
              NavigationDestination(
                icon: Icon(Icons.devices_outlined),
                selectedIcon: Icon(Icons.devices),
                label: '设备',
              ),
              NavigationDestination(
                icon: Icon(Icons.tune_outlined),
                selectedIcon: Icon(Icons.tune),
                label: '设置',
              ),
            ],
          ),
        );
      },
    );
  }

  void _selectPage(_Page page) => setState(() => _page = page);
}

class _DesktopNavigation extends StatelessWidget {
  const _DesktopNavigation({required this.page, required this.onSelected});

  final _Page page;
  final ValueChanged<_Page> onSelected;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 224,
      color: ink,
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 48,
              height: 48,
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Image.asset('assets/images/bluebridge-logo.png'),
            ),
            const SizedBox(height: 12),
            const Text(
              'BlueBridge',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 36),
            _NavigationItem(
              label: '概览',
              icon: Icons.grid_view_outlined,
              selected: page == _Page.overview,
              onTap: () => onSelected(_Page.overview),
            ),
            _NavigationItem(
              label: '路由',
              icon: Icons.alt_route_outlined,
              selected: page == _Page.routes,
              onTap: () => onSelected(_Page.routes),
            ),
            _NavigationItem(
              label: '设备',
              icon: Icons.devices_outlined,
              selected: page == _Page.devices,
              onTap: () => onSelected(_Page.devices),
            ),
            _NavigationItem(
              label: '设置',
              icon: Icons.tune_outlined,
              selected: page == _Page.settings,
              onTap: () => onSelected(_Page.settings),
            ),
            const Spacer(),
            const Text(
              '本地优先 · 无需登录',
              style: TextStyle(color: Color(0xFF9A9A95), fontSize: 11),
            ),
          ],
        ),
      ),
    );
  }
}

class _NavigationItem extends StatelessWidget {
  const _NavigationItem({
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Material(
        color: selected ? Colors.white : Colors.transparent,
        borderRadius: BorderRadius.circular(8),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(8),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
            child: Row(
              children: [
                Icon(
                  icon,
                  size: 19,
                  color: selected ? ink : const Color(0xFF9A9A95),
                ),
                const SizedBox(width: 11),
                Text(
                  label,
                  style: TextStyle(
                    color: selected ? ink : const Color(0xFFD0D0CB),
                    fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _PageBody extends StatelessWidget {
  const _PageBody({required this.page, required this.snapshot});

  final _Page page;
  final AppSnapshot snapshot;

  @override
  Widget build(BuildContext context) {
    final title = switch (page) {
      _Page.overview => '控制中心',
      _Page.routes => '音频路由',
      _Page.devices => '设备',
      _Page.settings => '设置',
    };

    final detail = switch (page) {
      _Page.overview => '统一管理本机音频与跨设备连接',
      _Page.routes => '查看真实音频来源、目标设备与输出',
      _Page.devices => '只显示已发现或已信任的真实设备',
      _Page.settings => '管理本地处理、权限与连接策略',
    };

    return SafeArea(
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.fromLTRB(28, 24, 28, 20),
            decoration: const BoxDecoration(
              border: Border(bottom: BorderSide(color: line)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: Theme.of(context).textTheme.headlineLarge,
                      ),
                      const SizedBox(height: 5),
                      Text(
                        detail,
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
                _MigrationBadge(ready: snapshot.platformAudioReady),
              ],
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(28),
              child: Align(
                alignment: Alignment.topCenter,
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 1080),
                  child: switch (page) {
                    _Page.overview => _Overview(snapshot: snapshot),
                    _Page.routes => _Routes(snapshot: snapshot),
                    _Page.devices => _Devices(snapshot: snapshot),
                    _Page.settings => const _Settings(),
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MigrationBadge extends StatelessWidget {
  const _MigrationBadge({required this.ready});

  final bool ready;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 7),
      decoration: BoxDecoration(
        color: surface,
        border: Border.all(color: line),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        ready ? '音频适配器已连接' : 'UI 重置阶段',
        style: Theme.of(context).textTheme.labelMedium,
      ),
    );
  }
}

class _Overview extends StatelessWidget {
  const _Overview({required this.snapshot});

  final AppSnapshot snapshot;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _Notice(
          title: '正在迁移平台音频能力',
          detail: '当前界面不使用模拟设备或模拟连接。真实适配器接入后，状态会自动显示在这里。',
          icon: Icons.info_outline,
        ),
        const SizedBox(height: 18),
        LayoutBuilder(
          builder: (context, constraints) {
            final stacked = constraints.maxWidth < 680;
            final cards = [
              _SummaryCard(
                label: '平台音频',
                value: snapshot.platformAudioReady ? '已接入' : '尚未接入',
                detail: _platformLabel(),
              ),
              _SummaryCard(
                label: '可信设备',
                value: '${snapshot.devices.length}',
                detail: '真实发现结果',
              ),
              _SummaryCard(
                label: '当前路由',
                value: snapshot.activeRoute == null ? '未启动' : '运行中',
                detail: '没有模拟会话',
              ),
            ];

            if (stacked) {
              return Column(
                children: cards
                    .map(
                      (card) => Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: card,
                      ),
                    )
                    .toList(),
              );
            }

            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: cards
                  .map(
                    (card) => Expanded(
                      child: Padding(
                        padding: EdgeInsets.only(
                          right: card == cards.last ? 0 : 10,
                        ),
                        child: card,
                      ),
                    ),
                  )
                  .toList(),
            );
          },
        ),
        const SizedBox(height: 24),
        Text('开始使用', style: Theme.of(context).textTheme.headlineSmall),
        const SizedBox(height: 10),
        _Panel(
          child: Column(
            children: [
              const _StepRow(
                index: '01',
                title: '接入本机音频',
                detail: '为当前平台实现真实的采集与输出适配器',
                status: '待迁移',
              ),
              const Divider(height: 1),
              const _StepRow(
                index: '02',
                title: '发现并确认设备',
                detail: '只保存双方确认过的本地可信设备',
                status: '待实现',
              ),
              const Divider(height: 1),
              const _StepRow(
                index: '03',
                title: '创建音频路由',
                detail: '选择来源、目标设备与最终输出',
                status: '待实现',
              ),
              const SizedBox(height: 18),
              Align(
                alignment: Alignment.centerLeft,
                child: FilledButton(
                  onPressed: snapshot.platformAudioReady ? () {} : null,
                  child: const Text('创建第一条路由'),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _Routes extends StatelessWidget {
  const _Routes({required this.snapshot});

  final AppSnapshot snapshot;

  @override
  Widget build(BuildContext context) {
    if (snapshot.activeRoute == null) {
      return const _EmptyState(
        icon: Icons.alt_route,
        title: '暂无路由',
        detail: '平台音频和设备发现接入后，才能创建真实路由。',
      );
    }

    final route = snapshot.activeRoute!;
    return _Panel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('当前路由', style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 18),
          _RouteNode(label: '来源', value: route.source),
          const _RouteConnector(),
          _RouteNode(label: '目标设备', value: route.destination),
          const _RouteConnector(),
          _RouteNode(label: '输出', value: route.output),
        ],
      ),
    );
  }
}

class _Devices extends StatelessWidget {
  const _Devices({required this.snapshot});

  final AppSnapshot snapshot;

  @override
  Widget build(BuildContext context) {
    if (snapshot.devices.isEmpty) {
      return const _EmptyState(
        icon: Icons.devices_outlined,
        title: '尚未发现设备',
        detail: '局域网发现和可信配对接入后，这里只显示真实设备。',
      );
    }

    return _Panel(
      child: Column(
        children: snapshot.devices
            .map(
              (device) => ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.computer_outlined),
                title: Text(device.name),
                subtitle: const Text('已确认的可信设备'),
              ),
            )
            .toList(),
      ),
    );
  }
}

class _Settings extends StatelessWidget {
  const _Settings();

  @override
  Widget build(BuildContext context) {
    return const _Panel(
      child: Column(
        children: [
          _SettingRow(label: '账户', value: '无需登录'),
          Divider(height: 1),
          _SettingRow(label: '音频处理', value: '仅在本地'),
          Divider(height: 1),
          _SettingRow(label: '跨设备传输', value: '尚未接入'),
          Divider(height: 1),
          _SettingRow(label: '诊断数据', value: '默认关闭'),
        ],
      ),
    );
  }
}

class _Panel extends StatelessWidget {
  const _Panel({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: surface,
        border: Border.all(color: line),
        borderRadius: BorderRadius.circular(12),
      ),
      child: child,
    );
  }
}

class _Notice extends StatelessWidget {
  const _Notice({
    required this.title,
    required this.detail,
    required this.icon,
  });

  final String title;
  final String detail;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return _Panel(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: ink),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 4),
                Text(detail, style: Theme.of(context).textTheme.bodySmall),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({
    required this.label,
    required this.value,
    required this.detail,
  });

  final String label;
  final String value;
  final String detail;

  @override
  Widget build(BuildContext context) {
    return _Panel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: Theme.of(context).textTheme.labelMedium),
          const SizedBox(height: 10),
          Text(value, style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 4),
          Text(detail, style: Theme.of(context).textTheme.bodySmall),
        ],
      ),
    );
  }
}

class _StepRow extends StatelessWidget {
  const _StepRow({
    required this.index,
    required this.title,
    required this.detail,
    required this.status,
  });

  final String index;
  final String title;
  final String detail;
  final String status;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 15),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 36,
            child: Text(index, style: Theme.of(context).textTheme.labelMedium),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 3),
                Text(detail, style: Theme.of(context).textTheme.bodySmall),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Text(status, style: Theme.of(context).textTheme.labelMedium),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({
    required this.icon,
    required this.title,
    required this.detail,
  });

  final IconData icon;
  final String title;
  final String detail;

  @override
  Widget build(BuildContext context) {
    return _Panel(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 60, horizontal: 20),
        child: Column(
          children: [
            Icon(icon, size: 34, color: muted),
            const SizedBox(height: 16),
            Text(title, style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 6),
            Text(
              detail,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }
}

class _RouteNode extends StatelessWidget {
  const _RouteNode({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: canvas,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Text(label, style: Theme.of(context).textTheme.labelMedium),
          const Spacer(),
          Text(value, style: Theme.of(context).textTheme.titleMedium),
        ],
      ),
    );
  }
}

class _RouteConnector extends StatelessWidget {
  const _RouteConnector();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.only(left: 18, top: 4, bottom: 4),
      child: Icon(Icons.arrow_downward, size: 15, color: muted),
    );
  }
}

class _SettingRow extends StatelessWidget {
  const _SettingRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Row(
        children: [
          Expanded(child: Text(label)),
          Text(value, style: Theme.of(context).textTheme.bodySmall),
        ],
      ),
    );
  }
}

String _platformLabel() {
  return switch (defaultTargetPlatform) {
    TargetPlatform.android => 'Android',
    TargetPlatform.macOS => 'macOS',
    TargetPlatform.windows => 'Windows',
    _ => '当前平台',
  };
}
