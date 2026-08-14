import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/widgets/glass_card.dart';
import '../../../core/utils/validation_utils.dart';
import '../providers/profile_providers.dart';

class PersonalInfoForm extends ConsumerStatefulWidget {
  const PersonalInfoForm({super.key});

  @override
  ConsumerState<PersonalInfoForm> createState() => _PersonalInfoFormState();
}

class _PersonalInfoFormState extends ConsumerState<PersonalInfoForm> {
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    final formState = ref.watch(personalInfoFormProvider);
    final userProfile = ref.watch(userProfileProvider);

    return GlassCard(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.person, color: Colors.blue[400]),
                  const SizedBox(width: 12),
                  Text(
                    'Personal Information',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              
              // Name field
              TextFormField(
                initialValue: userProfile.name,
                decoration: InputDecoration(
                  labelText: 'Full Name',
                  hintText: 'Enter your full name',
                  prefixIcon: const Icon(Icons.person_outline),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: Colors.grey[900],
                ),
                onChanged: (value) {
                  ref.read(personalInfoFormProvider.notifier).updateName(value);
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Name is required';
                  }
                  if (value.length < 2) {
                    return 'Name must be at least 2 characters';
                  }
                  return null;
                },
              ),
              if (formState['nameError'] != null)
                Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(
                    formState['nameError']!,
                    style: TextStyle(
                      color: Colors.red[400],
                      fontSize: 12,
                    ),
                  ),
                ),
              const SizedBox(height: 16),
              
              // Email field
              TextFormField(
                initialValue: userProfile.email,
                decoration: InputDecoration(
                  labelText: 'Email Address',
                  hintText: 'Enter your email address',
                  prefixIcon: const Icon(Icons.email_outlined),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: Colors.grey[900],
                ),
                onChanged: (value) {
                  ref.read(personalInfoFormProvider.notifier).updateEmail(value);
                },
                validator: (value) => ValidationUtils.validateEmail(value),
              ),
              if (formState['emailError'] != null)
                Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(
                    formState['emailError']!,
                    style: TextStyle(
                      color: Colors.red[400],
                      fontSize: 12,
                    ),
                  ),
                ),
              const SizedBox(height: 24),
              
              // Save button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState?.validate() ?? false) {
                      final formData = ref.read(personalInfoFormProvider.notifier).getFormData();
                      ref.read(userProfileProvider.notifier).updatePersonalInfo(
                        name: formData['name']!,
                        email: formData['email']!,
                      );
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Personal information updated successfully'),
                          backgroundColor: Colors.green,
                        ),
                      );
                    }
                  },
                  child: const Text('Save Changes'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}