package net.dananichev.media {

import flash.events.MouseEvent;

import net.ericpetersen.media.videoPlayer.VideoConnection;

import net.ericpetersen.media.videoPlayer.VideoPlayer;
import net.ericpetersen.media.videoPlayer.VideoConnection;
import net.dananichev.utils.Log;

import flash.geom.Point;
import flash.display.*;
import flash.media.Video;
import flash.errors.*;
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

public class VideoPlayerFisheye extends VideoPlayer {
    /**
     * Dispatched when fullScreen changes.
     *
     * @eventType FULL_SCREEN_CHANGED
     */
    public static const FULL_SCREEN_CHANGED:String = "FULL_SCREEN_CHANGED";

    protected var _isFullScreen:Boolean = false;
    protected var _origVideoPt:Point;
    protected var _origPlayerWidth:Number;
    protected var _origPlayerHeight:Number;

    private var Logger:Log = new Log();


    /** 3D scene variables */
    private var _camera:Camera3D;
    private var _cameraController:HoverController;
    private var _view:View3D;
    private var _mesh:Mesh;
    private var _texture:TextureMaterial;
    private var _bmpData:BitmapData;
    private var _bmpTexture:BitmapTexture;

    /**
     * @return Whether or not it is full-screen
     */
    public function get isFullScreen():Boolean {
        return _isFullScreen;
    }

    public function VideoPlayerFisheye(width:int = 320, height:int = 240) {
        super(width, height);
        _origPlayerWidth = width;
        _origPlayerHeight = height;
        addEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
    }

    /**
     * Sets the player to full screen
     * @param val true or false
     */
    public function setFullScreen(val:Boolean):void {
        Logger.WriteLine("setFullScreen " + val);
        _isFullScreen = val;
        if (val == true) {
            _origVideoPt.x = this.x;
            _origVideoPt.y = this.y;
            stage.displayState = StageDisplayState.FULL_SCREEN;
        } else {
            stage.displayState = StageDisplayState.NORMAL;
        }
    }

    /**
     * Remove listeners and clean up
     */
    override public function destroy():void {
        super.destroy();
        removeEventListener(Event.ENTER_FRAME, enterFrameHandler);
    }

    override protected function onAddedToStage(event:Event):void {
        super.onAddedToStage(event);
        stage.addEventListener(FullScreenEvent.FULL_SCREEN, onFullScreen);

        _init3D();
        _createScene();
        addEventListener(Event.ENTER_FRAME, enterFrameHandler, false, 0, true);
    }

    protected function enterFrameHandler(event:Event):void {
        _updateTexture();
//        _mesh.rotationY += 2;
        _view.render();
    }

    protected function onPlayClick(event:Event):void {
        playVideo();
    }

    protected function onPauseClick(event:Event):void {
        pauseVideo();
    }

    protected function onFullScreenClick(event:Event):void {
        setFullScreen(!_isFullScreen);
    }

    protected function onFullScreen(event:FullScreenEvent):void {
        Logger.WriteLine("onFullScreen");
        if (event.fullScreen) {
            // set up fullscreen
            _isFullScreen = true;
            stage.addEventListener(Event.RESIZE, resizeFullScreenDisplay);
            resizeFullScreenDisplay();
        } else {
            // go back from fullscreen
            _isFullScreen = false;
            stage.removeEventListener(Event.RESIZE, resizeFullScreenDisplay);
            resumeFromFullScreenDisplay();
        }
        dispatchEvent(new Event(FULL_SCREEN_CHANGED));
    }

    protected function resizeFullScreenDisplay(event:Event = null):void {
        Logger.WriteLine("resizeFullScreenDisplay");
        stage.scaleMode = StageScaleMode.NO_SCALE;
        stage.align = StageAlign.TOP_LEFT;
        this.x = 0;
        this.y = 0;
        setSize(stage.stageWidth, stage.stageHeight);
    }

    protected function resumeFromFullScreenDisplay():void {
        this.x = _origVideoPt.x;
        this.y = _origVideoPt.y;
        setSize(_origPlayerWidth, _origPlayerHeight);
    }

    override protected function onPlayerStateChange(event:Event):void {
        Logger.WriteLine("onPlayerStateChange");
        var state:int = getPlayerState();
        switch (state) {
            case VideoConnection.UNSTARTED :
                Logger.WriteLine("state: " + VideoConnection.UNSTARTED);
                break;
            case VideoConnection.PLAYING :
                Logger.WriteLine("state: " + VideoConnection.PLAYING);
                super.setVolume(0);
                break;
            case VideoConnection.PAUSED :
                Logger.WriteLine("state: " + VideoConnection.PAUSED);
                break;
            case VideoConnection.ENDED :
                Logger.WriteLine("state: " + VideoConnection.ENDED);
                seekTo(0);
                pauseVideo();
                break;
            default :
                break;
        }
    }

    private function _init3D():void {
        Logger.WriteLine("_init3D");
        _camera = new Camera3D();

        _view = new View3D();
        _view.x = 0;
        _view.y = -50;
        _view.antiAlias = 4;
        _view.camera.z = -950;
        _view.camera.y = 500;
        _view.camera.lookAt(new Vector3D());
        addChild(_view);
    };

    private function _createScene():void {
        Logger.WriteLine("_createScene");

        // Var ini
        _bmpData = new BitmapData(512, 512);

        var sphereGeometry:SphereGeometry = new SphereGeometry(512, 40, 40); // Local var which we will be free up after
        _mesh = new Mesh(sphereGeometry); // Everything is a mesh at the end of the day
        sphereGeometry = null; // Free up the geometry variable
        _view.scene.addChild(_mesh); // Add the sphere mesh to the Away3D scene
        _mesh.rotationY = 170;
    };

    private function _updateTexture():void {
        Logger.WriteLine("_updateTexture");

        if (super.getPlayerState() == VideoConnection.PLAYING) {
            // Draw!
            _bmpData.draw(super._videoContainer);

            // Try and use as little resources as possible
            if (!_bmpTexture) {
                _bmpTexture = new BitmapTexture(_bmpData);
            } else {
                _bmpTexture.dispose();
                _bmpTexture = new BitmapTexture(_bmpData);
            }

            if (!_texture) {
                _texture = new TextureMaterial(_bmpTexture, false, false, true);
            } else {
                _texture.texture = _bmpTexture;
            }

            _mesh.material = _texture;
        }
    };


}
}
