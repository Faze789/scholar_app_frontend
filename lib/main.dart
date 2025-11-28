import 'dart:async';
import 'student_alumni_admin.dart';
import 'student/student_screen.dart'; 
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:scholar_match_app/student/forgot.dart';
import 'package:scholar_match_app/student/uet_fee.dart';
import 'package:scholar_match_app/student/feedback.dart';
import 'package:scholar_match_app/student/air_feee.dart';
import 'package:scholar_match_app/student/iiui_uni.dart';
import 'package:scholar_match_app/student/lums_fee.dart';
import 'package:scholar_match_app/student/all_chats.dart';
import 'package:scholar_match_app/student/practice__.dart';
import 'package:scholar_match_app/student/visual_uni.dart';
import 'package:scholar_match_app/student/uni_events.dart';
import 'package:scholar_match_app/student/AIR_scholar.dart';
import 'package:scholar_match_app/student/chat_screen.dart';
import 'package:scholar_match_app/student/comsats_uni.dart';
import 'package:scholar_match_app/alumni/apply_alumnii.dart';
import 'package:scholar_match_app/alumni/comsats_event.dart';
import 'package:scholar_match_app/student/UetDashboard.dart';
import 'package:scholar_match_app/admin/admin_dashboard.dart';
import 'package:scholar_match_app/alumni/all_uni_events.dart';
import 'package:scholar_match_app/alumni/events_applied.dart';
import 'package:scholar_match_app/alumni/alumni_sign_in.dart';
import 'package:scholar_match_app/alumni/alumni_sign_up.dart';
import 'package:scholar_match_app/student/AIR_DASHBOARD.dart';
import 'package:scholar_match_app/student/LumsDashboard.dart';
import 'package:scholar_match_app/student/NustUniScreen.dart';
import 'package:scholar_match_app/student/FAST_UNI_FEES.dart';
import 'package:scholar_match_app/alumni/AlumniNedEvents.dart';
import 'package:scholar_match_app/student/connect_alumni.dart';
import 'package:scholar_match_app/admin/admin_home_screen.dart';
import 'package:scholar_match_app/alumni/AlumniIqraEvents.dart';
import 'package:scholar_match_app/alumni/AlumniNustEvents.dart';
import 'package:scholar_match_app/alumni/AlumniHomeScreen.dart';
import 'package:scholar_match_app/alumni/alumni_dashboard.dart';
import 'package:scholar_match_app/student/ned_fees_screen.dart';
import 'package:scholar_match_app/alumni/MessageChatScreen.dart';
import 'package:scholar_match_app/student/IIUIUniDashboard.dart';
import 'package:scholar_match_app/student/NustUniDashboard.dart';
import 'package:scholar_match_app/student/NedFeesDashboard.dart';
import 'package:scholar_match_app/student/uet_scholarships.dart';
import 'package:scholar_match_app/student/lums_scholarship.dart';
import 'package:scholar_match_app/student/StudentChooseUni.dart';
import 'package:scholar_match_app/student/uni_of_education.dart';
import 'package:scholar_match_app/student/uoe_scholarships.dart';
import 'package:scholar_match_app/student/IIUI-scholarships.dart';
import 'package:scholar_match_app/student/FAST_SCHOLARSHIPS.dart';
import 'package:scholar_match_app/alumni/alumni_chats_screen.dart';
import 'package:scholar_match_app/student/StudentLoginScreen.dart';
import 'package:scholar_match_app/student/FAST_UNI_DASHBOARD.dart';
import 'package:scholar_match_app/admin/admin_check_all_users.dart';
import 'package:scholar_match_app/student/ComsatsUniDashboard.dart';
import 'package:scholar_match_app/student/StudentSignUpScreen.dart';
import 'package:scholar_match_app/student/uni_of_education_fee.dart';
import 'package:scholar_match_app/student/AllScholarshipsScreen.dart';
import 'package:scholar_match_app/student/NustScholarshipScreen.dart';
import 'package:scholar_match_app/student/StudentDashboardScreen.dart';
import 'package:scholar_match_app/student/ned_scholarship_screen.dart';
import 'package:scholar_match_app/admin/admin_check_user_feedback.dart';
import 'package:scholar_match_app/student/COMSATS_scholarship_screen.dart';
import 'package:scholar_match_app/student/abroad_scholarships/rhodes.dart';
import 'package:scholar_match_app/student/abroad_scholarships/erasmus.dart';
import 'package:scholar_match_app/student/abroad_scholarships/common_wealth.dart';
import 'package:scholar_match_app/student/abroad_scholarships/sweden_scholarships.dart';
import 'package:scholar_match_app/student/abroad_scholarships/turkey_scholarships.dart';
import 'package:scholar_match_app/student/abroad_scholarships/hungary_scholarships.dart';
import 'package:scholar_match_app/student/abroad_scholarships/chevening_scholarships.dart';
import 'package:scholar_match_app/student/abroad_scholarships/abroad_scholarships_screen.dart';







