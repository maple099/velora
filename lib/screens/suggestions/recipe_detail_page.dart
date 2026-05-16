import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'logic_suggestions/cook_now_deduction_service.dart';

class RecipeDetailPage extends StatefulWidget {
  final String title;
  final List<String> ingredients;
  final List<String> steps;
  final List<String> nearExpiryIngredients;
  final String whyRecommended;

  const RecipeDetailPage({
    super.key,
    required this.title,
    required this.ingredients,
    required this.steps,
    required this.nearExpiryIngredients,
    required this.whyRecommended,
  });

  @override
  State<RecipeDetailPage> createState() => _RecipeDetailPageState();
}

class _RecipeDetailPageState extends State<RecipeDetailPage> {
  final CookNowDeductionService _deductionService = CookNowDeductionService();

  bool _isCooking = false;

  bool _isNearExpiry(String ingredient) {
    return widget.nearExpiryIngredients.any(
      (item) => item.toLowerCase().trim() == ingredient.toLowerCase().trim(),
    );
  }

  Future<void> _handleCookNow() async {
    if (_isCooking) return;

    setState(() => _isCooking = true);

    try {
      User? user = FirebaseAuth.instance.currentUser;

      user ??= await FirebaseAuth.instance
          .authStateChanges()
          .firstWhere((authUser) => authUser != null, orElse: () => null)
          .timeout(const Duration(seconds: 3), onTimeout: () => null);

      if (!mounted) return;

      if (user == null) {
        setState(() => _isCooking = false);

        _showSnackBar(
          message:
              'Login session not detected. Please reopen app and login again.',
          isError: true,
        );
        return;
      }

      final result = await _deductionService
          .deductRecipeIngredients(
            userId: user.uid,
            recipeTitle: widget.title,
            ingredients: widget.ingredients,
          )
          .timeout(
            const Duration(seconds: 10),
            onTimeout: () {
              return const CookNowDeductionResult(
                success: false,
                message: 'Inventory update took too long. Please try again.',
                usedItems: [],
                skippedItems: [],
              );
            },
          );

      if (!mounted) return;

      setState(() => _isCooking = false);

      _showResultDialog(result);
    } catch (e) {
      if (!mounted) return;

      setState(() => _isCooking = false);

      _showSnackBar(
        message: 'Failed to use Cook Now. Please try again.',
        isError: true,
      );
    }
  }

