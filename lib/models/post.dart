class Post {
  final int id;
  final String title;
  final String body;
  final int userId;
  final List<String> tags;
  final int reactions;
  final String userName;
  final String userHandle;
  final String userAvatar;
  final String? imageUrl;
  final DateTime createdAt;
  final int likes;
  final int comments;
  final int reposts;
  final int shares;
  final int views;
  final String? location;
  final bool isReposted;

  Post({
    required this.id,
    required this.title,
    required this.body,
    required this.userId,
    required this.tags,
    required this.reactions,
    required this.userName,
    required this.userHandle,
    required this.userAvatar,
    this.imageUrl,
    required this.createdAt,
    required this.likes,
    required this.comments,
    required this.reposts,
    required this.shares,
    required this.views,
    this.location,
    this.isReposted = false,
  });

  factory Post.fromDynamicJson(
    Map<String, dynamic> postJson,
    Map<String, dynamic> userJson,
    int index,
  ) {
    final nameData = userJson['name'];
    final firstName = nameData['first'] ?? 'User';
    final lastName = nameData['last'] ?? '';
    final email = userJson['email'] ?? '';
    final handle = email.isNotEmpty
        ? email.split('@')[0]
        : firstName.toLowerCase();
    final locationData = userJson['location'];
    final city = locationData['city'] ?? 'Mumbai';
    final country = locationData['country'] ?? 'India';

    return Post(
      id: postJson['id'],
      title: postJson['title'],
      body: postJson['body'],
      userId: postJson['userId'],
      tags: List<String>.from(postJson['tags'] ?? []),
      reactions: postJson['reactions'] is int
          ? postJson['reactions']
          : (postJson['reactions']['likes'] ?? 0),
      userName: '$firstName $lastName',
      userHandle: '@$handle',
      userAvatar:
          userJson['picture']['large'] ??
          'https://i.pravatar.cc/150?u=${postJson['userId']}',
      imageUrl: index % 2 == 0
          ? 'https://picsum.photos/seed/${postJson['id']}/800/600'
          : null,
      createdAt: index % 3 == 0
          ? DateTime.now().subtract(Duration(days: index)) // Recent
          : DateTime.now().subtract(
              Duration(days: 100 + (index * 20)),
            ), // Older dates
      likes:
          (postJson['reactions'] is int
              ? postJson['reactions']
              : (postJson['reactions']['likes'] ?? 0)) +
          100,
      comments: 10 + index,
      reposts: 5 + index,
      shares: 15 + index,
      views: 1000 + (index * 50),
      location: '$city, $country',
      isReposted: index % 4 == 0,
    );
  }

  // Keeping old fromJson for backward compatibility if needed, but updating it to use random values if called
  factory Post.fromJson(Map<String, dynamic> json, int index) {
    return Post(
      id: json['id'],
      title: json['title'],
      body: json['body'],
      userId: json['userId'],
      tags: List<String>.from(json['tags'] ?? []),
      reactions: 0,
      userName: 'User $index',
      userHandle: '@user$index',
      userAvatar: 'https://i.pravatar.cc/150?u=${json['userId']}',
      createdAt: DateTime.now(),
      likes: 0,
      comments: 0,
      reposts: 0,
      shares: 0,
      views: 0,
      location: 'India',
    );
  }
}