void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final router = GoRouter(
      routes: [
        GoRoute(
          path: '/',
          builder: (context, state) => const HomePage(),   
        ),
        //  GoRoute(
        //   path: '/',
        //   builder: (context, state) =>  practice__(), // i will comment this soon 
        // ),
        GoRoute(
          path: '/student_admin',
          builder: (context, state) => const StudentAdmin(),
        ),
        GoRoute(
          path: '/student',
          builder: (context, state) => const StudentScreen(),
        ),
      
        GoRoute(
          path: '/student_login',
          builder: (context, state) => const StudentLoginScreen(),
        ),
         GoRoute(
          path: '/student_forgot_pass',
          builder: (context, state) => const ForgotPasswordScreen(),
        ),
        GoRoute(
          path: '/student_sign_up',
          builder: (context, state) => StudentSignUpScreen(),
        ),
  GoRoute(
  path: '/student_dashboard',
  builder: (context, state) {
    final studentData = state.extra as Map<String, dynamic>;
    return StudentDashboardScreen(studentData: studentData);
  },
),

 GoRoute(
      path: '/uni-events',
      builder: (context, state) {
        final studentData = state.extra as Map<String, dynamic>;
        return UniEvents(studentData: studentData);
      },
    ),

    GoRoute(
      path: '/all_scholarships',
      name: 'all_scholarships',
      builder: (context, state) {
        final studentData = state.extra as Map<String, dynamic>;
        return AllScholarshipsScreen(studentData: studentData);
      },
    ),

    GoRoute(
      path: '/feedback',
      name: 'feedback',
      builder: (context, state) {
        final studentData = state.extra as Map<String, dynamic>;
        return FeedbackScreen(studentData: studentData);
      },
    ),

      GoRoute(
      path: '/visual_uni',
      name: 'visual_uni',
      builder: (context, state) {
        final studentData = state.extra as Map<String, dynamic>;
        return VisualUni(studentData: studentData);
      },
    ),




     GoRoute(
      path: '/all_chats',
      builder: (context, state) {
        final studentData = state.extra as Map<String, dynamic>;
        return all_chats(studentData: studentData);
      },
    ),

    
GoRoute(
  path: '/abroad_scholarships',
  builder: (context, state) {
    final data = state.extra as Map<String, dynamic>? ?? {};
    return AbroadScholarshipsScreen(studentData: data);
  },
),
GoRoute(
      path: '/sweden-scholarships',
      builder: (context, state) {
        final studentData = state.extra as Map<String, dynamic>? ?? {};
        return SwedenScholarshipsScreen(studentData: studentData);
      },
    ),
    GoRoute(
      path: '/turkey-scholarships',
      builder: (context, state) {
        final studentData = state.extra as Map<String, dynamic>? ?? {};
        return TurkeyScholarshipsScreen(studentData: studentData);
      },
    ),
    GoRoute(
      path: '/hungary-scholarships',
      builder: (context, state) {
        final studentData = state.extra as Map<String, dynamic>? ?? {};
        return HungaryScholarshipsScreen(studentData: studentData);
      },
    ),
    GoRoute(
      path: '/chevening-scholarship',
      builder: (context, state) {
        final studentData = state.extra as Map<String, dynamic>? ?? {};
        return CheveningScholarshipScreen(studentData: studentData);
      },
    ),
    GoRoute(
      path: '/erasmus-scholarship',
      builder: (context, state) {
        final studentData = state.extra as Map<String, dynamic>? ?? {};
        return ErasmusScholarshipScreen(studentData: studentData);
      },
    ),
    GoRoute(
      path: '/commonwealth-scholarship',
      builder: (context, state) {
        final studentData = state.extra as Map<String, dynamic>? ?? {};
        return CommonwealthScholarshipScreen(studentData: studentData);
      },
    ),
    GoRoute(
      path: '/rhodes-scholarship',
      builder: (context, state) {
        final studentData = state.extra as Map<String, dynamic>? ?? {};
        return RhodesScholarshipScreen(studentData: studentData);
      },
    ),





GoRoute(
  path: '/student-choose-uni',
  builder: (context, state) {
    final data = state.extra as Map<String, dynamic>;
    return StudentChooseUni(studentData: data);
  },
),

GoRoute(
  path: '/comsats-uni-dashboard',
  builder: (context, state) {
    final data = state.extra as Map<String, dynamic>;
    return ComsatsUniDashboard(studentData: data);
  },
),


GoRoute(
  path: '/comsats-uni',
  builder: (context, state) {
    final data = state.extra as Map<String, dynamic>;
    return ComsatsUni(studentData: data);
  },
),

   GoRoute(
      path: '/scholarships',
      builder: (context, state) {
        final studentData = state.extra as Map<String, dynamic>;
        return Comsats_ScholarshipScreen(studentData: studentData);
      },
    ),
    

    GoRoute(
  path: '/connect-alumni',
  builder: (context, state) {
    final studentData = state.extra! as Map<String, dynamic>;
    return ConnectAlumniScreen(studentData: studentData);
  },
),

   GoRoute(
      path: '/chat',
      builder: (context, state) {
        final data = state.extra as Map<String, dynamic>;
        return ChatScreen(
          currentStudent: data['currentStudent'],
          alumni: data['alumni'],
        );
      },
    ),


      GoRoute(
      path: '/uni_of_education_Dashboard',
      builder: (context, state) {
        final data = state.extra as Map<String, dynamic>;
        return uni_of_education(studentData: data);
      },
    ),

        GoRoute(
      path: '/uni_of_education_fee',
      builder: (context, state) {
        final data = state.extra as Map<String, dynamic>;
        return uni_of_education_fees(studentData: data);
      },
    ),

    GoRoute(
      path: '/uoe_scholarship',
      builder: (context, state) {
        final data = state.extra as Map<String, dynamic>;
        return UoeScholarships(studentData: data);
      },
    ),

     GoRoute(
      path: '/fast-uni-Dashboard',
      builder: (context, state) {
        final studentData = state.extra as Map<String, dynamic>;
        return fast_univeristy_dashboard(studentData: studentData);
      },
    ),

    GoRoute(
      path: '/FAST-uni-fees',
      builder: (context, state) {
        final studentData = state.extra as Map<String, dynamic>;
        return FastUniversityScreen(studentData: studentData);
      },
    ),

 GoRoute(
  path: '/fast_scholarship',
  builder: (context, state) {
    final studentData = state.extra as Map<String, dynamic>;
    return FAST_SCHOALRSHIPS(studentData: studentData);
  },
),

     GoRoute(
      path: '/nedfeesDashboard',
      builder: (context, state) {
        final studentData = state.extra as Map<String, dynamic>;
        return NedFeesDashboard(studentData: studentData);
      },
    ),

       GoRoute(
      path: '/nedfees',
      builder: (context, state) {
        final studentData = state.extra as Map<String, dynamic>;
        return NedFeesScreen(studentData: studentData);
      },
    ),
GoRoute(
  path: '/need-scholarships',
  builder: (context, state) {
    final studentData = state.extra as Map<String, dynamic>;
    return NedScholarshipsScreen(studentData: studentData);
  },
),

 GoRoute(
  path: '/air-uniDashboard',
  builder: (context, state) {
    final studentData = state.extra as Map<String, dynamic>;
    return air_univeristy(studentData: studentData);
  },
),
   

  GoRoute(
  path: '/air-uni-fee',
  builder: (context, state) {
    final studentData = state.extra as Map<String, dynamic>;
    return AirUniFees(studentData: studentData);
  },
),
   GoRoute(
      path: '/air-scholarship',
      builder: (context, state) {
        final studentData = state.extra as Map<String, dynamic>;
        return AIRScholarshipScreen(
          studentData: studentData
        );
      },
    ),

       GoRoute(
  path: '/nust-uniDashboard',
  builder: (context, state) {
    final studentData = state.extra as Map<String, dynamic>;
    return NustUniDashboard(studentData: studentData);
  },
),


    GoRoute(
  path: '/nust-uni',
  builder: (context, state) {
    final studentData = state.extra as Map<String, dynamic>;
    return NustUniScreen(studentData: studentData); 
  },
),

GoRoute(
  path: '/nust-scholarships',
  builder: (context, state) {
    final studentData = state.extra as Map<String, dynamic>;
    return NustScholarshipScreen(studentData: studentData);
  },
),

 GoRoute(
      path: '/lums-uniDashboard',
      builder: (context, state) {
        final data = state.extra as Map<String, dynamic>;
        return LumsDashboard(studentData: data);
      },
    ),

   GoRoute(
      path: '/lums-uni',
      builder: (context, state) {
        final data = state.extra as Map<String, dynamic>;
        return LumsPage(studentData: data);
      },
    ),

    GoRoute(
  path: '/lums-scholarships',
  builder: (context, state) {
    final studentData = state.extra as Map<String, dynamic>;
    return LumsScholarships(studentData: studentData);
  },
),

  GoRoute(
      path: '/uetDashboard',
      builder: (context, state) {
        final data = state.extra as Map<String, dynamic>;
        return UetDashboard(studentData: data);
      },
    ),


   GoRoute(
      path: '/uet-fee',
      builder: (context, state) {
        final data = state.extra as Map<String, dynamic>;
        return UetFeePage(studentData: data);
      },
    ),

    
GoRoute(
  path: '/uet-scholarships',
  builder: (context, state) {
    final studentData = state.extra as Map<String, dynamic>;
    return UetScholarships(studentData: studentData);
  },
),

 GoRoute(
      path: '/iiui-uniDashboard',
      builder: (context, state) {
        final studentData = state.extra as Map<String, dynamic>;
        return IIUIUniDashboard(studentData: studentData);
      },
    ),


   GoRoute(
      path: '/iiui-uni',
      builder: (context, state) {
        final studentData = state.extra as Map<String, dynamic>;
        return IIUIUni(studentData: studentData);
      },
    ),

    GoRoute(
      path: '/iiui-scholarships',
      builder: (context, state) {
        final studentData = state.extra as Map<String, dynamic>;
        return IIUIScholarships(studentData: studentData);
      },
    ),























        GoRoute(
      path: '/alumni',
      builder: (context, state) => const alumni_dashboard(), 
    ),

    GoRoute(
      path: '/alumni-signin',
      builder: (context, state) => const AlumniSignIn(),
    ),
    GoRoute(
      path: '/alumni-signup',
      builder: (context, state) => const AlumniSignUp(),
    ),
 GoRoute(
  path: '/alumni_home_screen',
  builder: (context, state) {
    final data = state.extra as Map<String, dynamic>;
    return AlumniHomeScreen(alumniData: data);
  },
),


  GoRoute(
  path: '/alumni-chats',
  builder: (context, state) {
    final alumniData = state.extra as Map<String, dynamic>;
    return AlumniChatsScreen(alumniData: alumniData);
  },
),
GoRoute(
  name: 'messageChat',
  path: '/message-chat',
  builder: (context, state) {
    final extra = state.extra as Map<String, dynamic>;
    return MessageChatScreen(
      alumniData: extra['alumniData'],
      chatId: extra['chatId'],
      otherEmail: extra['otherEmail'],
    );
  },
),


   GoRoute(
      path: '/all_uni_events',
      builder: (context, state) {
        final alumniData = state.extra as Map<String, dynamic>;
        return AllUniEventsScreen(alumniData: alumniData);
      },
    ),

     GoRoute(
      path: '/alumni-comsats-events',
      builder: (context, state) {
        final data = state.extra as Map<String, dynamic>;
        return ComsatsEvent(alumniData: data);
      },
    ),
    
    GoRoute(
  path: '/alumni-iqra-events',
  builder: (context, state) {
    final data = state.extra as Map<String, dynamic>;
    return AlumniIqraEvents(alumniData: data);
  },
),
GoRoute(
  path: '/alumni-ned-events',
  builder: (context, state) {
    final data = state.extra as Map<String, dynamic>;
    return AlumniNedEvents(alumniData: data);
  },
),
GoRoute(
  path: '/alumni-nust-events',
  builder: (context, state) {
    final data = state.extra as Map<String, dynamic>;
    return AlumniNustEvents(alumniData: data);
  },
),








 GoRoute(
  path: '/apply-alumni', 
  builder: (context, state) {
    final data = state.extra as Map<String, dynamic>;
    return ApplyAlumnii(
      alumniData: data['alumniData'],
      eventTitle: data['eventTitle'],
      eventDate: data['eventDate'],
    );
  },
),

GoRoute(
      path: '/events-applied',
      builder: (context, state) {
        final alumniData = state.extra as Map<String, dynamic>;
        return EventsApplied(alumniData: alumniData);
      },
    ),



    GoRoute(
      path: '/admin',
      builder: (context, state) {
        return admin();
      },
    ),

     GoRoute(
  path: '/admin_dashboard',
  builder: (context, state) {
    final data = state.extra as Map<String, dynamic>;
    return admin_dashboard(
      email: data['email'],
      password: data['password'],
    );
  },
),


     GoRoute(
  path: '/admin_check_all_users',
  builder: (context, state) {
    final data = state.extra as Map<String, dynamic>;
    return AdminCheckAllUsers(
      email: data['email'],
      password: data['password'],
    );
  },
),

    GoRoute(
  path: '/admin_check_user_feedback',
  builder: (context, state) {
    final data = state.extra as Map<String, dynamic>;
    return AdminCheckUserFeedback(
      email: data['email'],
      password: data['password'],
    );
  },
),








      
      
      ],
    );

    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      routerConfig: router, 
    );
  }
}


class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  void initState() {
    super.initState();

   
    Timer(const Duration(seconds: 3), () {
      context.go('/student_admin');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Colors.blue.shade900, Colors.purple.shade700],
          ),
        ),
        child: SafeArea(
          child: Stack(
            children: [
              Positioned(
                top: -50,
                left: -50,
                child: Container(
                  width: 200,
                  height: 200,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withOpacity(0.1),
                  ),
                ),
              ),
              Positioned(
                bottom: -100,
                right: -100,
                child: Container(
                  width: 300,
                  height: 300,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withOpacity(0.15),
                  ),
                ),
              ),
              Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Student Portal',
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          letterSpacing: 2,
                          shadows: [
                            Shadow(
                              color: Colors.black.withOpacity(0.3),
                              blurRadius: 5,
                              offset: const Offset(2, 2),
                            ),
                          ],
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 10),
                      Text(
                        '"Your journey to higher education starts here."',
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.white.withOpacity(0.9),
                          fontStyle: FontStyle.italic,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 20),
                      Text(
                        'Loading...',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.white.withOpacity(0.8),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
