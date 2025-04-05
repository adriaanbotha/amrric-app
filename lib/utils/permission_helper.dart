import 'package:amrric_app/services/auth_service.dart';
import 'package:amrric_app/models/user.dart';

class AnimalPermissions {
  final AuthService _authService;

  AnimalPermissions(this._authService);

  // Full animal management
  bool canManageAnimals() {
    final role = _authService.currentUser?.role;
    return role == UserRole.systemAdmin || role == UserRole.municipalityAdmin || 
           role == UserRole.veterinaryUser || role == UserRole.censusUser;
  }
  
  // View permissions
  bool canViewAllAnimals() {
    final role = _authService.currentUser?.role;
    return role == UserRole.systemAdmin || role == UserRole.municipalityAdmin || 
           role == UserRole.veterinaryUser;
  }

  bool canViewCouncilAnimals() {
    final role = _authService.currentUser?.role;
    return role == UserRole.municipalityAdmin || role == UserRole.censusUser;
  }

  bool canViewMedicalHistory() {
    final role = _authService.currentUser?.role;
    return role == UserRole.veterinaryUser || role == UserRole.systemAdmin || 
           role == UserRole.municipalityAdmin;
  }
  
  // Edit permissions
  bool canCreateAnimal() {
    final role = _authService.currentUser?.role;
    return role == UserRole.systemAdmin || role == UserRole.municipalityAdmin || 
           role == UserRole.censusUser || role == UserRole.veterinaryUser;
  }

  bool canEditAnimal() {
    final role = _authService.currentUser?.role;
    return role == UserRole.systemAdmin || role == UserRole.municipalityAdmin || 
           role == UserRole.veterinaryUser || role == UserRole.censusUser;
  }

  bool canDeleteAnimal() {
    final role = _authService.currentUser?.role;
    return role == UserRole.systemAdmin || role == UserRole.veterinaryUser || 
           role == UserRole.municipalityAdmin;
  }
  
  // Medical permissions
  bool canAddMedicalRecords() {
    final role = _authService.currentUser?.role;
    return role == UserRole.veterinaryUser || role == UserRole.systemAdmin;
  }

  bool canEditMedicalRecords() {
    final role = _authService.currentUser?.role;
    return role == UserRole.veterinaryUser || role == UserRole.systemAdmin;
  }

  bool canAddTreatments() {
    final role = _authService.currentUser?.role;
    return role == UserRole.veterinaryUser || role == UserRole.systemAdmin;
  }
  
  // Census permissions
  bool canAddBasicAnimal() {
    final role = _authService.currentUser?.role;
    return role == UserRole.censusUser || role == UserRole.systemAdmin || 
           role == UserRole.veterinaryUser || role == UserRole.municipalityAdmin;
  }

  bool canUpdateBasicInfo() {
    final role = _authService.currentUser?.role;
    return role == UserRole.censusUser || role == UserRole.systemAdmin || 
           role == UserRole.veterinaryUser || role == UserRole.municipalityAdmin;
  }
  
  // Validation permissions
  bool canValidateAnimalData() {
    final role = _authService.currentUser?.role;
    return role == UserRole.systemAdmin || role == UserRole.municipalityAdmin || 
           role == UserRole.veterinaryUser;
  }

  bool canAddAnimal() {
    final user = _authService.currentUser;
    if (user == null) return false;

    switch (user.role) {
      case UserRole.systemAdmin:
      case UserRole.municipalityAdmin:
      case UserRole.veterinaryUser:
      case UserRole.censusUser:
        return true;
      default:
        return false;
    }
  }
} 