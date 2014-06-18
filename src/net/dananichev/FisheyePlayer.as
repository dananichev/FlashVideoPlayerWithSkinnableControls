package net.dananichev {

import net.dananichev.media.VideoPlayerFisheye;

import flash.display.*;
import flash.media.Video;
import flash.events.*;
import flash.geom.Vector3D;
import flash.system.*;

/**
 * @author ericpetersen
 */
[SWF(backgroundColor="#000000", frameRate="60", width="1024", height="768")]
public class FisheyePlayer extends MovieClip {
    private var _videoPlayerFisheye:VideoPlayerFisheye;
    private var _videoWidth:Number = 320;
    private var _videoHeight:Number = 240;

    /**
     * VideoPlayerWithControls example
     */
    public function FisheyePlayer() {
        stage.scaleMode = StageScaleMode.NO_SCALE;
        stage.align = StageAlign.TOP_LEFT;

        Security.loadPolicyFile('http://school-edge.netlab/crossdomain.xml');
        Security.allowDomain('*');

        _videoPlayerFisheye = new VideoPlayerFisheye(_videoWidth, _videoHeight);
        _videoPlayerFisheye.x = 50;
        _videoPlayerFisheye.y = 50;
        addChild(_videoPlayerFisheye);

        _videoPlayerFisheye.loadVideo("jim", true, "rtmp://rtmp.jim.stream.vmmacdn.be/vmma-jim-rtmplive-live");
    }

}
}
