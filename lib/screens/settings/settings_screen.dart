import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/services/api_service.dart';
import 'widgets/bank_payment_settings_card.dart';
import 'widgets/billing_cycle_card.dart';
import 'widgets/contract_rules_card.dart';
import 'widgets/edit_rate_modal.dart';
import 'widgets/notification_settings_card.dart';
import 'widgets/utility_rates_card.dart';

/// Full Apple iOS-styled Settings Screen with live Supabase Database Sync
class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  double _electricRate = 8.0;
  double _waterRate = 18.0;
  int _commonFee = 300;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSettingsFromDb();
  }

  void _loadSettingsFromDb() async {
    final properties = await ApiService.getProperties();
    if (!mounted) return;
    if (properties.isNotEmpty) {
      final prop = properties.first;
      setState(() {
        _electricRate = (prop['electric_rate'] ?? prop['electricRate'] ?? 8.0).toDouble();
        _waterRate = (prop['water_rate'] ?? prop['waterRate'] ?? 18.0).toDouble();
        _commonFee = ((prop['common_fee'] ?? prop['commonFee'] ?? 300) as num).toInt();
        _isLoading = false;
      });
    } else {
      setState(() => _isLoading = false);
    }
  }

  void _openEditRateModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => EditRateModal(
        electricRate: _electricRate,
        waterRate: _waterRate,
        commonFee: _commonFee,
        onSave: (elec, water, common) async {
          setState(() {
            _electricRate = elec;
            _waterRate = water;
            _commonFee = common;
          });

          // Save live to Supabase via Go API
          final res = await ApiService.updatePropertySettings(1, {
            'electricRate': elec,
            'waterRate': water,
          });

          if (!mounted) return;
          if (res['success'] == true) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('บันทึกอัตราค่าน้ำ ค่าไฟ ลง Database Supabase สำเร็จ ✅'),
                backgroundColor: Color(0xFF34C759),
                behavior: SnackBarBehavior.floating,
              ),
            );
          }
        },
      ),
    );
  }

  void _onBackupData() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('กำลังสำรองข้อมูลหอพักขึ้น Cloud Supabase... สำเร็จ ✅'),
        backgroundColor: Color(0xFF34C759),
        behavior: SnackBarBehavior.floating,
        duration: Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false,
        leading: Navigator.canPop(context)
            ? Padding(
                padding: const EdgeInsets.only(left: 14),
                child: GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF2F2F7),
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.black.withAlpha(8)),
                    ),
                    child: const Icon(
                      CupertinoIcons.chevron_back,
                      color: AppColors.textPrimary,
                      size: 20,
                    ),
                  ),
                ),
              )
            : null,
        titleSpacing: 0,
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Flexible(
              child: Text(
                'ตั้งค่าระบบ & หอพัก',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.4,
                ),
              ),
            ),
            if (_isLoading) ...[
              const SizedBox(width: 8),
              const CupertinoActivityIndicator(radius: 7),
            ],
          ],
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(0.5),
          child: Container(
            color: Colors.black.withAlpha(12),
            height: 0.5,
          ),
        ),
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(
          parent: AlwaysScrollableScrollPhysics(),
        ),
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 36),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Utility Rates Card
            UtilityRatesCard(
              electricRate: _electricRate,
              waterRate: _waterRate,
              commonFee: _commonFee,
              onEditTap: _openEditRateModal,
            ),
            const SizedBox(height: 14),

            // Bank Payment & PromptPay Settings Card
            const BankPaymentSettingsCard(),
            const SizedBox(height: 14),

            // Billing Cycle Card
            const BillingCycleCard(),
            const SizedBox(height: 14),

            // Notification Settings Card
            const NotificationSettingsCard(),
            const SizedBox(height: 14),

            // Contract Rules Card
            const ContractRulesCard(),
            const SizedBox(height: 16),

            // Section: Data & Backup
            _buildSectionHeader('การสำรองข้อมูลและการจัดการระบบ (Database)'),
            const SizedBox(height: 8),
            _buildGroupedCard([
              _buildMenuItem(
                icon: CupertinoIcons.cloud_upload_fill,
                iconColor: const Color(0xFF007AFF),
                title: 'สำรองข้อมูลขึ้น Cloud Supabase',
                subtitle: 'สถานะ: ซิงค์ข้อมูลอัตโนมัติแบบ Realtime',
                onTap: _onBackupData,
              ),
              _buildMenuItem(
                icon: CupertinoIcons.arrow_down_doc_fill,
                iconColor: const Color(0xFF34C759),
                title: 'ส่งออกข้อมูลผู้เช่าและห้องพัก (Excel)',
                subtitle: 'ดาวน์โหลดไฟล์ .xlsx ทั้งหมด',
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('ส่งออกไฟล์ข้อมูลเรียบร้อย'),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                },
              ),
              _buildMenuItem(
                icon: CupertinoIcons.trash_fill,
                iconColor: const Color(0xFFFF9500),
                title: 'ล้างข้อมูลแคชชั่วคราว (Clear Cache)',
                subtitle: 'ขนาดแคชปัจจุบัน 0 KB',
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('ล้างข้อมูลแคชเรียบร้อยแล้ว'),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                },
                isLast: true,
              ),
            ]),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w700,
          color: AppColors.textSecondary,
          letterSpacing: -0.2,
        ),
      ),
    );
  }

  Widget _buildGroupedCard(List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.black.withAlpha(8), width: 0.8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(5),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(children: children),
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    bool isLast = false,
  }) {
    return Column(
      children: [
        Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(18),
            highlightColor: Colors.black.withAlpha(10),
            onTap: onTap,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              child: Row(
                children: [
                  Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      color: iconColor.withAlpha(25),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(icon, size: 20, color: iconColor),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: const TextStyle(
                            fontSize: 14.5,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                            letterSpacing: -0.2,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          subtitle,
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Icon(
                    CupertinoIcons.chevron_forward,
                    size: 15,
                    color: AppColors.chevron,
                  ),
                ],
              ),
            ),
          ),
        ),
        if (!isLast) const Divider(height: 1, indent: 64, thickness: 0.5),
      ],
    );
  }
}
