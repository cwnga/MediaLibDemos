
!!! PLEASE USE THE NEXT VERSION !!!

MedialibiOS3x - https://github.com/slavavdovichenko/MediaLibDemos3x
supported: video codecs: H264, H.263 (Sorenson), audio codecs: AAC, Speex, Nelly Moser

=============
MediaLibDemos
=============

Media Library for iOS provides the classes and protocols for media live stream publishing and playback, or VOD recording and playback, via RTMP. 
It allows the iOS devices to interact with the media servers: Adobe FMS, Wowza MS, Red5, crtmp, rtmpd.

Media Library for iOS uses the classes and protocols of Communication Library for iOS (see Communication Library for iOS User Guide).

The library imposes the following requirements on the iOS applications utilizing it:
1.	iOS Deployment Target - 6.0 or above;
2.	the following frameworks and libraries must be added to the list of libraries linked to the binary:
-	AudioToolbox.framework, AVFoundation.framework, CFNetwork.framework, CoreData.framework, CoreGraphics.framework, CoreMedia.framework, CoreVideo.framework, Foundation.framework, Security.framework, libiconv.2.4.0.dylib, libz.dylib;
-	The Midnight Coders static libraries: CommLibiOS.a, MediaLibiOS.a;
-	the FFmpeg/Libav static libraries: libavcodec.a, libavdevice.a, libavfilter.a, libavformat.a, libavutil.a, libswscale.a
