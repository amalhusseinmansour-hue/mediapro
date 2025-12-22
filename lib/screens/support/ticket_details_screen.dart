import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/constants/app_colors.dart';
import '../../models/support_ticket_model.dart';
import '../../services/support_service.dart';
import 'package:intl/intl.dart';

class TicketDetailsScreen extends StatelessWidget {
  final SupportTicketModel ticket;

  const TicketDetailsScreen({super.key, required this.ticket});

  @override
  Widget build(BuildContext context) {
    final SupportService supportService = Get.find<SupportService>();

    return Scaffold(
      backgroundColor: AppColors.darkBg,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: ShaderMask(
          shaderCallback: (bounds) =>
              AppColors.cyanPurpleGradient.createShader(bounds),
          child: const Text(
            'تفاصيل التذكرة',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.neonCyan),
          onPressed: () => Get.back(),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          _buildTicketHeader(ticket),
          const SizedBox(height: 24),
          _buildTicketInfo(ticket),
          const SizedBox(height: 24),
          _buildDescriptionSection(ticket),
          if (ticket.response != null) ...[
            const SizedBox(height: 24),
            _buildResponseSection(ticket),
          ],
          const SizedBox(height: 24),
          _buildStatusActions(ticket, supportService),
        ],
      ),
    );
  }

  Widget _buildTicketHeader(SupportTicketModel ticket) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: AppColors.cyanPurpleGradient,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  ticket.statusText,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
              const Spacer(),
              Text(
                '#${ticket.id.substring(0, 8)}',
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            ticket.subject,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTicketInfo(SupportTicketModel ticket) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.darkCard,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.neonCyan.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          _buildInfoRow(
            icon: Icons.category_rounded,
            label: 'الفئة',
            value: ticket.categoryText,
            color: AppColors.neonCyan,
          ),
          const SizedBox(height: 16),
          _buildInfoRow(
            icon: Icons.priority_high_rounded,
            label: 'الأولوية',
            value: ticket.priorityText,
            color: _getPriorityColor(ticket.priority),
          ),
          const SizedBox(height: 16),
          _buildInfoRow(
            icon: Icons.access_time_rounded,
            label: 'تاريخ الإنشاء',
            value: DateFormat('yyyy/MM/dd - HH:mm').format(ticket.createdAt),
            color: AppColors.neonPurple,
          ),
          if (ticket.updatedAt != null) ...[
            const SizedBox(height: 16),
            _buildInfoRow(
              icon: Icons.update_rounded,
              label: 'آخر تحديث',
              value: DateFormat('yyyy/MM/dd - HH:mm').format(ticket.updatedAt!),
              color: AppColors.neonMagenta,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDescriptionSection(SupportTicketModel ticket) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.neonCyan.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.description_rounded,
                color: AppColors.neonCyan,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            const Text(
              'الوصف',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(20),
          width: double.infinity,
          decoration: BoxDecoration(
            color: AppColors.darkCard,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: AppColors.neonCyan.withValues(alpha: 0.3),
              width: 1,
            ),
          ),
          child: Text(
            ticket.description,
            style: const TextStyle(
              fontSize: 15,
              color: AppColors.textLight,
              height: 1.6,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildResponseSection(SupportTicketModel ticket) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFF00E676).withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.support_agent_rounded,
                color: Color(0xFF00E676),
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            const Text(
              'رد الدعم الفني',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(20),
          width: double.infinity,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                const Color(0xFF00E676).withValues(alpha: 0.1),
                const Color(0xFF00E676).withValues(alpha: 0.05),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: const Color(0xFF00E676).withValues(alpha: 0.3),
              width: 1,
            ),
          ),
          child: Text(
            ticket.response!,
            style: const TextStyle(
              fontSize: 15,
              color: Colors.white,
              height: 1.6,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStatusActions(
    SupportTicketModel ticket,
    SupportService supportService,
  ) {
    if (ticket.status == TicketStatus.resolved || ticket.status == TicketStatus.closed) {
      return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: const Color(0xFF00E676).withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: const Color(0xFF00E676).withValues(alpha: 0.3),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            const Icon(
              Icons.check_circle_rounded,
              color: Color(0xFF00E676),
              size: 24,
            ),
            const SizedBox(width: 12),
            const Expanded(
              child: Text(
                'تم حل هذه التذكرة',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF00E676),
                ),
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.darkCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.neonCyan.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              const Icon(
                Icons.info_rounded,
                color: AppColors.neonCyan,
                size: 20,
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  'يتم العمل على تذكرتك',
                  style: TextStyle(
                    fontSize: 15,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            'سيتم الرد عليك خلال 24-48 ساعة',
            style: TextStyle(
              fontSize: 13,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Color _getPriorityColor(TicketPriority priority) {
    switch (priority) {
      case TicketPriority.low:
        return const Color(0xFF00E676);
      case TicketPriority.medium:
        return AppColors.neonCyan;
      case TicketPriority.high:
        return const Color(0xFFFF9800);
      case TicketPriority.urgent:
        return const Color(0xFFFF5252);
    }
  }
}
