package net.ericpetersen {
	import net.ericpetersen.media.videoPlayer.VideoPlayerWithControls;
	import net.ericpetersen.media.videoPlayer.controls.VideoPlayerControls;

    import flash.display.*;
    import flash.media.Video;
    import flash.events.*;
    import flash.geom.Vector3D;
    import flash.system.*;

    import away3d.animators.*;
    import away3d.animators.data.*;
    import away3d.animators.nodes.*;
    import away3d.cameras.*;
    import away3d.containers.*;
    import away3d.controllers.*;
    import away3d.core.base.*;
    import away3d.debug.*;
    import away3d.entities.*;
    import away3d.materials.*;
    import away3d.materials.lightpickers.*;
    import away3d.tools.helpers.*;
    import away3d.utils.*;
    import away3d.primitives.*;
    import away3d.textures.*;

	/**
	 * @author ericpetersen
	 */
    [SWF(backgroundColor="#000000", frameRate="60", width="1024", height="768")]
	public class VideoPlayerWithControlsExample extends MovieClip {
		private var _videoPlayerWithControls:VideoPlayerWithControls;
		private var _videoWidth:Number = 320;
		private var _videoHeight:Number = 240;

		/**
		 * VideoPlayerWithControls example 
		 */
		public function VideoPlayerWithControlsExample() {
			stage.scaleMode = StageScaleMode.NO_SCALE;
			stage.align = StageAlign.TOP_LEFT;

            Security.loadPolicyFile('http://school-edge.netlab/crossdomain.xml');
            Security.allowDomain('*');

			var controlsAsset:MovieClip = new VideoPlayerControlsAsset();
			var videoPlayerControls:VideoPlayerControls = new VideoPlayerControls(controlsAsset, _videoWidth, true);
			_videoPlayerWithControls = new VideoPlayerWithControls(videoPlayerControls, _videoWidth, _videoHeight);
			_videoPlayerWithControls.x = 50;
			_videoPlayerWithControls.y = 50;
			addChild(_videoPlayerWithControls);
			
			/*
			 * Load the video
			 * Progressive: loadVideo("video/video01.flv");
			 * Streaming from rtmp://appName/streamName.flv: loadVideo("streamName", true, "rtmp://appName"); // streamName does not include ".flv"
			 */
			_videoPlayerWithControls.loadVideo("jim", true, "rtmp://rtmp.jim.stream.vmmacdn.be/vmma-jim-rtmplive-live");

		}

	}
}
