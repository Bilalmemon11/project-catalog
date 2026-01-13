import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:smart_merchandiser/app/app_state.dart';
import 'package:smart_merchandiser/models/user_profile.dart';

class ProfileFormScreen extends StatefulWidget {
  const ProfileFormScreen({super.key, required this.user});

  final User user;

  @override
  State<ProfileFormScreen> createState() => _ProfileFormScreenState();
}

class _ProfileFormScreenState extends State<ProfileFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _storeNameController = TextEditingController();
  final _equityNumberController = TextEditingController();
  final _addressController = TextEditingController();
  final _cityController = TextEditingController();
  final _stateController = TextEditingController();
  final _zipController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  String _distributor = 'AWG';

  @override
  void dispose() {
    _storeNameController.dispose();
    _equityNumberController.dispose();
    _addressController.dispose();
    _cityController.dispose();
    _stateController.dispose();
    _zipController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _emailController.text = widget.user.email ?? '';
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    final profile = UserProfile(
      distributor: _distributor,
      storeName: _storeNameController.text.trim(),
      equityNumber: _equityNumberController.text.trim(),
      address: _addressController.text.trim(),
      city: _cityController.text.trim(),
      state: _stateController.text.trim(),
      zipCode: _zipController.text.trim(),
      email: _emailController.text.trim(),
      phoneNumber: _phoneController.text.trim(),
    );
    AppStateScope.of(context).updateProfile(profile);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Profile saved.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final twoColumn = width >= 900;
    final textTheme = Theme.of(context).textTheme;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Complete your profile'),
        actions: [
          TextButton.icon(
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              if (!mounted) return;
              AppStateScope.of(context).clearProfile();
            },
            icon: const Icon(Icons.logout),
            label: const Text('Sign out'),
          ),
        ],
      ),
      body: Align(
        alignment: Alignment.topCenter,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 960),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Before you can access the catalog, we need a few details.',
                    style: textTheme.titleMedium,
                  ),
                  const SizedBox(height: 20),
                  LayoutBuilder(
                    builder: (context, constraints) {
                      return Column(
                        children: [
                          _buildFieldGroup(
                            twoColumn,
                            [
                              _buildDistributorField(),
                              _buildTextField(
                                controller: _storeNameController,
                                label: 'Store name',
                                icon: Icons.storefront,
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          _buildFieldGroup(
                            twoColumn,
                            [
                              _buildTextField(
                                controller: _equityNumberController,
                                label: 'Equity/AWG number',
                                icon: Icons.confirmation_number_outlined,
                              ),
                              _buildTextField(
                                controller: _addressController,
                                label: 'Address',
                                icon: Icons.location_on_outlined,
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          _buildFieldGroup(
                            twoColumn,
                            [
                              _buildTextField(
                                controller: _cityController,
                                label: 'City',
                                icon: Icons.location_city_outlined,
                              ),
                              _buildTextField(
                                controller: _stateController,
                                label: 'State',
                                icon: Icons.map_outlined,
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          _buildFieldGroup(
                            twoColumn,
                            [
                              _buildTextField(
                                controller: _zipController,
                                label: 'Zip code',
                                icon: Icons.markunread_mailbox_outlined,
                                keyboardType: TextInputType.number,
                                validator: _zipValidator,
                              ),
                              _buildTextField(
                                controller: _emailController,
                                label: 'Contact email',
                                icon: Icons.email_outlined,
                                keyboardType: TextInputType.emailAddress,
                                validator: _emailValidator,
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          _buildFieldGroup(
                            twoColumn,
                            [
                              _buildTextField(
                                controller: _phoneController,
                                label: 'Phone number',
                                icon: Icons.phone_outlined,
                                keyboardType: TextInputType.phone,
                              ),
                              const SizedBox.shrink(),
                            ],
                          ),
                        ],
                      );
                    },
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: _submit,
                          child: const Text('Save and continue'),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Your information is stored locally for Milestone 1.',
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFieldGroup(bool twoColumn, List<Widget> fields) {
    if (twoColumn) {
      return Row(
        children: fields
            .map(
              (field) => Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: field,
                ),
              ),
            )
            .toList(),
      );
    }
    return Column(
      children: fields
          .where((field) => field is! SizedBox)
          .map(
            (field) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: field,
            ),
          )
          .toList(),
    );
  }

  Widget _buildDistributorField() {
    return DropdownButtonFormField<String>(
      value: _distributor,
      decoration: const InputDecoration(
        labelText: 'Distributor',
        prefixIcon: Icon(Icons.local_shipping_outlined),
      ),
      items: const [
        DropdownMenuItem(value: 'AWG', child: Text('AWG')),
        DropdownMenuItem(value: 'UNFI', child: Text('UNFI')),
        DropdownMenuItem(value: 'MDI', child: Text('MDI')),
        DropdownMenuItem(value: 'United Foods', child: Text('United Foods')),
      ],
      onChanged: (value) {
        if (value == null) return;
        setState(() {
          _distributor = value;
        });
      },
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
      ),
      validator: validator ?? _requiredValidator,
    );
  }

  String? _requiredValidator(String? value) {
    if ((value ?? '').trim().isEmpty) {
      return 'Required';
    }
    return null;
  }

  String? _zipValidator(String? value) {
    final trimmed = (value ?? '').trim();
    if (trimmed.isEmpty) {
      return 'Required';
    }
    if (trimmed.length < 5) {
      return 'Enter a valid zip code.';
    }
    return null;
  }

  String? _emailValidator(String? value) {
    final trimmed = (value ?? '').trim();
    if (trimmed.isEmpty) {
      return 'Required';
    }
    if (!trimmed.contains('@')) {
      return 'Enter a valid email.';
    }
    return null;
  }
}
