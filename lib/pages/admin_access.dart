import 'package:flutter/material.dart';

import '../core/app_theme.dart';
import '../core/aura_bento.dart';
import '../widgets/glass_surface.dart';
import 'admin_page.dart';

/// Change this value to use a different Admin Control password.
const String adminControlPassword = 'furqan123';

Future<void> openProtectedAdmin(BuildContext context) async {
  final allowed = await showGeneralDialog<bool>(
    context: context,
    barrierDismissible: true,
    barrierLabel: 'Close admin password dialog',
    barrierColor: Colors.black.withAlpha(64),
    transitionDuration: const Duration(milliseconds: 560),
    pageBuilder: (context, animation, secondaryAnimation) {
      return const _AdminPasswordDialog();
    },
    transitionBuilder: (context, animation, secondaryAnimation, child) {
      final curved = CurvedAnimation(
        parent: animation,
        curve: const Cubic(0.22, 1, 0.36, 1),
      );
      return FadeTransition(
        opacity: curved,
        child: ScaleTransition(
          scale: Tween<double>(begin: 0.94, end: 1).animate(curved),
          child: SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0, 0.04),
              end: Offset.zero,
            ).animate(curved),
            child: child,
          ),
        ),
      );
    },
  );

  if (allowed == true && context.mounted) {
    await Navigator.of(context).push(
      PremiumPageRoute<void>(page: const AdminPage()),
    );
  }
}

class _AdminPasswordDialog extends StatefulWidget {
  const _AdminPasswordDialog();

  @override
  State<_AdminPasswordDialog> createState() => _AdminPasswordDialogState();
}

class _AdminPasswordDialogState extends State<_AdminPasswordDialog> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  bool _obscure = true;
  String? _error;

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _submit() {
    if (_controller.text == adminControlPassword) {
      Navigator.of(context).pop(true);
      return;
    }

    setState(() {
      _error = 'Incorrect password. Please try again.';
    });
    _controller.clear();
    _focusNode.requestFocus();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(18),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 500),
            child: Material(
              color: Colors.transparent,
              child: GlassSurface(
                radius: AuraBento.radiusXl - 4,
                padding: const EdgeInsets.all(AuraBento.space6 + 2),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Container(
                          width: 52,
                          height: 52,
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: AuraBento.accentDarkAction,
                          ),
                          child: const Icon(
                            Icons.lock_outline_rounded,
                            color: AuraBento.textInverted,
                          ),
                        ),
                        const SizedBox(width: AuraBento.space4),
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Text(
                                'Admin Control',
                                style: TextStyle(
                                  fontFamily: AuraBento.fontSerif,
                                  color: AuraBento.textPrimary,
                                  fontSize: 28,
                                  letterSpacing: -0.3,
                                ),
                              ),
                              SizedBox(height: 6),
                              Text(
                                'Enter the password to manage live projects and screenshots.',
                                style: TextStyle(
                                  color: AuraBento.textSecondary,
                                  height: 1.5,
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: AuraBento.space2),
                        AuraCircularToken(
                          icon: Icons.close_rounded,
                          variant: AuraCircularTokenVariant.pureWhite,
                          tooltip: 'Close',
                          onTap: () => Navigator.of(context).pop(false),
                        ),
                      ],
                    ),
                    const SizedBox(height: AuraBento.space6),
                    TextField(
                      controller: _controller,
                      focusNode: _focusNode,
                      autofocus: true,
                      obscureText: _obscure,
                      textInputAction: TextInputAction.done,
                      onSubmitted: (_) => _submit(),
                      onChanged: (_) {
                        if (_error != null) setState(() => _error = null);
                      },
                      decoration: InputDecoration(
                        labelText: 'Admin password',
                        hintText: 'Enter password',
                        prefixIcon: const Icon(Icons.password_rounded),
                        suffixIcon: IconButton(
                          tooltip: _obscure ? 'Show password' : 'Hide password',
                          onPressed: () => setState(() => _obscure = !_obscure),
                          icon: Icon(
                            _obscure
                                ? Icons.visibility_outlined
                                : Icons.visibility_off_outlined,
                          ),
                        ),
                      ),
                    ),
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 360),
                      switchInCurve: const Cubic(0.22, 1, 0.36, 1),
                      child: _error == null
                          ? const SizedBox(height: AuraBento.space3 + 2)
                          : Padding(
                              key: ValueKey<String>(_error!),
                              padding:
                                  const EdgeInsets.only(top: AuraBento.space3),
                              child: Text(
                                _error!,
                                style: const TextStyle(
                                  color: AppColors.danger,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                    ),
                    const SizedBox(height: AuraBento.space2),
                    SizedBox(
                      width: double.infinity,
                      child: PremiumButton(
                        label: 'Unlock Admin',
                        icon: Icons.arrow_forward_rounded,
                        primary: true,
                        onPressed: _submit,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
