import 'package:flutter/material.dart';

class RecipeDetailPage extends StatelessWidget {
  final String title;
  final String content;

  const RecipeDetailPage({
    super.key,
    required this.title,
    required this.content,
  });

  List<String> _cleanLines() {
    return content
        .replaceAll('**', '')
        .replaceAll('*', '•')
        .split('\n')
        .map((line) => line.trim())
        .where((line) => line.isNotEmpty)
        .toList();
  }

  bool _isHeading(String line) {
    final lower = line.toLowerCase();
    return lower.contains('ingredients') ||
        lower.contains('steps') ||
        lower.contains('why') ||
        lower.contains('simple') ||
        lower.contains('instructions');
  }

  @override
  Widget build(BuildContext context) {
    final lines = _cleanLines();

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(18, 14, 18, 28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _TopBar(title: title),
              const SizedBox(height: 16),
              _HeroCard(title: title),
              const SizedBox(height: 20),
              const Text(
                'Full Recipe Details',
                style: TextStyle(
                  fontSize: 19,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFF111827),
                ),
              ),
              const SizedBox(height: 12),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: const Color(0xFFE5E7EB)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: lines.map((line) {
                    final heading = _isHeading(line);

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 11),
                      child: Text(
                        line,
                        style: TextStyle(
                          fontSize: heading ? 15 : 14,
                          height: 1.45,
                          fontWeight: heading
                              ? FontWeight.w900
                              : FontWeight.w500,
                          color: heading
                              ? const Color(0xFF7C3AED)
                              : const Color(0xFF374151),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: 16),
              const _TipCard(),
            ],
          ),
        ),
      ),
    );
  }
}

class _TopBar extends StatelessWidget {
  final String title;

  const _TopBar({required this.title});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back_rounded),
        ),
        Expanded(
          child: Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w900,
              color: Color(0xFF111827),
            ),
          ),
        ),
        Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: const Color(0xFFF3E8FF),
            borderRadius: BorderRadius.circular(16),
          ),
          child: const Icon(
            Icons.bookmark_border_rounded,
            color: Color(0xFF7C3AED),
          ),
        ),
      ],
    );
  }
}

class _HeroCard extends StatelessWidget {
  final String title;

  const _HeroCard({required this.title});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF7C3AED), Color(0xFFA855F7)],
        ),
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF7C3AED).withValues(alpha: 0.22),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.restaurant_menu_rounded,
            color: Colors.white,
            size: 34,
          ),
          const SizedBox(height: 16),
          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 25,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 12),
          const Row(
            children: [
              _HeroBadge(text: 'Quick'),
              SizedBox(width: 8),
              _HeroBadge(text: 'Easy'),
              SizedBox(width: 8),
              _HeroBadge(text: 'Waste Less'),
            ],
          ),
        ],
      ),
    );
  }
}

class _HeroBadge extends StatelessWidget {
  final String text;

  const _HeroBadge({required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(99),
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 11,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

class _TipCard extends StatelessWidget {
  const _TipCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFEFFDF5),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFFD1FAE5)),
      ),
      child: const Row(
        children: [
          Icon(Icons.eco_rounded, color: Color(0xFF10B981), size: 28),
          SizedBox(width: 12),
          Expanded(
            child: Text(
              'This recipe helps reduce waste by using inventory items before expiry.',
              style: TextStyle(
                color: Color(0xFF047857),
                fontSize: 13,
                height: 1.35,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
