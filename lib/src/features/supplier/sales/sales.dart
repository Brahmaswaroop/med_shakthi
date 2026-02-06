import 'package:flutter/material.dart';

void main() {
  runApp(const SupplierSalesApp());
}

class SupplierSalesApp extends StatelessWidget {
  const SupplierSalesApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Supplier Sales Dashboard',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFFF5F7FA),
        colorScheme: ColorScheme.light(
          primary: const Color(0xFF16A3A6),
          secondary: const Color(0xFF16A3A6),
          surface: Colors.white,
        ),
        fontFamily: 'Roboto',
      ),
      home: const SupplierSalesDashboardPage(),
    );
  }
}

class SupplierSalesDashboardPage extends StatelessWidget {
  const SupplierSalesDashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: const _BottomNav(),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              _TopBar(),
              SizedBox(height: 16),
              _SalesSummaryHero(),
              SizedBox(height: 24),
              _SectionHeader(title: 'Sales Categories'),
              SizedBox(height: 12),
              _SalesCategoryRow(),
              SizedBox(height: 24),
              _SectionHeader(title: 'Key Sales Metrics'),
              SizedBox(height: 12),
              _KpiRow(),
              SizedBox(height: 24),
              _SectionHeader(title: 'Orders & Compliance'),
              SizedBox(height: 12),
              _OrdersComplianceRow(),
              SizedBox(height: 24),
              _ForecastAndInsightsCard(),
              SizedBox(height: 24),
              _CommunicationAndGamificationCard(),
              SizedBox(height: 24),
              _SalesDashboardComparisonCard(),
              SizedBox(height: 80),
            ],
          ),
        ),
      ),
    );
  }
}

/// TOP BAR – search + profile/cart style
class _TopBar extends StatelessWidget {
  const _TopBar();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          height: 44,
          width: 44,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(Icons.grid_view_rounded, color: Colors.black54),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Container(
            height: 44,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(22),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: const Row(
              children: [
                Icon(Icons.search, color: Colors.black38),
                SizedBox(width: 8),
                Text(
                  'Search sales analytics…',
                  style: TextStyle(color: Colors.black38),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 12),
        Container(
          height: 44,
          width: 44,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(22),
          ),
          child: const Icon(Icons.person_outline, color: Colors.black54),
        ),
      ],
    );
  }
}

/// HERO CARD – supplier sales summary + payouts
class _SalesSummaryHero extends StatelessWidget {
  const _SalesSummaryHero();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        gradient: const LinearGradient(
          colors: [Color(0xFF16A3A6), Color(0xFF0E8C91)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Supplier Sales Overview',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Monthly payout is ready.\nTrack sales, payouts, risk and compliance in one view.',
            style: TextStyle(color: Colors.white70, height: 1.3),
          ),
          const SizedBox(height: 14),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
              _HeroStat(label: 'This Month Sales', value: '₹ 8.9L'),
              _HeroStat(label: 'On‑time Delivery', value: '96%'),
              _HeroStat(label: 'Defect Rate', value: '1.2%'),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: const Color(0xFF16A3A6),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24),
                  ),
                ),
                onPressed: () {},
                child: const Text('View Payout Report'),
              ),
              const SizedBox(width: 12),
              const Text(
                '+14% vs last month',
                style: TextStyle(color: Colors.white70, fontSize: 13),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _HeroStat extends StatelessWidget {
  final String label;
  final String value;

  const _HeroStat({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w700,
            fontSize: 16,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: const TextStyle(color: Colors.white70, fontSize: 12),
        ),
      ],
    );
  }
}

/// SECTION HEADER
class _SectionHeader extends StatelessWidget {
  final String title;

  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w700,
      ),
    );
  }
}

/// SALES CATEGORIES – similar circles row
class _SalesCategoryRow extends StatelessWidget {
  const _SalesCategoryRow();

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: const [
        _CategoryItem(icon: Icons.shopping_bag_outlined, label: 'Total Sales'),
        _CategoryItem(icon: Icons.pending_actions_outlined, label: 'Pending'),
        _CategoryItem(icon: Icons.assignment_turned_in_outlined, label: 'Fulfilled'),
        _CategoryItem(icon: Icons.cancel_outlined, label: 'Rejected'),
      ],
    );
  }
}

class _CategoryItem extends StatelessWidget {
  final IconData icon;
  final String label;

