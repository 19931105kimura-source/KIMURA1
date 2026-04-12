import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../state/order_state.dart';
import '../utils/price_format.dart';
import '../../billing/billing_calculator.dart';

class OwnerSeatStatusPage extends StatelessWidget {
  const OwnerSeatStatusPage({super.key});

  String _formatRemaining(int sec) {
    final safe = sec < 0 ? 0 : sec;
    final h = safe ~/ 3600;
    final m = (safe % 3600) ~/ 60;
    final s = safe % 60;
    if (h > 0) {
      return '${h}時間${m.toString().padLeft(2, '0')}分';
    }
    return '${m}分${s.toString().padLeft(2, '0')}秒';
  }

  @override
  Widget build(BuildContext context) {
    final orderState = context.watch<OrderState>();
    final activeTables = orderState.tables
        .where(orderState.isActive)
        .toList()
      ..sort();

    return Scaffold(
      appBar: AppBar(
        title: Text('使用中の席（${activeTables.length}）'),
      ),
      body: activeTables.isEmpty
          ? const Center(
              child: Text(
                '現在使用中の席はありません',
                style: TextStyle(fontSize: 16),
              ),
            )
          : GridView.builder(
              padding: const EdgeInsets.all(16),
              gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                maxCrossAxisExtent: 260,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: 1.0,
              ),
              itemCount: activeTables.length,
              itemBuilder: (context, index) {
                final table = activeTables[index];
                final order = orderState.orderForDisplay(table);
                final total = order == null
                    ? 0
                    : BillingCalculator.calculateFromLines(order.lines).total;
                final timer = orderState.timerOf(table);

                return Card(
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '席 $table',
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        const Spacer(),
                        const Text(
                          '会計金額',
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.white70,
                          ),
                        ),
                        Text(
                          formatYenTruncatedToTen(total),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          '残り時間',
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.white70,
                          ),
                        ),
                        Text(
                          timer == null
                              ? '--'
                              : _formatRemaining(timer.remainingSeconds),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}