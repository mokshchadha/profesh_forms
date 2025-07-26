import 'package:flutter/material.dart';

enum OtpType { login, signUpEmail, signUpPhone, loginCandidate }

enum PreferenceUpdateFlow { signUp, profile, banner, projectCreation }

enum UserType { candidate, recruiter }

enum FinalPreviewType { confirmed, notConfirmed, isEdit }

enum ProjectStatusType { active, closed }

extension ProjectStatusTypeExtension on ProjectStatusType {
  String get value {
    switch (this) {
      case ProjectStatusType.active:
        return "ACTIVE";
      case ProjectStatusType.closed:
        return "CLOSED";
    }
  }
}

enum Avatars {
  yellow,
  blue,
  green,
}

extension AvatarsExtension on Avatars {
  String get url {
    switch (this) {
      case Avatars.yellow:
        return 'https://i.ibb.co/T4PFmHz/yellow.png';
      case Avatars.blue:
        return 'https://i.ibb.co/6YRD0gx/blue.png';
      case Avatars.green:
        return 'https://i.ibb.co/wQFcV2v/green.png';
      default:
        return '';
    }
  }
}

enum AnalyticsEvents {
  view_cv_open,
  view_cv_closed,
  accepted_video_cv,
  rejected_video_cv,
  video_loaded,
  video_skipped,
  navigated_to_shortlisted,
  navigated_to_home,
  navigated_from_home,
  schedule_interview,
  cancel_interview,
  remove_shortlisted,
  clicked_banner,
  register_webinar,
  deny_video_update,
}

enum CandidateStatus { shortlisted, viewed, rejected, unreviewed }

enum InterviewStatus { schedule, invalid }

enum UserStatus { active, inactive, pending }

extension UserStatusExtension on UserStatus {
  String get value {
    switch (this) {
      case UserStatus.active:
        return "Active";
      case UserStatus.inactive:
        return "Inactive";
      case UserStatus.pending:
        return "Pending";
    }
  }
}

enum ThemeColors {
  lavender,
  lime,
  lime100,
  lime200,
  lime500,
  lime700,
  lime900,

  mauve,
  mauve100,
  mauve300,
  mauve500,
  mauve700,
  mauve900,

  slateGreen,
  slateGreen100,
  slateGreen200,
  slateGreen500,
  slateGreen700,
  slateGreen900,

  neutral1,
  neutral2,
  neutral3,
  neutral4,
  neutral5,
  neutral6,

  black,
  malachite,
  red,
  neon,
  indigo,
  amber,
  lightgrey,
}

extension ThemeColorExtension on ThemeColors {
  Color get color {
    switch (this) {
      case ThemeColors.lavender:
        return const Color(0xff322275);
      case ThemeColors.indigo:
        return const Color.fromARGB(255, 153, 153, 227);
      case ThemeColors.mauve:
        return const Color(0xFFC9B3F4);
      case ThemeColors.mauve100:
        return const Color(0xFFF7F0FE);
      case ThemeColors.mauve300:
        return const Color(0xFFE3D3FB);
      case ThemeColors.mauve500:
        return const Color(0xFFC9B3F4);
      case ThemeColors.mauve700:
        return const Color(0xFF715AAF);
      case ThemeColors.mauve900:
        return const Color(0xFF322275);
      case ThemeColors.slateGreen:
        return const Color(0xFF2A4B4E);
      case ThemeColors.slateGreen100:
        return const Color(0xFFDFF6F0);
      case ThemeColors.slateGreen200:
        return const Color(0xFF91C9C5);
      case ThemeColors.slateGreen500:
        return const Color(0xFF2A4B4E);
      case ThemeColors.slateGreen700:
        return const Color(0xFF152F38);
      case ThemeColors.slateGreen900:
        return const Color(0xFF081925);
      case ThemeColors.lime:
        return const Color(0xFFB3F00D);
      case ThemeColors.lime100:
        return const Color(0xFFF6FECE);
      case ThemeColors.lime200:
        return const Color(0xFFDCFA6C);
      case ThemeColors.lime500:
        return const Color(0xFFB3F00D);
      case ThemeColors.lime700:
        return const Color(0xFF76AC06);
      case ThemeColors.lime900:
        return const Color(0xFF487302);

      case ThemeColors.neutral1:
        return const Color(0xFFFFFFFF);
      case ThemeColors.neutral2:
        return const Color(0xFFCACACA);
      case ThemeColors.neutral3:
        return const Color(0xFF989898);
      case ThemeColors.neutral4:
        return const Color(0xFF5B5B5B);
      case ThemeColors.neutral5:
        return const Color(0xFF424242);
      case ThemeColors.neutral6:
        return const Color(0xFF121212);

      case ThemeColors.malachite:
        return const Color(0xFF003033);
      case ThemeColors.black:
        return const Color(0xFF051011);
      case ThemeColors.neon:
        return const Color.fromARGB(255, 57, 255, 20).withOpacity(0.5);
      case ThemeColors.red:
        return const Color.fromARGB(255, 255, 20, 20).withOpacity(0.5);
      case ThemeColors.amber:
        return const Color.fromARGB(255, 229, 167, 10);
      case ThemeColors.lightgrey:
        return const Color(0xffF0F0F0);
      default:
        return Colors.black;
    }
  }
}