  const _CategoryItem({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          height: 60,
          width: 60,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(30),
          ),
          child: Icon(icon, color: const Color(0xFF16A3A6)),
        ),
        const SizedBox(height: 6),
        Text(
          label,
          style: const TextStyle(fontSize: 13, color: Colors.black87),
        ),
      ],
    );
  }
}

/// KPI CARDS – sales + delivery + customer satisfaction + lead time
class _KpiRow extends StatelessWidget {
  const _KpiRow();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: const [
        _KpiPair(
          left: _KpiCard(
            title: 'Revenue',
            subtitle: 'This Month',
            value: '₹ 8.9L',
            change: '+14%',
            changePositive: true,
          ),
          right: _KpiCard(
            title: 'On‑time Delivery',
            subtitle: 'Last 30 days',
            value: '96%',
            change: '+3%',
            changePositive: true,
          ),
        ),
        SizedBox(height: 12),
        _KpiPair(
          left: _KpiCard(
            title: 'Defect Rate',
            subtitle: 'Quality score',
            value: '1.2%',
            change: '-0.4%',
            changePositive: true,
          ),
          right: _KpiCard(
            title: 'Customer Rating',
            subtitle: 'Avg. last 100 orders',
            value: '4.7★',
            change: '+0.2',
            changePositive: true,
          ),
        ),
      ],
    );
  }
}

class _KpiPair extends StatelessWidget {
  final Widget left;
  final Widget right;

  const _KpiPair({required this.left, required this.right});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: left),
        const SizedBox(width: 12),
        Expanded(child: right),
      ],
    );
  }
}

class _KpiCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final String value;
  final String change;
  final bool changePositive;

  const _KpiCard({
    required this.title,
    required this.subtitle,
    required this.value,
    required this.change,
    required this.changePositive,
  });

  @override
  Widget build(BuildContext context) {
    final Color chipBg =
        changePositive ? const Color(0xFFE0FFF3) : const Color(0xFFFFF2E0);
    final Color chipText =
        changePositive ? const Color(0xFF16A3A6) : const Color(0xFFD87528);

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style:
                const TextStyle(fontSize: 13, color: Colors.black54),
          ),
          const SizedBox(height: 2),
          Text(
            subtitle,
            style: const TextStyle(
              fontSize: 11,
              color: Colors.black38,
            ),
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                value,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: chipBg,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Text(
                  change,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: chipText,
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

/// ORDERS + COMPLIANCE / PROFILE
class _OrdersComplianceRow extends StatelessWidget {
  const _OrdersComplianceRow();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: const [
        Expanded(child: _OrdersCard()),
        SizedBox(width: 12),
        Expanded(child: _ProfileComplianceCard()),
      ],
    );
  }
}

class _OrdersCard extends StatelessWidget {
  const _OrdersCard();

  @override
  Widget build(BuildContext context) {
    return _CardWrapper(
      title: 'Order Management',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          _BulletItem(
              'Real‑time lifecycle: pending, fulfilled, delayed, cancelled.'),
          _BulletItem(
              'Accept / reject orders with mandatory reason tags.'),
          _BulletItem('Track SLA breaches and auto‑escalations.'),
        ],
      ),
    );
  }
}

class _ProfileComplianceCard extends StatelessWidget {
  const _ProfileComplianceCard();

  @override
  Widget build(BuildContext context) {
    return _CardWrapper(
      title: 'Profile & Compliance',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          _BulletItem('Store certifications, licenses & GST details.'),
          _BulletItem('Compliance status and risk score in one badge.'),
          _BulletItem('View full audit trail of policy or price changes.'),
        ],
      ),
    );
  }
}

/// FORECASTING & INSIGHTS
class _ForecastAndInsightsCard extends StatelessWidget {
  const _ForecastAndInsightsCard();

  @override
  Widget build(BuildContext context) {
    return _CardWrapper(
      title: 'Forecasting & Insights',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          _BulletItem('AI‑driven demand prediction by product & region.'),
          _BulletItem('Payout prediction based on current sales velocity.'),
          _BulletItem('Low‑stock and seasonal demand alerts.'),
        ],
      ),
    );
  }
}

/// COMMUNICATION + GAMIFICATION
class _CommunicationAndGamificationCard extends StatelessWidget {
  const _CommunicationAndGamificationCard();

