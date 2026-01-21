import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../data/models/models.dart';
import '../../../checkout/presentation/widgets/modern_address_picker.dart';
import '../../../checkout/providers/checkout_provider.dart';

@RoutePage()
class AddressesScreen extends ConsumerWidget {
  const AddressesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final addressesAsync = ref.watch(userAddressesProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('My Addresses')),
      body: addressesAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                LucideIcons.circleAlert,
                size: 48,
                color: context.colors.error,
              ),
              const SizedBox(height: 16),
              Text(
                'Failed to load addresses',
                style: TextStyle(color: context.colors.textSecondary),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => ref.invalidate(userAddressesProvider),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
        data: (addresses) {
          if (addresses.isEmpty) {
            return _buildEmptyState(context);
          }
          return _buildAddressList(context, ref, addresses);
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddAddressSheet(context, ref),
        icon: const Icon(LucideIcons.plus),
        label: const Text('Add Address'),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: context.colors.primary.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                LucideIcons.mapPinOff,
                size: 64,
                color: context.colors.primary,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'No addresses yet',
              style: context.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Save your delivery addresses here for faster checkout',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: context.colors.textSecondary,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 32),
            // Empty state illustration hints
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _EmptyStateHint(icon: LucideIcons.house, label: 'Home'),
                const SizedBox(width: 16),
                _EmptyStateHint(icon: LucideIcons.briefcase, label: 'Work'),
                const SizedBox(width: 16),
                _EmptyStateHint(icon: LucideIcons.mapPin, label: 'Other'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAddressList(
    BuildContext context,
    WidgetRef ref,
    List<Address> addresses,
  ) {
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
      itemCount: addresses.length,
      itemBuilder: (context, index) {
        final address = addresses[index];
        return _AddressCard(
          address: address,
          onSetDefault: () => _setDefaultAddress(ref, address.id),
          onEdit: () => _showEditAddressSheet(context, ref, address),
          onDelete: () => _confirmDeleteAddress(context, ref, address),
        );
      },
    );
  }

  void _showAddAddressSheet(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _AddAddressSheet(
        onSave: (address, label, isDefault) async {
          await ref
              .read(addressManagerProvider.notifier)
              .createAddress(
                streetLine1: address.streetLine1,
                streetLine2: address.streetLine2,
                city: address.city,
                state: address.state,
                postalCode: address.postalCode,
                latitude: address.latitude,
                longitude: address.longitude,
                deliveryInstructions: address.deliveryInstructions,
                label: label,
                isDefault: isDefault,
              );
          if (context.mounted) {
            Navigator.pop(context);
          }
        },
      ),
    );
  }

  void _showEditAddressSheet(
    BuildContext context,
    WidgetRef ref,
    Address address,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _AddAddressSheet(
        existingAddress: address,
        onSave: (newAddress, label, isDefault) async {
          // Delete old and create new (simplest approach)
          await ref
              .read(addressManagerProvider.notifier)
              .deleteAddress(address.id);
          await ref
              .read(addressManagerProvider.notifier)
              .createAddress(
                streetLine1: newAddress.streetLine1,
                streetLine2: newAddress.streetLine2,
                city: newAddress.city,
                state: newAddress.state,
                postalCode: newAddress.postalCode,
                latitude: newAddress.latitude,
                longitude: newAddress.longitude,
                deliveryInstructions: newAddress.deliveryInstructions,
                label: label,
                isDefault: isDefault,
              );
          if (context.mounted) {
            Navigator.pop(context);
          }
        },
      ),
    );
  }

  Future<void> _setDefaultAddress(WidgetRef ref, String addressId) async {
    await ref
        .read(addressManagerProvider.notifier)
        .setDefaultAddress(addressId);
  }

  void _confirmDeleteAddress(
    BuildContext context,
    WidgetRef ref,
    Address address,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Address'),
        content: Text(
          'Are you sure you want to delete "${address.label ?? address.streetLine1}"?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await ref
                  .read(addressManagerProvider.notifier)
                  .deleteAddress(address.id);
            },
            style: TextButton.styleFrom(foregroundColor: context.colors.error),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}

/// Empty state hint widget
class _EmptyStateHint extends StatelessWidget {
  final IconData icon;
  final String label;

  const _EmptyStateHint({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: context.colors.surfaceVariant,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: context.colors.textTertiary, size: 24),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(color: context.colors.textTertiary, fontSize: 12),
        ),
      ],
    );
  }
}

/// Address card widget
class _AddressCard extends StatelessWidget {
  final Address address;
  final VoidCallback onSetDefault;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _AddressCard({
    required this.address,
    required this.onSetDefault,
    required this.onEdit,
    required this.onDelete,
  });

