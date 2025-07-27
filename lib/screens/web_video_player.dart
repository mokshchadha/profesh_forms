// import 'dart:ui';

// import 'package:camera/camera.dart';
// import 'package:chewie/chewie.dart';
// import 'package:flutter/foundation.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:profesh/components/app_bars.dart';
// import 'package:profesh/components/button.dart';
// import 'package:profesh/components/scaffold_bg.dart';
// import 'package:profesh/constants.dart';
// import 'package:profesh/screens/login.dart';
// import 'package:profesh/screens/web_flow/web_video_loader.dart';
// import 'package:video_player/video_player.dart';

// class WebVideoPlayer extends ConsumerStatefulWidget {
//   static const route = "web-video";

//   final String url;
//   final bool isVideoUpload;
//   XFile? videoFile;
//   WebVideoPlayer(
//       {super.key,
//       required this.url,
//       required this.isVideoUpload,
//       this.videoFile});

//   @override
//   ConsumerState<WebVideoPlayer> createState() => _WebVideoPlayerState();
// }

// class _WebVideoPlayerState extends ConsumerState<WebVideoPlayer> {
//   late VideoPlayerController _videoPlayerController;
//   ChewieController? _chewieController;
//   final _isUploading = ValueNotifier<bool>(false);

//   @override
//   void initState() {
//     super.initState();
//     _initializePlayer();
//   }

//   Future<void> _initializePlayer() async {
//     _videoPlayerController =
//         VideoPlayerController.networkUrl(Uri.parse(widget.url));
//     bool isIphone = defaultTargetPlatform == TargetPlatform.iOS;
//     await _videoPlayerController.initialize();
//     _chewieController = ChewieController(
//       videoPlayerController: _videoPlayerController,
//       autoPlay: (widget.isVideoUpload) ? !isIphone : true,
//       looping: true,
//       showControls: isIphone,
//       showControlsOnInitialize: false,
//       allowPlaybackSpeedChanging: false,
//     );
//     setState(() {});
//   }

//   @override
//   void dispose() {
//     _videoPlayerController.dispose();
//     _chewieController?.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return ScaffoldWithBG(
//         image: Images.bgBlack.assetImage,
//         appBar: TransparentAppBar(
//           title: Text(
//             widget.isVideoUpload ? 'Upload' : 'Apply to Jobs',
//             style: const TextStyle(color: Colors.white),
//           ),
//           iconColor: Colors.white,
//         ),
//         body: SafeArea(
//             child: Column(
//           children: [
//             Expanded(
//               child: Padding(
//                 padding: const EdgeInsets.symmetric(horizontal: 12),
//                 child: Container(
//                   height: double.infinity,
//                   width: double.infinity,
//                   decoration: const BoxDecoration(
//                     color: Colors.black,
//                   ),
//                   child: Center(
//                     child: _chewieController != null &&
//                             _chewieController!
//                                 .videoPlayerController.value.isInitialized
//                         ? Stack(
//                             children: [
//                               Chewie(
//                                 controller: _chewieController!,
//                               ),
//                             ],
//                           )
//                         : const CircularProgressIndicator(),
//                   ),
//                 ),
//               ),
//             ),
//             Padding(
//               padding: EdgeInsets.only(
//                 bottom: MediaQuery.of(context).viewInsets.bottom,
//               ),
//               child: Container(
//                 padding: const EdgeInsets.symmetric(horizontal: 16),
//                 color: Colors.black,
//                 width: double.infinity,
//                 height: 75,
//                 child: Center(
//                     child: SizedBox(
//                   width: double.infinity,
//                   child: Button(
//                     onClick: () async {
//                       if (widget.isVideoUpload == true) {
//                         await _videoPlayerController.pause();
//                         Navigator.push(
//                           context,
//                           MaterialPageRoute(
//                             builder: (context) => WebVideoLoader(
//                               videoFile: widget.videoFile,
//                             ),
//                           ),
//                         );
//                       } else {
//                         await _videoPlayerController.pause();
//                         Navigator.pushNamed(context, LoginScreen.route);
//                       }
//                     },
//                     child: Text(
//                       widget.isVideoUpload ? 'Upload' : 'Next',
//                       style: TextStyle(
//                           color: ThemeColors.malachite.color,
//                           fontWeight: FontWeight.w600,
//                           fontSize: 16),
//                     ),
//                   ),
//                 )),
//               ),
//             )
//           ],
//         )));
//   }
// }