import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:bharatnova/features/home/providers/post_provider.dart';
import 'package:bharatnova/features/home/providers/location_provider.dart';
import 'package:bharatnova/features/home/widgets/post_card.dart';
import 'package:bharatnova/features/home/widgets/shimmer_loading.dart';

import 'package:bharatnova/features/auth/providers/user_provider.dart';
import 'package:cached_network_image/cached_network_image.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen>
    with SingleTickerProviderStateMixin, WidgetsBindingObserver {
  late TabController _tabController;
  final ScrollController _scrollController = ScrollController();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _tabController = TabController(length: 4, vsync: this);
    _scrollController.addListener(_onScroll);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(locationServiceProvider).requestAllPermissions();
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      // Refresh location when app comes to foreground
      ref.invalidate(cityProvider);
    }
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      ref.read(postProvider.notifier).fetchMore();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _tabController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final postState = ref.watch(postProvider);
    final cityAsync = ref.watch(cityProvider);
    final user = ref.watch(currentUserProvider);

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: Colors.white,
      extendBody: true,
      drawer: _buildDrawer(user),
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.sort, color: Color(0xFF2E3192), size: 28),
          onPressed: () => _scaffoldKey.currentState?.openDrawer(),
        ),
        title: Image.asset(
          'assets/logo/bharatnova.png',
          height: 30,
          width: 100,
          errorBuilder: (context, error, stackTrace) => const Text(
            'BHARATNOVA',
            style: TextStyle(
              color: Color(0xFF2E3192),
              fontWeight: FontWeight.bold,
              letterSpacing: 1.2,
            ),
          ),
        ),
        centerTitle: true,
        actions: [
          Row(
            children: [
              const Icon(Icons.location_on, color: Color(0xFF2E3192), size: 18),
              const SizedBox(width: 4),
              cityAsync.when(
                data: (city) => Text(
                  city,
                  style: const TextStyle(
                    color: Colors.black87,
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
                loading: () =>
                    const Text('Loading...', style: TextStyle(fontSize: 12)),
                error: (_, __) => const Text('Mumbai'),
              ),
              const SizedBox(width: 16),
            ],
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          labelColor: const Color(0xFF2E3192),
          unselectedLabelColor: Colors.grey,
          indicatorColor: const Color(0xFF2E3192),
          indicatorWeight: 3,
          labelStyle: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
          tabs: const [
            Tab(text: 'Post'),
            Tab(text: 'Nova'),
            Tab(text: 'News'),
            Tab(text: 'Article'),
          ],
        ),
      ),
      body: RefreshIndicator(
        onRefresh: () =>
            ref.read(postProvider.notifier).fetchPosts(refresh: true),
        child: _buildFeed(postState),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.topCenter,
        children: [
          Container(
            height: 100,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(40),
              ), // Even more rounded
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withAlpha(90), // Slightly reduced
                  blurRadius: 15, // Reduced
                  spreadRadius: 2,
                  offset: const Offset(0, -6), // Reduced height
                ),
              ],
            ),
            child: Column(
              children: [
                Container(
                  height: 35,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.black.withAlpha(15), // Light inner shadow effect
                        Colors.white.withAlpha(5),
                        Colors.white,
                      ],
                    ),
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(40),
                    ),
                  ),
                ),
                Expanded(
                  child: BottomAppBar(
                    color: Colors.transparent,
                    elevation: 0,
                    height: 65,
                    padding: EdgeInsets.zero,
                    shape: const CircularNotchedRectangle(),
                    notchMargin: 0,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildNavIcon(Icons.home_filled, 0, ''),
                        _buildNavIcon(Icons.search, 1, ''),
                        _buildBNLogoIcon(2),
                        const SizedBox(width: 48), // Space for FAB
                        _buildNavIcon(Icons.play_circle_outline, 3, ''),
                        _buildNavIcon(Icons.notifications_none, 4, ''),
                        _buildProfileIcon(user, 5),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            top: 5, // FAB now sits well within the taller bar area
            child: _buildCustomFAB(),
          ),
        ],
      ),
    );
  }

  Widget _buildCustomFAB() {
    return Container(
      height: 64,
      width: 64,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(40),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(4),
      child: Container(
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
          color: Color(0xFF2E3192),
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            ...List.generate(24, (index) {
              return Transform.rotate(
                angle: (index * 15) * 3.14159 / 180,
                child: Container(
                  height: 50,
                  width: 1,
                  color: Colors.white.withAlpha(30),
                ),
              );
            }),
            Container(
              width: 24,
              height: 24,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white,
              ),
              child: const Icon(
                Icons.add,
                color: Color(0xFF2E3192),
                size: 20,
                weight: 800,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDrawer(dynamic user) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          UserAccountsDrawerHeader(
            decoration: const BoxDecoration(color: Color(0xFF2E3192)),
            currentAccountPicture: CircleAvatar(
              backgroundImage: user?.photoURL != null
                  ? CachedNetworkImageProvider(user!.photoURL!)
                  : null,
              child: user?.photoURL == null ? const Icon(Icons.person) : null,
            ),
            accountName: Text(user?.displayName ?? 'Guest User'),
            accountEmail: Text(user?.email ?? ''),
          ),
          ListTile(
            leading: const Icon(Icons.collections_bookmark),
            title: const Text('Feed Collection'),
            onTap: () => Navigator.pop(context),
          ),
          ListTile(
            leading: const Icon(Icons.settings),
            title: const Text('Settings'),
            onTap: () => Navigator.pop(context),
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: const Text('Logout', style: TextStyle(color: Colors.red)),
            onTap: () => _showLogoutConfirmation(context),
          ),
        ],
      ),
    );
  }

  void _showLogoutConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context); // Close dialog
              await ref.read(authServiceProvider).signOut();
              if (mounted) Navigator.pushReplacementNamed(context, '/login');
            },
            child: const Text('Logout', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  Widget _buildFeed(PostState state) {
    if (state.isLoading && state.posts.isEmpty) {
      return const ShimmerLoading();
    }

    if (state.errorMessage != null && state.posts.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Error: ${state.errorMessage}'),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () =>
                  ref.read(postProvider.notifier).fetchPosts(refresh: true),
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      controller: _scrollController,
      itemCount: state.posts.length + (state.hasReachedMax ? 0 : 1),
      itemBuilder: (context, index) {
        if (index == state.posts.length) {
          return const Padding(
            padding: EdgeInsets.all(16.0),
            child: Center(child: CircularProgressIndicator()),
          );
        }
        return PostCard(post: state.posts[index]);
      },
    );
  }

  Widget _buildNavIcon(IconData icon, int index, String label) {
    bool isSelected = _selectedIndex == index;
    return InkWell(
      onTap: () => setState(() => _selectedIndex = index),
      child: Icon(
        icon,
        color: isSelected ? const Color(0xFF2E3192) : Colors.grey,
        size: 28,
      ),
    );
  }

  Widget _buildBNLogoIcon(int index) {
    bool isSelected = _selectedIndex == index;
    return InkWell(
      onTap: () => setState(() => _selectedIndex = index),
      child: Image.asset(
        'assets/images/bn.png',
        width: 32,
        height: 32,
        // Removed color filter to show original logo colors if it's a colorful logo
        // but if it's a monochrome logo, we can keep the isSelected color
        errorBuilder: (context, error, stackTrace) => Text(
          'BN',
          style: TextStyle(
            color: isSelected ? const Color(0xFF2E3192) : Colors.grey,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
      ),
    );
  }

  Widget _buildProfileIcon(dynamic user, int index) {
    bool isSelected = _selectedIndex == index;
    return InkWell(
      onTap: () => setState(() => _selectedIndex = index),
      child: Container(
        padding: const EdgeInsets.all(2),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: isSelected ? const Color(0xFF2E3192) : Colors.transparent,
            width: 2,
          ),
        ),
        child: CircleAvatar(
          radius: 12,
          backgroundImage: user?.photoURL != null
              ? CachedNetworkImageProvider(user!.photoURL!)
              : null,
          child: user?.photoURL == null
              ? const Icon(Icons.person, size: 14)
              : null,
        ),
      ),
    );
  }
}
