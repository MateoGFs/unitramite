import 'package:flutter/material.dart';

/// Icono de cada trámite. Un trámite nuevo sin icono usa uno genérico.
IconData tramiteIcon(String id) {
  switch (id) {
    case 'TR-001':
      return Icons.description_outlined;
    case 'TR-002':
      return Icons.edit_note_outlined;
    case 'TR-003':
      return Icons.swap_horiz_rounded;
    case 'TR-004':
      return Icons.school_outlined;
    case 'TR-005':
      return Icons.event_busy_outlined;
    case 'TR-006':
      return Icons.replay_rounded;
    case 'TR-007':
      return Icons.bookmark_added_outlined;
    default:
      return Icons.assignment_outlined;
  }
}