import 'package:flutter/material.dart';
import 'package:bharatnova/models/post.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:intl/intl.dart';

import 'package:share_plus/share_plus.dart';

class PostCard extends StatefulWidget {
  final Post post;

  const PostCard({super.key, required this.post});

  @override
  State<PostCard> createState() => _PostCardState();
}

class _PostCardState extends State<PostCard> {
  bool _isExpanded = false;
  bool _isLiked = false;
  bool _isCollected = false;
  late int _likeCount;
  late int _commentCount;
  late int _collectionCount;
  final PageController _pageController = PageController();
  int _currentImageIndex = 0;

  @override
  void initState() {
    super.initState();
    _likeCount = widget.post.likes;
    _commentCount = widget.post.comments;
    _collectionCount = 12; // Mock initial collection count
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _handleLike() {
    setState(() {
      _isLiked = !_isLiked;
      if (_isLiked) {
        _likeCount++;
      } else {
        _likeCount--;
      }
    });
  }

  void _handleCollection() {
    setState(() {
      _isCollected = !_isCollected;
      if (_isCollected) {
        _collectionCount++;
      } else {
        _collectionCount--;
      }
    });
  }

  void _handleComment() {
    _showCommentBottomSheet();
  }

  void _showCommentBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        minChildSize: 0.4,
        maxChildSize: 0.95,
        builder: (_, controller) => Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              Container(
                margin: const EdgeInsets.only(top: 12),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const Padding(
                padding: EdgeInsets.all(16.0),
                child: Text(
                  'Comments',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
              const Divider(height: 1),
              Expanded(
                child: ListView.builder(
                  controller: controller,
                  itemCount: 5, // Mock comments
                  itemBuilder: (context, index) => ListTile(
                    leading: const CircleAvatar(radius: 16),
                    title: Text(
                      'User $index',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: const Text(
                      'This is a great post! Interesting read.',
                    ),
                    trailing: Text(
                      '${index + 1}h',
                      style: const TextStyle(color: Colors.grey, fontSize: 12),
                    ),
                  ),
                ),
              ),
              _buildCommentInput(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCommentInput() {
    return Container(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom + 16,
        top: 12,
        left: 16,
        right: 16,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(13),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Row(
        children: [
          const CircleAvatar(radius: 18),
          const SizedBox(width: 12),
          Expanded(
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Add a comment...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Colors.grey[100],
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
              ),
              onSubmitted: (value) {
                if (value.isNotEmpty) {
                  setState(() {
                    _commentCount++;
                  });
                  Navigator.pop(context);
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  void _handleShare() {
    Share.share(
      '${widget.post.title}\n\n${widget.post.body}\n\nRead more on BharatNova',
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (widget.post.isReposted)
            Padding(
              padding: const EdgeInsets.only(left: 18.0, bottom: 4.0),
              child: Row(
                children: [
                  const Icon(Icons.repeat, size: 14, color: Colors.grey),
                  const SizedBox(width: 8),
                  Text(
                    'You Reposted',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          _buildHeader(),
          _buildContent(),
          if (widget.post.imageUrl != null) ...[
            _buildImageSlider(),
            _buildPaginationDots(),
          ],
          _buildFooter(),
          const Divider(height: 1, color: Color(0xFFF0F0F0)),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            backgroundImage: CachedNetworkImageProvider(widget.post.userAvatar),
            radius: 22,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        widget.post.userName,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          height: 1.1,
                        ),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                    ),
                    const SizedBox(width: 4),
                    const Icon(
                      Icons.account_circle,
                      color: Color(0xFF2E3192),
                      size: 16,
                    ),
                  ],
                ),
                Text(
                  widget.post.userHandle,
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 13,
                    height: 1.0,
                  ),
                ),
                const SizedBox(height: 1), // Tight gap
                Row(
                  children: [
                    Icon(Icons.location_on, color: Colors.grey[600], size: 12),
                    Flexible(
                      child: Text(
                        ' ${widget.post.location}',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 13,
                          height: 1.0,
                        ),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Text(
            DateTime.now().difference(widget.post.createdAt).inDays < 7
                ? '${DateTime.now().difference(widget.post.createdAt).inDays}d'
                : DateFormat('d MMM yyyy').format(widget.post.createdAt),
            style: TextStyle(color: Colors.grey[600], fontSize: 13),
          ),
          const SizedBox(width: 8),
          const Icon(Icons.more_vert, color: Colors.grey),
        ],
      ),
    );
  }

  Widget _buildContent() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.post.body,
            maxLines: _isExpanded ? null : 4,
            overflow: _isExpanded
                ? TextOverflow.visible
                : TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 15, height: 1.4),
          ),
          const SizedBox(height: 4),
          GestureDetector(
            onTap: () {
              setState(() {
                _isExpanded = !_isExpanded;
              });
            },
            child: Text(
              _isExpanded ? 'Show Less' : 'Read More',
              style: const TextStyle(
                color: Color(0xFF2E3192),
                fontWeight: FontWeight.w600,
                decoration: TextDecoration.underline,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImageSlider() {
    // Mocking 4 images for the demonstration as requested
    final List<String> imageUrls = [
      widget.post.imageUrl!,
      '${widget.post.imageUrl!}?sig=1',
      '${widget.post.imageUrl!}?sig=2',
      '${widget.post.imageUrl!}?sig=3',
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Stack(
        children: [
          SizedBox(
            height: 350,
            child: PageView.builder(
              controller: _pageController,
              itemCount: imageUrls.length,
              onPageChanged: (index) {
                setState(() {
                  _currentImageIndex = index;
                });
              },
              itemBuilder: (context, index) {
                return CachedNetworkImage(
                  imageUrl: imageUrls[index],
                  width: double.infinity,
                  fit: BoxFit.cover,
                  placeholder: (context, url) =>
                      Container(color: Colors.grey[200]),
                );
              },
            ),
          ),
          Positioned(
            top: 10,
            right: 10,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.black54,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '${_currentImageIndex + 1}/${imageUrls.length}',
                style: const TextStyle(color: Colors.white, fontSize: 12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaginationDots() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(4, (index) {
          return Container(
            margin: const EdgeInsets.symmetric(horizontal: 2),
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: index == _currentImageIndex
                  ? const Color(0xFF2E3192)
                  : Colors.grey[300],
            ),
          );
        }),
      ),
    );
  }

  Widget _buildFooter() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _buildActionItem(
            _isLiked ? Icons.favorite : Icons.favorite_border,
            _likeCount.toString(),
            color: _isLiked ? Colors.red : null,
            onTap: _handleLike,
          ),
          _buildActionItem(
            Icons.chat_bubble_outline,
            _commentCount.toString(),
            onTap: _handleComment,
          ),
          _buildActionItem(Icons.repeat, widget.post.reposts.toString()),
          _buildActionItem(
            Icons.remove_red_eye_outlined,
            widget.post.views.toString(),
          ),
          _buildActionItem(
            _isCollected
                ? Icons.collections_bookmark
                : Icons.collections_bookmark_outlined,
            _collectionCount.toString(),
            color: _isCollected ? const Color(0xFF2E3192) : null,
            onTap: _handleCollection,
          ),
          _buildActionItem(Icons.share_outlined, 'Share', onTap: _handleShare),
        ],
      ),
    );
  }

  Widget _buildActionItem(
    IconData icon,
    String count, {
    Color? color,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Row(
        children: [
          Icon(
            icon,
            size: 16,
            color: color ?? Colors.grey[600],
          ), // Reduced size from 20
          if (count.isNotEmpty) ...[
            const SizedBox(width: 2),
            Text(
              count,
              style: TextStyle(
                color: color ?? Colors.grey[600],
                fontSize: 12,
              ), // Reduced size from 13
            ),
          ],
        ],
      ),
    );
  }
}