enum Images {
  bgShiftedUp,
  bgShiftedDown,
  bgStar,
  logo,
  bgSimple,
  resumeSuccess,
  bgBlack,
  bgLanding,
  bgBlackAndWhite,
  landingImage,
  recruiterProfileBg,
  resumeSuccessBg,
  bgDesignBlack,
}

extension ImagesExtension on Images {
  AssetImage get assetImage {
    switch (this) {
      case Images.bgShiftedUp:
        return const AssetImage('assets/bg_shifted_up.png');
      case Images.bgShiftedDown:
        return const AssetImage('assets/bg_c.png');
      case Images.bgStar:
        return const AssetImage('assets/bg_1.png');
      case Images.logo:
        return const AssetImage('assets/logo.png');
      case Images.bgSimple:
        return const AssetImage('assets/bg_simple.png');
      case Images.resumeSuccess:
        return const AssetImage('assets/resume_uploaded.png');
      case Images.bgBlack:
        return const AssetImage('assets/bg_black.jpg');
      case Images.bgLanding:
        return const AssetImage('assets/bg_landing.png');
      case Images.bgBlackAndWhite:
        return const AssetImage('assets/bg_black_and_white.png');
      case Images.landingImage:
        return const AssetImage('assets/landing.png');
      case Images.recruiterProfileBg:
        return const AssetImage('assets/profile_bg.png');
      case Images.resumeSuccessBg:
        return const AssetImage('assets/resume_success_bg.png');
      case Images.bgDesignBlack:
        return const AssetImage('assets/bg_design_black.png');
    }
  }

  String get path {
    switch (this) {
      case Images.bgShiftedUp:
        return 'assets/bg_shifted_up.png';
      case Images.bgShiftedDown:
        return 'assets/bg_shifted_down.png';
      case Images.bgStar:
        return 'assets/bg_star.png';
      case Images.logo:
        return 'assets/logo.png';
      case Images.bgSimple:
        return 'assets/bg_simple.png';
      case Images.resumeSuccess:
        return 'assets/resume_uploaded.png';
      case Images.bgBlack:
        return 'assets/bg_black.jpg';
      case Images.bgLanding:
        return 'assets/bg_landing.png';
      case Images.bgBlackAndWhite:
        return 'assets/bg_black_and_white.png';
      case Images.landingImage:
        return 'assets/landing.png';
      case Images.recruiterProfileBg:
        return 'assets/profile_bg.png';
      case Images.resumeSuccessBg:
        return 'assets/resume_success_bg.png';
      case Images.bgDesignBlack:
        return 'assets/bg_design_black.png';
    }
  }
}

enum Languages { english, hindi, kannada }

extension LanguageExtension on Languages {
  String get code {
    switch (this) {
      case Languages.hindi:
        return 'hi';
      case Languages.english:
        return 'en';
      case Languages.kannada:
        return 'kn';
    }
  }
}

enum FilterType { publicFeed, applicationFeed }

const APPLICATION_FEED_LIMIT = 150;

const deepLinkScheme = 'profesh';

const apiV1 = 'api/v1';
const apiV2 = 'api/v2';
const demoRefCode = "demo";
const sandboxURL = 'https://dev.joinprofesh.com';
const prodUrl = 'https://prod.joinprofesh.com';
final emailRegex = RegExp(r'^[\w-\.]+@[\w-\.]+\.[a-z]{2,4}$');
const profeshPublicURL = 'https://profesh.web.app';
const watiNumber = '+918951437501';
const contactUsEmail = 'team@joinprofesh.com';
const serverUrl = sandboxURL;