  IconData _getLabelIcon() {
    final label = address.label?.toLowerCase();
    if (label == 'home') return LucideIcons.house;
    if (label == 'work' || label == 'office') return LucideIcons.briefcase;
    return LucideIcons.mapPin;
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: address.isDefault ? 2 : 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: address.isDefault
              ? context.colors.primary
              : context.colors.borderLight,
          width: address.isDefault ? 2 : 1,
        ),
      ),
      child: InkWell(
        onTap: onEdit,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  // Icon
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: address.isDefault
                          ? context.colors.primary.withValues(alpha: 0.1)
                          : context.colors.surfaceVariant,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      _getLabelIcon(),
                      size: 20,
                      color: address.isDefault
                          ? context.colors.primary
                          : context.colors.textSecondary,
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Label and default badge
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              address.label ?? 'Address',
                              style: context.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            if (address.isDefault) ...[
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: context.colors.primary,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  'Default',
                                  style: context.textTheme.labelSmall?.copyWith(
                                    color: context.colors.surface,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                        const SizedBox(height: 2),
                        Text(
                          address.streetLine1,
                          style: context.textTheme.bodyMedium,
                        ),
                      ],
                    ),
                  ),
                  // Menu button
                  PopupMenuButton<String>(
                    icon: Icon(
                      LucideIcons.ellipsisVertical,
                      color: context.colors.textSecondary,
                    ),
                    onSelected: (value) {
                      switch (value) {
                        case 'default':
                          onSetDefault();
                          break;
                        case 'edit':
                          onEdit();
                          break;
                        case 'delete':
                          onDelete();
                          break;
                      }
                    },
                    itemBuilder: (context) => [
                      if (!address.isDefault)
                        const PopupMenuItem(
                          value: 'default',
                          child: Row(
                            children: [
                              Icon(LucideIcons.star, size: 18),
                              SizedBox(width: 12),
                              Text('Set as Default'),
                            ],
                          ),
                        ),
                      const PopupMenuItem(
                        value: 'edit',
                        child: Row(
                          children: [
                            Icon(LucideIcons.pencil, size: 18),
                            SizedBox(width: 12),
                            Text('Edit'),
                          ],
                        ),
                      ),
                      PopupMenuItem(
                        value: 'delete',
                        child: Builder(
                          builder: (menuContext) => Row(
                            children: [
                              Icon(
                                LucideIcons.trash2,
                                size: 18,
                                color: menuContext.colors.error,
                              ),
                              const SizedBox(width: 12),
                              Text(
                                'Delete',
                                style: TextStyle(
                                  color: menuContext.colors.error,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              // Full address details
              Padding(
                padding: const EdgeInsets.only(left: 54, top: 4),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (address.streetLine2 != null &&
                        address.streetLine2!.isNotEmpty) ...[
                      Text(
                        address.streetLine2!,
                        style: TextStyle(color: context.colors.textSecondary),
                      ),
                    ],
                    Text(
                      '${address.city}, ${address.state} ${address.postalCode}',
                      style: TextStyle(color: context.colors.textSecondary),
                    ),
                    if (address.deliveryInstructions != null &&
                        address.deliveryInstructions!.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(
                            LucideIcons.messageSquare,
                            size: 14,
                            color: context.colors.textTertiary,
                          ),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              address.deliveryInstructions!,
                              style: context.textTheme.bodySmall?.copyWith(
                                color: context.colors.textTertiary,
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                    // Coordinates badge (for debugging/verification)
                    if (address.hasCoordinates) ...[
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(
                            LucideIcons.mapPinCheck,
                            size: 12,
                            color: context.colors.success,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'GPS verified',
                            style: context.textTheme.labelSmall?.copyWith(
                              color: context.colors.success,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Add/Edit address bottom sheet with ModernAddressPicker
class _AddAddressSheet extends ConsumerStatefulWidget {
  final Address? existingAddress;
  final Future<void> Function(
    DeliveryAddress address,
    String? label,
    bool isDefault,
  )
  onSave;

  const _AddAddressSheet({this.existingAddress, required this.onSave});

  @override
  ConsumerState<_AddAddressSheet> createState() => _AddAddressSheetState();
}

class _AddAddressSheetState extends ConsumerState<_AddAddressSheet> {
  final _labelController = TextEditingController();
  DeliveryAddress? _selectedAddress;
  bool _isDefault = false;
  bool _isSaving = false;

  // Predefined labels
  final _presetLabels = ['Home', 'Work', 'Other'];
  String? _selectedPresetLabel;

  @override
  void initState() {
    super.initState();
    if (widget.existingAddress != null) {
      final addr = widget.existingAddress!;
      _selectedAddress = DeliveryAddress(
        streetLine1: addr.streetLine1,
        streetLine2: addr.streetLine2,
        city: addr.city,
        state: addr.state,
        postalCode: addr.postalCode,
        country: addr.country,
        latitude: addr.latitude,
        longitude: addr.longitude,
        deliveryInstructions: addr.deliveryInstructions,
      );
      _labelController.text = addr.label ?? '';
      _isDefault = addr.isDefault;

      // Check if it matches a preset
      if (_presetLabels.contains(addr.label)) {
        _selectedPresetLabel = addr.label;
      }
    }
  }

  @override
  void dispose() {
    _labelController.dispose();
    super.dispose();
  }

  Future<void> _handleSave() async {
    if (_selectedAddress == null || !_selectedAddress!.isValid) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please select a valid address'),
          backgroundColor: context.colors.error,
        ),
      );
      return;
    }

    final label =
        _selectedPresetLabel ??
        (_labelController.text.isNotEmpty ? _labelController.text : null);

    setState(() => _isSaving = true);

    try {
      await widget.onSave(_selectedAddress!, label, _isDefault);
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.existingAddress != null;

    return Container(
      decoration: BoxDecoration(
        color: context.colors.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: DraggableScrollableSheet(
        initialChildSize: 0.9,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        expand: false,
        builder: (context, scrollController) {
          return Column(
            children: [
              // Handle
              Container(
                margin: const EdgeInsets.symmetric(vertical: 12),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: context.colors.borderLight,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              // Header
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      isEditing ? 'Edit Address' : 'Add New Address',
                      style: context.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(LucideIcons.x),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1),
              // Content
              Expanded(
                child: ListView(
                  controller: scrollController,
                  padding: const EdgeInsets.all(16),
                  children: [
                    // Address label section
                    Text(
                      'Address Label',
                      style: context.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 12),
                    // Preset label chips
                    Row(
                      children: _presetLabels.map((label) {
                        final isSelected = _selectedPresetLabel == label;
                        return Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: ChoiceChip(
                            label: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  label == 'Home'
                                      ? LucideIcons.house
                                      : label == 'Work'
                                      ? LucideIcons.briefcase
                                      : LucideIcons.mapPin,
                                  size: 16,
                                  color: isSelected
                                      ? context.colors.surface
                                      : context.colors.textSecondary,
                                ),
                                const SizedBox(width: 6),
                                Text(label),
                              ],
                            ),
                            selected: isSelected,
                            onSelected: (selected) {
                              setState(() {
                                _selectedPresetLabel = selected ? label : null;
                                if (selected) {
                                  _labelController.clear();
                                }
                              });
                            },
                            selectedColor: context.colors.primary,
                            labelStyle: TextStyle(
                              color: isSelected ? context.colors.surface : null,
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 12),
                    // Custom label input
                    TextField(
                      controller: _labelController,
                      decoration: InputDecoration(
                        labelText: 'Or enter custom label',
                        hintText: 'e.g., Mom\'s House, Gym',
                        prefixIcon: const Icon(LucideIcons.tag, size: 18),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onChanged: (value) {
                        if (value.isNotEmpty) {
                          setState(() => _selectedPresetLabel = null);
                        }
                      },
                    ),

                    const SizedBox(height: 24),

                    // Address picker section
                    Text(
                      'Delivery Address',
                      style: context.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 12),
                    // Modern Address Picker - same as checkout!
                    ModernAddressPicker(
                      initialAddress: _selectedAddress,
                      showDeliveryInstructions: true,
                      onAddressChanged: (address) {
                        setState(() {
                          _selectedAddress = address;
                        });
                      },
                    ),

                    const SizedBox(height: 24),

                    // Set as default toggle
                    SwitchListTile(
                      value: _isDefault,
                      onChanged: (value) {
                        setState(() => _isDefault = value);
                      },
                      title: const Text('Set as default address'),
                      subtitle: Text(
                        'This address will be pre-selected during checkout',
                        style: TextStyle(
                          color: context.colors.textSecondary,
                          fontSize: 12,
                        ),
                      ),
                      secondary: Icon(
                        LucideIcons.star,
                        color: _isDefault
                            ? context.colors.primary
                            : context.colors.textTertiary,
                      ),
                      contentPadding: EdgeInsets.zero,
                    ),

                    const SizedBox(height: 24),

                    // Save button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _isSaving ? null : _handleSave,
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        child: _isSaving
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : Text(
                                isEditing ? 'Update Address' : 'Save Address',
                              ),
                      ),
                    ),

                    // Bottom padding for keyboard
                    SizedBox(height: MediaQuery.of(context).viewInsets.bottom),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
