import 'package:amrric_app/services/auth_service.dart';
import 'package:amrric_app/models/user.dart';

class AnimalPermissions {
  final AuthService _authService;

  AnimalPermissions(this._authService);

  // Full animal management
  Future<bool> canManageAnimals() async {
    final user = await _authService.getCurrentUser();
    final role = user?.role;
    return role == UserRole.systemAdmin || role == UserRole.municipalityAdmin || 
           role == UserRole.veterinaryUser || role == UserRole.censusUser;
  }
  
  // View permissions
  Future<bool> canViewAllAnimals() async {
    final user = await _authService.getCurrentUser();
    final role = user?.role;
    return role == UserRole.systemAdmin || role == UserRole.municipalityAdmin || 
           role == UserRole.veterinaryUser;
  }

  Future<bool> canViewCouncilAnimals() async {
    final user = await _authService.getCurrentUser();
    final role = user?.role;
    return role == UserRole.municipalityAdmin || role == UserRole.censusUser;
  }

  Future<bool> canViewMedicalHistory() async {
    final user = await _authService.getCurrentUser();
    final role = user?.role;
    return role == UserRole.veterinaryUser || role == UserRole.systemAdmin || 
           role == UserRole.municipalityAdmin;
  }
  
  // Edit permissions
  Future<bool> canCreateAnimal() async {
    final user = await _authService.getCurrentUser();
    final role = user?.role;
    return role == UserRole.systemAdmin || role == UserRole.municipalityAdmin || 
           role == UserRole.censusUser || role == UserRole.veterinaryUser;
  }

  Future<bool> canEditAnimal() async {
    final user = await _authService.getCurrentUser();
    final role = user?.role;
    return role == UserRole.systemAdmin || role == UserRole.municipalityAdmin || 
           role == UserRole.veterinaryUser || role == UserRole.censusUser;
  }

  Future<bool> canDeleteAnimal() async {
    final user = await _authService.getCurrentUser();
    final role = user?.role;
    return role == UserRole.systemAdmin || role == UserRole.veterinaryUser || 
           role == UserRole.municipalityAdmin;
  }
  
  // Medical permissions
  Future<bool> canAddMedicalRecords() async {
    final user = await _authService.getCurrentUser();
    final role = user?.role;
    return role == UserRole.veterinaryUser || role == UserRole.systemAdmin;
  }

  Future<bool> canEditMedicalRecords() async {
    final user = await _authService.getCurrentUser();
    final role = user?.role;
    return role == UserRole.veterinaryUser || role == UserRole.systemAdmin;
  }

  Future<bool> canAddTreatments() async {
    final user = await _authService.getCurrentUser();
    final role = user?.role;
    return role == UserRole.veterinaryUser || role == UserRole.systemAdmin;
  }
  
  // Census permissions
  Future<bool> canAddBasicAnimal() async {
    final user = await _authService.getCurrentUser();
    final role = user?.role;
    return role == UserRole.censusUser || role == UserRole.systemAdmin || 
           role == UserRole.veterinaryUser || role == UserRole.municipalityAdmin;
  }

  Future<bool> canUpdateBasicInfo() async {
    final user = await _authService.getCurrentUser();
    final role = user?.role;
    return role == UserRole.censusUser || role == UserRole.systemAdmin || 
           role == UserRole.veterinaryUser || role == UserRole.municipalityAdmin;
  }
  
  // Validation permissions
  Future<bool> canValidateAnimalData() async {
    final user = await _authService.getCurrentUser();
    final role = user?.role;
    return role == UserRole.systemAdmin || role == UserRole.municipalityAdmin || 
           role == UserRole.veterinaryUser;
  }

  Future<bool> canAddAnimal() async {
    final user = await _authService.getCurrentUser();
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