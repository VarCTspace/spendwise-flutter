import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';

import '../app/app_theme.dart';
import '../providers/transaction_provider.dart';
import 'add_transaction_screen.dart';
import 'history_screen.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  String money(double value) {
    return NumberFormat.currency(
      locale: 'en_IN',
      symbol: '₹',
      decimalDigits: 0,
    ).format(value);
  }

  @override
  Widget build(BuildContext context) {
    final desktop = MediaQuery.of(context).size.width >= 950;

    return Scaffold(
      body: Row(
        children: [
          if (desktop) _sidebar(context),
          Expanded(
            child: SafeArea(
              child: Consumer<TransactionProvider>(
                builder: (context, provider, child) {
                  final now = DateTime.now();

                  final monthly = provider.transactions.where((t) =>
                      t.date.year == now.year &&
                      t.date.month == now.month).toList();

                  final income = monthly
                      .where((t) => t.isIncome)
                      .fold(0.0, (s, t) => s + t.amount);

                  final expenses = monthly
                      .where((t) => !t.isIncome)
                      .fold(0.0, (s, t) => s + t.amount);

                  final savings = income - expenses;

                  final savingsRate =
                      income > 0 ? (savings / income) * 100 : 0.0;

                  final dailyAverage =
                      expenses / now.day;

                  final categoryTotals = <String, double>{};

                  for (final t in monthly.where((t) => !t.isIncome)) {
                    categoryTotals[t.category] =
                        (categoryTotals[t.category] ?? 0) + t.amount;
                  }

                  String highestCategory = 'No spending yet';

                  if (categoryTotals.isNotEmpty) {
                    highestCategory = categoryTotals.entries
                        .reduce((a, b) => a.value > b.value ? a : b)
                        .key;
                  }

                  return SingleChildScrollView(
                    padding: EdgeInsets.all(desktop ? 30 : 18),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _header(context),

                        const SizedBox(height: 28),

                        Text(
                          'Welcome to SpendWise 👋',
                          style: TextStyle(
                            fontSize: desktop ? 25 : 21,
                            fontWeight: FontWeight.bold,
                          ),
                        ),

                        const SizedBox(height: 5),

                        Text(
                          DateFormat('MMMM yyyy').format(now),
                          style: const TextStyle(color: Colors.grey),
                        ),

                        const SizedBox(height: 22),

                        _balanceCard(provider.balance),

                        const SizedBox(height: 25),

                        _sectionTitle('Financial Overview'),

                        const SizedBox(height: 14),

                        GridView.count(
                          crossAxisCount: desktop ? 4 : 2,
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                          childAspectRatio: desktop ? 1.45 : 1.5,
                          children: [
                            _statCard(
                              'Monthly Income',
                              money(income),
                              Icons.trending_up,
                              AppTheme.income,
                            ),
                            _statCard(
                              'Monthly Expenses',
                              money(expenses),
                              Icons.trending_down,
                              AppTheme.expense,
                            ),
                            _statCard(
                              'Savings Rate',
                              '${savingsRate.toStringAsFixed(1)}%',
                              Icons.savings_outlined,
                              AppTheme.primary,
                            ),
                            _statCard(
                              'Daily Average',
                              money(dailyAverage),
                              Icons.calendar_today,
                              Colors.orange,
                            ),
                          ],
                        ),

                        const SizedBox(height: 28),

                        _sectionTitle('Spending Analytics'),

                        const SizedBox(height: 14),

                        _chartCard(
                          title: 'Expense Distribution',
                          subtitle: 'Category-wise spending this month',
                          child: categoryTotals.isEmpty
                              ? _emptyChart()
                              : _expenseChart(categoryTotals),
                        ),

                        const SizedBox(height: 16),

                        _chartCard(
                          title: 'Monthly Cash Flow',
                          subtitle: 'Income vs expenses – last 6 months',
                          child: _cashFlowChart(provider.transactions),
                        ),

                        const SizedBox(height: 28),

                        _sectionTitle('Smart Insights'),

                        const SizedBox(height: 14),

                        _insightCard(
                          icon: Icons.category_outlined,
                          color: Colors.orange,
                          title: 'Highest Spending Category',
                          description: highestCategory,
                        ),

                        const SizedBox(height: 10),

                        _insightCard(
                          icon: Icons.lightbulb_outline,
                          color: AppTheme.primary,
                          title: 'Savings Analysis',
                          description: income == 0
                              ? 'Add income entries to calculate your savings rate.'
                              : savings >= 0
                                  ? 'You have saved ${money(savings)} this month.'
                                  : 'Your expenses exceed your income by ${money(-savings)}.',
                        ),

                        const SizedBox(height: 10),

                        _insightCard(
                          icon: Icons.receipt_long,
                          color: Colors.blue,
                          title: 'Transaction Activity',
                          description:
                              '${monthly.length} transactions recorded this month.',
                        ),

                        const SizedBox(height: 28),

                        Row(
                          mainAxisAlignment:
                              MainAxisAlignment.spaceBetween,
                          children: [
                            _sectionTitle('Recent Transactions'),
                            TextButton(
                              onPressed: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const HistoryScreen(),
                                ),
                              ),
                              child: const Text('View All'),
                            ),
                          ],
                        ),

                        const SizedBox(height: 10),

                        if (provider.transactions.isEmpty)
                          _emptyTransactions(context)
                        else
                          ...provider.transactions.take(5).map((t) {
                            final color = t.isIncome
                                ? AppTheme.income
                                : AppTheme.expense;

                            return Card(
                              margin: const EdgeInsets.only(bottom: 9),
                              child: ListTile(
                                leading: CircleAvatar(
                                  backgroundColor:
                                      color.withValues(alpha: 0.12),
                                  child: Icon(
                                    t.isIncome
                                        ? Icons.arrow_downward
                                        : Icons.arrow_upward,
                                    color: color,
                                  ),
                                ),
                                title: Text(t.title),
                                subtitle: Text(
                                  '${t.category} • ${DateFormat('dd MMM yyyy').format(t.date)}',
                                ),
                                trailing: Text(
                                  '${t.isIncome ? '+' : '-'}${money(t.amount)}',
                                  style: TextStyle(
                                    color: color,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            );
                          }),

                        const SizedBox(height: 80),
                      ],
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),

      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => const AddTransactionScreen(),
          ),
        ),
        icon: const Icon(Icons.add),
        label: const Text('Add Transaction'),
      ),

      bottomNavigationBar: desktop
          ? null
          : NavigationBar(
              selectedIndex: 0,
              onDestinationSelected: (index) {
                if (index == 1) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const HistoryScreen(),
                    ),
                  );
                } else if (index == 2) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Analytics dashboard is shown above.'),
                    ),
                  );
                } else if (index == 3) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Profile module is coming next.'),
                    ),
                  );
                }
              },
              destinations: const [
                NavigationDestination(
                  icon: Icon(Icons.dashboard_outlined),
                  label: 'Home',
                ),
                NavigationDestination(
                  icon: Icon(Icons.receipt_long),
                  label: 'History',
                ),
                NavigationDestination(
                  icon: Icon(Icons.analytics_outlined),
                  label: 'Analytics',
                ),
                NavigationDestination(
                  icon: Icon(Icons.person_outline),
                  label: 'Profile',
                ),
              ],
            ),
    );
  }

  Widget _header(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text(
          'SpendWise',
          style: TextStyle(
            fontSize: 25,
            fontWeight: FontWeight.bold,
            color: AppTheme.primary,
          ),
        ),
        Row(
          children: [
            IconButton(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('You are all caught up!'),
                  ),
                );
              },
              icon: const Icon(Icons.notifications_none),
            ),
            const CircleAvatar(
              backgroundColor: Color(0xFFE7DDFB),
              child: Icon(Icons.person, color: AppTheme.primary),
            ),
          ],
        ),
      ],
    );
  }

  Widget _sidebar(BuildContext context) {
    return Container(
      width: 225,
      color: Colors.white,
      padding: const EdgeInsets.all(22),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'SpendWise',
            style: TextStyle(
              fontSize: 25,
              fontWeight: FontWeight.bold,
              color: AppTheme.primary,
            ),
          ),
          const SizedBox(height: 40),
          _menuItem(Icons.dashboard, 'Dashboard', true, () {}),
          _menuItem(
            Icons.add_circle_outline,
            'Add Transaction',
            false,
            () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const AddTransactionScreen(),
              ),
            ),
          ),
          _menuItem(
            Icons.receipt_long,
            'Transactions',
            false,
            () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const HistoryScreen(),
              ),
            ),
          ),
          const Spacer(),
          const Text(
            'Track your money.\nSpend smarter.',
            style: TextStyle(color: Colors.grey, fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _menuItem(
    IconData icon,
    String title,
    bool selected,
    VoidCallback action,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Material(
        color: selected
            ? AppTheme.primary.withValues(alpha: 0.10)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          onTap: action,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(13),
            child: Row(
              children: [
                Icon(
                  icon,
                  color: selected ? AppTheme.primary : Colors.grey,
                ),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: TextStyle(
                    color: selected ? AppTheme.primary : Colors.black87,
                    fontWeight:
                        selected ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 19,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _balanceCard(double balance) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(25),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xFF6750A4),
            Color(0xFF9076D5),
          ],
        ),
        borderRadius: BorderRadius.circular(22),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Total Balance',
            style: TextStyle(color: Colors.white70),
          ),
          const SizedBox(height: 10),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              money(balance),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 34,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 15),
          const Row(
            children: [
              Icon(Icons.account_balance_wallet, color: Colors.white),
              SizedBox(width: 8),
              Text(
                'Your financial health at a glance',
                style: TextStyle(color: Colors.white),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _statCard(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(13),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 25),
            const SizedBox(height: 10),
            Text(
              title,
              style: const TextStyle(
                fontSize: 12,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 5),
            FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: Text(
                value,
                style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _chartCard({
    required String title,
    required String subtitle,
    required Widget child,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: const TextStyle(
                color: Colors.grey,
                fontSize: 12,
              ),
            ),
            const SizedBox(height: 20),
            child,
          ],
        ),
      ),
    );
  }

  Widget _expenseChart(Map<String, double> data) {
    final colors = [
      AppTheme.primary,
      AppTheme.income,
      AppTheme.expense,
      Colors.orange,
      Colors.blue,
      Colors.pink,
      Colors.teal,
      Colors.brown,
    ];

    final total = data.values.fold(0.0, (a, b) => a + b);
    final entries = data.entries.toList();

    return Column(
      children: [
        SizedBox(
          height: 190,
          child: PieChart(
            PieChartData(
              centerSpaceRadius: 48,
              sectionsSpace: 3,
              sections: List.generate(entries.length, (index) {
                final entry = entries[index];
                final percentage = entry.value / total * 100;

                return PieChartSectionData(
                  value: entry.value,
                  color: colors[index % colors.length],
                  title: '${percentage.toStringAsFixed(0)}%',
                  radius: 55,
                  titleStyle: const TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                );
              }),
            ),
          ),
        ),
        const SizedBox(height: 15),
        Wrap(
          spacing: 15,
          runSpacing: 10,
          children: List.generate(entries.length, (index) {
            return Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(
                    color: colors[index % colors.length],
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 5),
                Text(
                  entries[index].key,
                  style: const TextStyle(fontSize: 12),
                ),
              ],
            );
          }),
        ),
      ],
    );
  }

  Widget _cashFlowChart(List transactions) {
    final now = DateTime.now();

    final months = List.generate(6, (index) {
      return DateTime(now.year, now.month - 5 + index);
    });

    final incomeValues = <double>[];
    final expenseValues = <double>[];

    for (final month in months) {
      double income = 0;
      double expenses = 0;

      for (final t in transactions) {
        if (t.date.year == month.year &&
            t.date.month == month.month) {
          if (t.isIncome) {
            income += t.amount;
          } else {
            expenses += t.amount;
          }
        }
      }

      incomeValues.add(income);
      expenseValues.add(expenses);
    }

    final maximum = [
      ...incomeValues,
      ...expenseValues,
    ].fold(0.0, (a, b) => a > b ? a : b);

    if (maximum == 0) return _emptyChart();

    return Column(
      children: [
        SizedBox(
          height: 200,
          child: BarChart(
            BarChartData(
              maxY: maximum * 1.25,
              gridData: const FlGridData(show: true),
              borderData: FlBorderData(show: false),
              titlesData: const FlTitlesData(show: false),
              barGroups: List.generate(6, (index) {
                return BarChartGroupData(
                  x: index,
                  barsSpace: 5,
                  barRods: [
                    BarChartRodData(
                      toY: incomeValues[index],
                      color: AppTheme.income,
                      width: 10,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    BarChartRodData(
                      toY: expenseValues[index],
                      color: AppTheme.expense,
                      width: 10,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ],
                );
              }),
            ),
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 14,
          children: List.generate(6, (index) {
            return Text(
              DateFormat('MMM').format(months[index]),
              style: const TextStyle(
                fontSize: 11,
                color: Colors.grey,
              ),
            );
          }),
        ),
        const SizedBox(height: 15),
        const Wrap(
          spacing: 20,
          children: [
            _Legend(color: AppTheme.income, label: 'Income'),
            _Legend(color: AppTheme.expense, label: 'Expenses'),
          ],
        ),
      ],
    );
  }

  Widget _emptyChart() {
    return Container(
      height: 150,
      alignment: Alignment.center,
      child: const Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.insert_chart_outlined,
            size: 40,
            color: Colors.grey,
          ),
          SizedBox(height: 8),
          Text(
            'Add transactions to generate analytics.',
            style: TextStyle(color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _insightCard({
    required IconData icon,
    required Color color,
    required String title,
    required String description,
  }) {
    return Card(
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: color.withValues(alpha: 0.12),
          child: Icon(icon, color: color),
        ),
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(description),
      ),
    );
  }

  Widget _emptyTransactions(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(25),
        child: Center(
          child: Column(
            children: [
              const Icon(
                Icons.receipt_long_outlined,
                size: 42,
                color: Colors.grey,
              ),
              const SizedBox(height: 10),
              const Text(
                'No transactions yet',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const Text(
                'Add income or expenses to see your financial analytics.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 12),
              OutlinedButton.icon(
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const AddTransactionScreen(),
                  ),
                ),
                icon: const Icon(Icons.add),
                label: const Text('Add Transaction'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Legend extends StatelessWidget {
  final Color color;
  final String label;

  const _Legend({
    required this.color,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 6),
        Text(label, style: const TextStyle(fontSize: 12)),
      ],
    );
  }
}