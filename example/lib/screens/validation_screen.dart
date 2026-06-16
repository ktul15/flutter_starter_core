import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_starter_core/flutter_starter_core.dart';

import '../cubits/validation_cubit.dart';

/// Demonstrates every [Validators] rule and [Validators.compose].
class ValidationScreen extends StatelessWidget {
  const ValidationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => ValidationCubit(),
      child: const _ValidationBody(),
    );
  }
}

class _ValidationBody extends StatefulWidget {
  const _ValidationBody();

  @override
  State<_ValidationBody> createState() => _ValidationBodyState();
}

class _ValidationBodyState extends State<_ValidationBody> {
  final _formKey = GlobalKey<FormState>();
  final _required = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController(text: 'pass');
  final _confirm = TextEditingController();
  final _min = TextEditingController();
  final _max = TextEditingController();

  @override
  void dispose() {
    _required.dispose();
    _email.dispose();
    _password.dispose();
    _confirm.dispose();
    _min.dispose();
    _max.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ValidationCubit, ValidationState>(
      builder: (ctx, state) => Scaffold(
        appBar: AppBar(title: const Text('Validation')),
        body: Form(
          key: _formKey,
          autovalidateMode: state.autovalidate
              ? AutovalidateMode.onUserInteraction
              : AutovalidateMode.disabled,
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // required()
              _Rule('Validators.required()'),
              AppTextField(
                controller: _required,
                label: 'Required field',
                prefixIcon: Icons.edit_outlined,
                validator:
                    Validators.required('This field is required'),
              ),

              const SizedBox(height: 16),

              // email()
              _Rule('Validators.email()'),
              AppTextField(
                controller: _email,
                label: 'Email',
                prefixIcon: Icons.email_outlined,
                keyboardType: TextInputType.emailAddress,
                validator: Validators.compose([
                  Validators.required(),
                  Validators.email(),
                ]),
              ),

              const SizedBox(height: 16),

              // password()
              _Rule(
                'Validators.password() — min 8 chars, requires letter + digit',
              ),
              PasswordField(
                controller: _password,
                validator: Validators.password(),
              ),

              const SizedBox(height: 16),

              // match()
              _Rule('Validators.match() — must equal password field above'),
              PasswordField(
                controller: _confirm,
                validator: Validators.match(
                  () => _password.text,
                  'Passwords do not match',
                ),
              ),

              const SizedBox(height: 16),

              // minLength()
              _Rule('Validators.minLength(3)'),
              AppTextField(
                controller: _min,
                label: 'Min 3 characters',
                prefixIcon: Icons.short_text,
                validator: Validators.compose([
                  Validators.required(),
                  Validators.minLength(3),
                ]),
              ),

              const SizedBox(height: 16),

              // maxLength()
              _Rule('Validators.maxLength(10)'),
              AppTextField(
                controller: _max,
                label: 'Max 10 characters',
                prefixIcon: Icons.text_fields,
                validator: Validators.maxLength(
                  10,
                  'Keep it under 10 chars',
                ),
              ),

              const SizedBox(height: 24),

              PrimaryButton(
                label: 'Validate all',
                onPressed: () {
                  ctx.read<ValidationCubit>().enableAutovalidate();
                  if (_formKey.currentState!.validate()) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('All fields valid!')),
                    );
                  }
                },
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}

class _Rule extends StatelessWidget {
  const _Rule(this.label);
  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
              fontFamily: 'monospace',
              color: Theme.of(context).colorScheme.primary,
            ),
      ),
    );
  }
}
