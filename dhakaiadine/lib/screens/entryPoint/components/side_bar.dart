import 'package:flutter/material.dart';

import '../../../model/menu.dart';
import '../../../routes/app_router.dart';
import '../../../utils/rive_utils.dart';
import 'info_card.dart';
import 'side_menu.dart';

import '../../../services/auth_service.dart';

class SideBar extends StatefulWidget {
  const SideBar({super.key});

  @override
  State<SideBar> createState() => _SideBarState();
}

class _SideBarState extends State<SideBar> {
  Menu selectedSideMenu = sidebarMenus.first;
  String userName = "Loading...";
  String userEmail = "";

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  Future<void> _loadUser() async {
    final authService = AuthService.instance;
    final uid = authService.currentUserId;
    if (uid != null) {
      try {
        final profile = await authService.getUserProfile(uid);
        if (profile != null && mounted) {
          setState(() {
            userName = profile['name'] as String? ?? "User";
            userEmail = profile['email'] as String? ?? authService.currentUserEmail ?? "";
          });
        }
      } catch (e) {
        if (mounted) {
          setState(() {
            userName = "User";
            userEmail = authService.currentUserEmail ?? "";
          });
        }
      }
    } else {
      if (mounted) {
        setState(() {
          userName = "Guest";
          userEmail = authService.currentUserEmail ?? "";
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        width: 288,
        height: double.infinity,
        decoration: const BoxDecoration(
          color: Color(0xFFFFF8E1),
          borderRadius: BorderRadius.all(Radius.circular(30)),
        ),
        child: DefaultTextStyle(
          style: const TextStyle(color: Color(0xFF212121)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              InfoCard(name: userName, bio: userEmail),
              Padding(
                padding: const EdgeInsets.only(left: 24, top: 32, bottom: 16),
                child: Text(
                  "Browse".toUpperCase(),
                  style: Theme.of(
                    context,
                  ).textTheme.titleMedium!.copyWith(color: Color(0xFF757575)),
                ),
              ),
              ...sidebarMenus.map(
                (menu) => SideMenu(
                  menu: menu,
                  selectedMenu: selectedSideMenu,
                  press: () {
                    RiveUtils.chnageSMIBoolState(menu.rive.status!);
                    setState(() {
                      selectedSideMenu = menu;
                    });

                    switch (menu.title) {
                      case 'Home':
                        Navigator.pushNamed(context, AppRouter.home);
                        break;
                      case 'Search':
                        Navigator.pushNamed(context, AppRouter.search);
                        break;
                      case 'Favorites':
                        Navigator.pushNamed(context, AppRouter.favorites);
                        break;
                      case 'Help':
                        Navigator.pushNamed(context, AppRouter.help);
                        break;
                    }
                  },
                  riveOnInit: (artboard) {
                    menu.rive.status = RiveUtils.getRiveInput(
                      artboard,
                      stateMachineName: menu.rive.stateMachineName,
                    );
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 24, top: 40, bottom: 16),
                child: Text(
                  "History".toUpperCase(),
                  style: Theme.of(
                    context,
                  ).textTheme.titleMedium!.copyWith(color: Color(0xFF757575)),
                ),
              ),
              ...sidebarMenus2.map(
                (menu) => SideMenu(
                  menu: menu,
                  selectedMenu: selectedSideMenu,
                  press: () {
                    RiveUtils.chnageSMIBoolState(menu.rive.status!);
                    setState(() {
                      selectedSideMenu = menu;
                    });

                    switch (menu.title) {
                      case 'History':
                        Navigator.pushNamed(context, AppRouter.orderHistory);
                        break;
                      case 'Notifications':
                        Navigator.pushNamed(context, AppRouter.notifications);
                        break;
                    }
                  },
                  riveOnInit: (artboard) {
                    menu.rive.status = RiveUtils.getRiveInput(
                      artboard,
                      stateMachineName: menu.rive.stateMachineName,
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