  @override
  Widget build(BuildContext context) {
    return _CardWrapper(
      title: 'Collaboration & Engagement',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          _BulletTitle('Communication'),
          _BulletItem('In‑app chat with buyers and support.'),
          _BulletItem('Share invoices, proofs and documents in chat.'),
          _BulletItem('Instant notifications for disputes or delays.'),
          SizedBox(height: 10),
          _BulletTitle('Gamification'),
          _BulletItem(
              'Leaderboards for on‑time delivery and customer rating.'),
          _BulletItem('Badges and rewards for top performing suppliers.'),
        ],
      ),
    );
  }
}

/// COMPARISON TABLE – current vs industry leading
class _SalesDashboardComparisonCard extends StatelessWidget {
  const _SalesDashboardComparisonCard();

  @override
  Widget build(BuildContext context) {
    return _CardWrapper(
      title: 'Supplier Dashboard Comparison',
      child: Column(
        children: const [
          _ComparisonRow(
            feature: 'Sales Growth',
            current: 'Monthly payout only',
            industry: 'Growth trends, compliance & risk alerts',
          ),
          _ComparisonRow(
            feature: 'Performance Stats',
            current: 'Revenue & pending units',
            industry:
                'Delivery %, lead time, defect rate, customer ratings',
          ),
          _ComparisonRow(
            feature: 'Order Management',
            current: 'Basic status view',
            industry:
                'Real‑time lifecycle, accept/reject, SLA tracking',
          ),
          _ComparisonRow(
            feature: 'Financials',
            current: 'Revenue & payout view',
            industry:
                'Invoices, tax compliance, multi‑currency support',
          ),
          _ComparisonRow(
            feature: 'Communication',
            current: 'No in‑app communication',
            industry:
                'Chat, document sharing, dispute resolution',
          ),
          _ComparisonRow(
            feature: 'Forecasting',
            current: 'No predictions',
            industry:
                'AI demand & payout prediction',
          ),
          _ComparisonRow(
            feature: 'UI/UX',
            current: 'Simple navigation',
            industry:
                'Custom dashboards, filters, role‑based views',
          ),
        ],
      ),
    );
  }
}

class _ComparisonRow extends StatelessWidget {
  final String feature;
  final String current;
  final String industry;

  const _ComparisonRow({
    required this.feature,
    required this.current,
    required this.industry,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10),
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Color(0xFFE2E6EC), width: 0.5),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 3,
            child: Text(
              feature,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            flex: 3,
            child: Text(
              current,
              style: const TextStyle(fontSize: 12, color: Colors.black54),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            flex: 4,
            child: Text(
              industry,
              style: const TextStyle(fontSize: 12, color: Colors.black87),
            ),
          ),
        ],
      ),
    );
  }
}

/// GENERIC CARD WRAPPER
class _CardWrapper extends StatelessWidget {
  final String title;
  final Widget child;

  const _CardWrapper({required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }
}

/// BULLETS
class _BulletTitle extends StatelessWidget {
  final String text;
  const _BulletTitle(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        fontWeight: FontWeight.w700,
        fontSize: 13,
      ),
    );
  }
}

class _BulletItem extends StatelessWidget {
  final String text;
  const _BulletItem(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, top: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('• ', style: TextStyle(fontSize: 13, height: 1.4)),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 13,
                color: Colors.black87,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// BOTTOM NAV – supplier side tabs
class _BottomNav extends StatefulWidget {
  const _BottomNav();

  @override
  State<_BottomNav> createState() => _BottomNavState();
}

class _BottomNavState extends State<_BottomNav> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    return NavigationBar(
      selectedIndex: _index,
      onDestinationSelected: (i) => setState(() => _index = i),
      destinations: const [
        NavigationDestination(
          icon: Icon(Icons.home_outlined),
          selectedIcon: Icon(Icons.home),
          label: 'Dashboard',
        ),
        NavigationDestination(
          icon: Icon(Icons.receipt_long_outlined),
          selectedIcon: Icon(Icons.receipt_long),
          label: 'Orders',
        ),
        NavigationDestination(
          icon: Icon(Icons.bar_chart_outlined),
          selectedIcon: Icon(Icons.bar_chart),
          label: 'Analytics',
        ),
        NavigationDestination(
          icon: Icon(Icons.account_balance_wallet_outlined),
          selectedIcon: Icon(Icons.account_balance_wallet),
          label: 'Payouts',
        ),
        NavigationDestination(
          icon: Icon(Icons.chat_bubble_outline),
          selectedIcon: Icon(Icons.chat_bubble),
          label: 'Chat',
        ),
      ],
    );
  }
}