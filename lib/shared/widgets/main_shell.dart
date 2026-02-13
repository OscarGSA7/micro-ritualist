import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../features/dashboard/presentation/screens/dashboard_screen.dart';
import '../../features/dashboard/presentation/screens/rituals_screen.dart';
import '../../features/profile/presentation/screens/profile_screen.dart';
import '../../features/settings/presentation/screens/settings_screen.dart';
import '../../features/rituals/presentation/screens/create_ritual_screen.dart';
import 'app_bottom_navigation.dart';

/// Shell principal de la aplicación
/// 
/// Contiene el BottomNavigationBar persistente y maneja la navegación
/// entre las pantallas principales de la app
class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _currentIndex = NavIndex.home.value;
  
  // Controlador de PageView para transiciones suaves
  late final PageController _pageController;
  
  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: _currentIndex);
  }
  
  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  /// Maneja la navegación al tocar un item del bottom nav
  void _onNavTap(int index) {
    // Si es el botón de añadir, mostramos modal en lugar de cambiar de página
    if (index == NavIndex.addRitual.value) {
      _showCreateRitualModal();
      return;
    }
    
    setState(() {
      _currentIndex = index;
    });
    
    // Calcular el índice de página (excluyendo el botón de añadir)
    int pageIndex = index;
    if (index > NavIndex.addRitual.value) {
      pageIndex = index - 1;
    }
    
    // Navegar con animación
    _pageController.animateToPage(
      pageIndex,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }
  
  /// Muestra el modal para crear un nuevo ritual
  void _showCreateRitualModal() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.9,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        builder: (context, scrollController) => Container(
          decoration: BoxDecoration(
            color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(24),
            ),
          ),
          child: CreateRitualScreen(
            scrollController: scrollController,
            onRitualCreated: (ritual) {
              Navigator.pop(context);
              // TODO: Añadir el ritual a la lista
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Rutina "${ritual.title}" creada'),
                  backgroundColor: AppColors.success,
                ),
              );
            },
            onCancel: () => Navigator.pop(context),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.lightBackground,
      extendBody: true,
      body: PageView(
        controller: _pageController,
        physics: const NeverScrollableScrollPhysics(), // Deshabilitar swipe
        children: const [
          // Página 0: Dashboard/Inicio
          DashboardScreen(),
          
          // Página 1: Rituales
          RitualsScreen(),
          
          // Página 2: Perfil (el índice 2 del nav es el botón +, así que perfil es página 2)
          ProfileScreen(),

          // Página 3: Configuración
          SettingsScreen(),
        ],
      ),
      bottomNavigationBar: AppBottomNavigation(
        currentIndex: _currentIndex,
        onTap: _onNavTap,
      ),
    );
  }
}
