import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:bharatnova/models/post.dart';
import 'package:bharatnova/services/post_service.dart';

class PostState {
  final List<Post> posts;
  final bool isLoading;
  final bool isFetchingMore;
  final String? errorMessage;
  final int skip;
  final bool hasReachedMax;

  PostState({
    required this.posts,
    required this.isLoading,
    required this.isFetchingMore,
    this.errorMessage,
    required this.skip,
    required this.hasReachedMax,
  });

  PostState copyWith({
    List<Post>? posts,
    bool? isLoading,
    bool? isFetchingMore,
    String? errorMessage,
    int? skip,
    bool? hasReachedMax,
  }) {
    return PostState(
      posts: posts ?? this.posts,
      isLoading: isLoading ?? this.isLoading,
      isFetchingMore: isFetchingMore ?? this.isFetchingMore,
      errorMessage: errorMessage,
      skip: skip ?? this.skip,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
    );
  }
}

class PostNotifier extends StateNotifier<PostState> {
  final PostService _postService;
  static const int _limit = 10;

  PostNotifier(this._postService)
    : super(
        PostState(
          posts: [],
          isLoading: true,
          isFetchingMore: false,
          skip: 0,
          hasReachedMax: false,
        ),
      ) {
    fetchPosts();
  }

  Future<void> fetchPosts({bool refresh = false}) async {
    if (refresh) {
      state = state.copyWith(
        isLoading: true,
        skip: 0,
        hasReachedMax: false,
        posts: [],
      );
    }

    try {
      final newPosts = await _postService.fetchPosts(
        skip: state.skip,
        limit: _limit,
      );

      if (newPosts.isEmpty) {
        state = state.copyWith(isLoading: false, hasReachedMax: true);
      } else {
        state = state.copyWith(
          isLoading: false,
          posts: [...state.posts, ...newPosts],
          skip: state.skip + _limit,
          hasReachedMax: newPosts.length < _limit,
        );
      }
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
    }
  }

  Future<void> fetchMore() async {
    if (state.isFetchingMore || state.hasReachedMax) return;

    state = state.copyWith(isFetchingMore: true);
    try {
      final newPosts = await _postService.fetchPosts(
        skip: state.skip,
        limit: _limit,
      );
      if (newPosts.isEmpty) {
        state = state.copyWith(isFetchingMore: false, hasReachedMax: true);
      } else {
        state = state.copyWith(
          isFetchingMore: false,
          posts: [...state.posts, ...newPosts],
          skip: state.skip + _limit,
          hasReachedMax: newPosts.length < _limit,
        );
      }
    } catch (e) {
      state = state.copyWith(isFetchingMore: false, errorMessage: e.toString());
    }
  }
}

final postServiceProvider = Provider((ref) => PostService());

final postProvider = StateNotifierProvider<PostNotifier, PostState>((ref) {
  return PostNotifier(ref.watch(postServiceProvider));
});
