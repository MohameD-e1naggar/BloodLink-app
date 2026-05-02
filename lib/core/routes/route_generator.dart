import 'package:flutter/material.dart';
import 'package:www/core/routes/routes.dart';
import 'package:www/features/splash_screen/splash_screen.dart';
import 'package:www/features/onboarding/onboarding_screen.dart';
import 'package:www/features/onboarding/role_selection_screen.dart';

import 'package:www/features/donor/auth/donor_login_screen.dart';
import 'package:www/features/donor/donor_wrapper.dart';
import 'package:www/features/donor/requests/donor_request_details_screen.dart';
import 'package:www/features/donor/requests/donor_confirm_donation_screen.dart';
import 'package:www/features/donor/requests/donor_appointment_screen.dart';
import 'package:www/features/donor/auth/registration/basic_info_screen.dart';
import 'package:www/features/donor/auth/registration/personal_info_screen.dart';
import 'package:www/features/donor/auth/registration/health_screening_screen.dart';
import 'package:www/features/donor/auth/registration/review_summary_screen.dart';

import 'package:www/features/hospital/auth/hospital_login_screen.dart';
import 'package:www/features/hospital/hospital_wrapper.dart';
import 'package:www/features/hospital/requests/hospital_blood_request_screen.dart';
import 'package:www/features/hospital/home/hospital_search_screen.dart';
import 'package:www/features/hospital/home/hospital_notifications_screen.dart';
import 'package:www/features/hospital/auth/registration/hospital_registration_screen.dart';
import 'package:www/features/hospital/auth/registration/hospital_responsible_person_screen.dart';

import 'package:www/features/blood_bank/auth/blood_bank_login_screen.dart';
import 'package:www/features/blood_bank/blood_bank_wrapper.dart';
import 'package:www/features/blood_bank/home/blood_bank_notifications_screen.dart';
import 'package:www/features/blood_bank/auth/registration/blood_bank_registration_screen.dart';
import 'package:www/features/blood_bank/auth/registration/blood_bank_responsible_person_screen.dart';

import 'package:www/core/models/blood_request.dart';
import 'package:www/core/models/user.dart' as my_user;

class RouteGenerator {
  static Route<dynamic>? getRoute(RouteSettings settings) {


    switch (settings.name) {
      case Routes.welcomeRoute:
        return _build((_) => const SplashScreen());

      case Routes.onboardingRoute:
        return _build((_) => const OnboardingScreen());

      case Routes.roleSelectionRoute:
        return _build((_) => const RoleSelectionScreen());

      // Donor

      case Routes.donorLoginRoute:
        return _build((_) => const DonorLoginScreen());

      case Routes.donorHomeRoute:
        return _build((_) => const DonorWrapper());

      case Routes.donorRegisterBasicRoute:
        return _build((_) => const BasicInfoScreen());

      case Routes.donorRegisterPersonalRoute:
        final args = settings.arguments as Map<String, dynamic>?;
        _assertArgs(args, Routes.donorRegisterPersonalRoute);
        return _build((_) => PersonalInfoScreen(
          fullName: args!['fullName'],
          email: args['email'],
          pass: args['pass'],
          phone: args['phone'],
        ));

      case Routes.donorRegisterHealthRoute:
        final args = settings.arguments as Map<String, dynamic>?;
        _assertArgs(args, Routes.donorRegisterHealthRoute);
        return _build((_) => HealthScreeningScreen(
          fullName: args!['fullName'],
          email: args['email'],
          pass: args['pass'],
          phone: args['phone'],
          dob: args['dob'],
          gender: args['gender'],
          bloodType: args['bloodType'],
          weight: args['weight'],
        ));

      case Routes.donorRegisterReviewRoute:
        final args = settings.arguments as Map<String, dynamic>?;
        _assertArgs(args, Routes.donorRegisterReviewRoute);
        return _build((_) => ReviewSummaryScreen(
          fullName: args!['fullName'],
          email: args['email'],
          pass: args['pass'],
          phone: args['phone'],
          dob: args['dob'],
          gender: args['gender'],
          bloodType: args['bloodType'],
          weight: args['weight'],
          hasChronicDiseases: args['hasChronicDiseases'],
          takesMedication: args['takesMedication'],
          hadSurgery: args['hadSurgery'],
          hasAnemia: args['hasAnemia'],
          lastDonation: args['lastDonation'],
        ));

      case Routes.donorRequestDetailsRoute:
        final req = settings.arguments as Request;
        return _build((_) => DonationDetailsScreen(request: req));

      case Routes.donorBloodBanksRoute:
        return _build((_) => const BloodBanksScreen());

      case Routes.donorConfirmDonationRoute:
        final bloodBank = settings.arguments as my_user.User;
        return _build((_) => MakeAppointmentScreen(bloodBank: bloodBank));

      // Hospital

      case Routes.hospitalLoginRoute:
        return _build((_) => const HospitalLoginScreen());

      case Routes.hospitalHomeRoute:
        return _build((_) => const HospitalWrapper());

      case Routes.hospitalRegisterRoute:
        return _build((_) => const HospitalRegistrationScreen());

      case Routes.hospitalRegisterResponsibleRoute:
        final args = settings.arguments as Map<String, dynamic>?;
        _assertArgs(args, Routes.hospitalRegisterResponsibleRoute);
        return _build((_) => HospitalResponsiblePersonScreen(
          hospitalName: args!['hospitalName'],
          email: args['email'],
          pass: args['pass'],
          phoneNumber: args['phoneNumber'],
          address: args['address'],
        ));

      case Routes.hospitalBloodRequestRoute:
        final hospitalName = settings.arguments as String;
        return _build((_) => HospitalBloodRequestScreen(hospitalName: hospitalName));

      case Routes.hospitalSearchRoute:
        return _build((_) => const HospitalSearchScreen());

      case Routes.hospitalNotificationsRoute:
        final uid = settings.arguments as String;
        return _build((_) => NotificationsScreen(uid: uid));

      // Blood Bank

      case Routes.bloodBankLoginRoute:
        return _build((_) => const BloodBankLoginScreen());

      case Routes.bloodBankHomeRoute:
        return _build((_) => const BloodBankWrapper());

      case Routes.bloodBankRegisterRoute:
        return _build((_) => const BloodBankRegistrationScreen());

      case Routes.bloodBankRegisterResponsibleRoute:
        final args = settings.arguments as Map<String, dynamic>?;
        _assertArgs(args, Routes.bloodBankRegisterResponsibleRoute);
        return _build((_) => BloodBankResponsiblePersonScreen(
          bankName: args!['bankName'],
          email: args['email'],
          pass: args['pass'],
          phoneNumber: args['phoneNumber'],
          address: args['address'],
          workingHours: args['workingHours'],
        ));

      case Routes.bloodBankNotificationsRoute:
        return _build((_) => const BloodBankNotifications());

      default:
        return _errorRoute(settings.name);
    }
  }

  static MaterialPageRoute<dynamic> _build(WidgetBuilder builder) {
    return MaterialPageRoute(builder: builder);
  }

  static void _assertArgs(Map<String, dynamic>? args, String route) {
    assert(args != null, 'Route "$route" requires a Map<String, dynamic> argument.');
  }

  static Route<dynamic> _errorRoute(String? name) {
    return MaterialPageRoute(
      builder: (_) => Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: Text(
            'No route defined for "$name"',
            style: const TextStyle(color: Colors.white),
          ),
        ),
      ),
    );
  }
}
