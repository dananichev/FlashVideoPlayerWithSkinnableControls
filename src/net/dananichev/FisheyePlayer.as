package net.dananichev {

import net.dananichev.media.VideoPlayerFisheye;

import flash.display.*;
import flash.media.Video;
import flash.events.*;
import flash.geom.Vector3D;
import flash.system.*;

/**
 * @author dananichev
 */
[SWF(backgroundColor="#000000", frameRate="60", width="1024", height="768")]
public class FisheyePlayer extends MovieClip {
    private var _videoPlayerFisheye:VideoPlayerFisheye;
    private var _videoWidth:Number = 1024;
    private var _videoHeight:Number = 1024;

    /**
     * VideoPlayerWithControls example
     */
    public function FisheyePlayer() {
        stage.scaleMode = StageScaleMode.NO_SCALE;
        stage.align = StageAlign.TOP_LEFT;

//        Security.loadPolicyFile('http://school-edge.netlab/crossdomain.xml');
        Security.loadPolicyFile('http://66.55.163.226/crossdomain.xml');
//        Security.loadPolicyFile('http://66.55.163.226:180/crossdomain.xml');
        Security.allowDomain('*');

        _videoPlayerFisheye = new VideoPlayerFisheye(_videoWidth, _videoHeight);
        _videoPlayerFisheye.x = 50;
        _videoPlayerFisheye.y = 50;
        addChild(_videoPlayerFisheye);

//        _videoPlayerFisheye.loadVideo("jim", true, "rtmp://rtmp.jim.stream.vmmacdn.be/vmma-jim-rtmplive-live");
        _videoPlayerFisheye.loadVideo("high", true, "rtmp://66.55.163.226:1935/cam13");
    }

}
}