  void _showSnackBar({required String message, required bool isError}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: isError
            ? const Color(0xFFEF4444)
            : const Color(0xFF10B981),
        content: Text(
          message,
          style: const TextStyle(fontWeight: FontWeight.w700),
        ),
      ),
    );
  }

  void _showResultDialog(CookNowDeductionResult result) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          title: Text(
            result.success ? 'Inventory Updated' : 'Cook Now Failed',
            style: const TextStyle(fontWeight: FontWeight.w900),
          ),
          content: SingleChildScrollView(
            child: Text(
              _buildResultMessage(result),
              style: const TextStyle(
                color: Color(0xFF374151),
                height: 1.45,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);

                if (result.success) {
                  Navigator.pop(context, true);
                }
              },
              child: const Text(
                'OK',
                style: TextStyle(fontWeight: FontWeight.w900),
              ),
            ),
          ],
        );
      },
    );
  }

  String _buildResultMessage(CookNowDeductionResult result) {
    final buffer = StringBuffer();

    buffer.writeln(result.message);

    if (result.usedItems.isNotEmpty) {
      buffer.writeln('');
      buffer.writeln('Used items:');

      for (final item in result.usedItems) {
        buffer.writeln('• $item');
      }
    }

    if (result.skippedItems.isNotEmpty) {
      buffer.writeln('');
      buffer.writeln('Skipped items:');

      for (final item in result.skippedItems) {
        buffer.writeln('• $item');
      }
    }

    return buffer.toString().trim();
  }

  @override
  Widget build(BuildContext context) {
    final isSmall = MediaQuery.of(context).size.width < 370;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF8FAFC),
        elevation: 0,
        iconTheme: const IconThemeData(color: Color(0xFF111827)),
        title: const Text(
          'Recipe Details',
          style: TextStyle(
            color: Color(0xFF111827),
            fontWeight: FontWeight.w900,
          ),
        ),
      ),
      body: ListView(
        padding: EdgeInsets.fromLTRB(
          isSmall ? 16 : 20,
          8,
          isSmall ? 16 : 20,
          110,
        ),
        children: [
          _HeroCard(title: widget.title, isSmall: isSmall),
          const SizedBox(height: 18),
          _SectionCard(
            title: 'Ingredients',
            icon: Icons.restaurant_menu_rounded,
            child: Column(
              children: widget.ingredients.map((ingredient) {
                return _IngredientRow(
                  name: ingredient,
                  isNearExpiry: _isNearExpiry(ingredient),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 18),
          _SectionCard(
            title: 'Cooking Steps',
            icon: Icons.list_alt_rounded,
            child: Column(
              children: List.generate(widget.steps.length, (index) {
                return _StepRow(number: index + 1, text: widget.steps[index]);
              }),
            ),
          ),
          const SizedBox(height: 18),
          _WhyCard(text: widget.whyRecommended),
        ],
      ),
      bottomNavigationBar: _CookNowBottomBar(
        isCooking: _isCooking,
        onPressed: _handleCookNow,
      ),
    );
  }
}

class _CookNowBottomBar extends StatelessWidget {
  final bool isCooking;
  final VoidCallback onPressed;

  const _CookNowBottomBar({required this.isCooking, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 24),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: const Color(0xFFE5E7EB)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 20,
            offset: const Offset(0, -8),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 54,
          child: ElevatedButton.icon(
            onPressed: isCooking ? null : onPressed,
            icon: isCooking
                ? const SizedBox(
                    height: 19,
                    width: 19,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.3,
                      color: Colors.white,
                    ),
                  )
                : const Icon(Icons.restaurant_rounded),
            label: Text(
              isCooking ? 'Updating Inventory...' : 'Cook Now',
              style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 15),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF7C3AED),
              foregroundColor: Colors.white,
              disabledBackgroundColor: const Color(0xFFC4B5FD),
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _HeroCard extends StatelessWidget {
  final String title;
  final bool isSmall;

  const _HeroCard({required this.title, required this.isSmall});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(isSmall ? 18 : 22),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF7C3AED), Color(0xFFA855F7)],
        ),
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF7C3AED).withValues(alpha: 0.24),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: isSmall ? 58 : 66,
            width: isSmall ? 58 : 66,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.18),
              borderRadius: BorderRadius.circular(22),
            ),
            child: const Icon(
              Icons.auto_awesome_rounded,
              color: Colors.white,
              size: 32,
            ),
          ),
          const SizedBox(height: 18),
          Text(
            title,
            style: TextStyle(
              color: Colors.white,
              fontSize: isSmall ? 22 : 26,
              fontWeight: FontWeight.w900,
              height: 1.15,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'AI recipe suggestion based on your inventory',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.86),
              fontSize: isSmall ? 12 : 13,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Widget child;

  const _SectionCard({
    required this.title,
    required this.icon,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFE5E7EB)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 16,
            offset: const Offset(0, 7),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                height: 38,
                width: 38,
                decoration: BoxDecoration(
                  color: const Color(0xFFF3E8FF),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(icon, color: const Color(0xFF7C3AED), size: 21),
              ),
              const SizedBox(width: 12),
              Text(
                title,
                style: const TextStyle(
                  color: Color(0xFF111827),
                  fontSize: 17,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          child,
        ],
      ),
    );
  }
}

class _IngredientRow extends StatelessWidget {
  final String name;
  final bool isNearExpiry;

  const _IngredientRow({required this.name, required this.isNearExpiry});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: isNearExpiry ? const Color(0xFFFFFBEB) : const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isNearExpiry
              ? const Color(0xFFFDE68A)
              : const Color(0xFFE5E7EB),
        ),
      ),
      child: Row(
        children: [
          Icon(
            isNearExpiry
                ? Icons.warning_amber_rounded
                : Icons.check_circle_rounded,
            color: isNearExpiry
                ? const Color(0xFFF59E0B)
                : const Color(0xFF10B981),
            size: 21,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              name,
              style: const TextStyle(
                color: Color(0xFF111827),
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          if (isNearExpiry)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
              decoration: BoxDecoration(
                color: const Color(0xFFFFF3C4),
                borderRadius: BorderRadius.circular(999),
              ),
              child: const Text(
                'Near Expiry ⚠️',
                style: TextStyle(
                  fontSize: 11,
                  color: Color(0xFFB45309),
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _StepRow extends StatelessWidget {
  final int number;
  final String text;

  const _StepRow({required this.number, required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 13),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 30,
            width: 30,
            decoration: BoxDecoration(
              color: const Color(0xFF7C3AED),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Center(
              child: Text(
                number.toString(),
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                color: Color(0xFF374151),
                fontWeight: FontWeight.w600,
                height: 1.45,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _WhyCard extends StatelessWidget {
  final String text;

  const _WhyCard({required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFFECFDF5),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFA7F3D0)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.lightbulb_rounded, color: Color(0xFF10B981)),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                color: Color(0xFF065F46),
                fontWeight: FontWeight.w700,
                height: 1.45,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
