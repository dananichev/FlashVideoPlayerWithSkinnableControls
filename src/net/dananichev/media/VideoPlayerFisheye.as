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
import away3d.cameras.lenses.*;
import away3d.containers.*;
import away3d.controllers.*;
import away3d.core.base.*;
import away3d.debug.*;
import away3d.entities.*;
import away3d.materials.*;
import away3d.materials.utils.*;
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
    private var _vertexPositionData:Vector.<Number>;
    private var _textureCoordData:Vector.<Number>;
    private var _normalData:Vector.<Number>;
    private var _indexData:Vector.<uint>;

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
        _cameraController.panAngle = mouseX - 320;
        _cameraController.tiltAngle = mouseY - 240;
//        PerspectiveLens(_view.camera.lens).fieldOfView -=1;
//
//        Logger.WriteLine('FOV ' + PerspectiveLens(_view.camera.lens).fieldOfView);
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
        _view.camera.lens = new PerspectiveLens(5);
        _view.camera.z = -100;
        _view.camera.y = 100;
        _view.camera.lookAt(new Vector3D());
        _cameraController = new HoverController(_view.camera, null, 0, 0, 50);
        addChild(_view);

        var stats : AwayStats = new AwayStats(_view);
        stats.x = 0;
        stats.y = 0;
        addChild(stats);
    };

    private function _createScene():void {
        Logger.WriteLine("_createScene");

        // Var ini
//        _bmpData = new BitmapData(512, 512);

        var geometry:Geometry = new Geometry();
        var subgeometry:SubGeometry = new SubGeometry();
        _computeVerticesAndIndexes();

        Logger.WriteLine("_computeVerticesAndIndexes vertices " + _vertexPositionData.length);
        Logger.WriteLine("_computeVerticesAndIndexes uvs " + _textureCoordData.length);
        Logger.WriteLine("_computeVerticesAndIndexes indexes " + _indexData.length);

        subgeometry.updateVertexData(_vertexPositionData);
        subgeometry.updateUVData(_textureCoordData);
        subgeometry.updateIndexData(_indexData);
        subgeometry.autoDeriveVertexTangents = true;

        geometry.addSubGeometry(subgeometry);
        _mesh = new Mesh(geometry, new ColorMaterial(0x0000ff));
        geometry = null;
//        var uvMap:BitmapData = WireframeMapGenerator.generateSolidMap(_mesh);
//        _mesh.material = new TextureMaterial(new BitmapTexture(uvMap));
        _mesh.scale(2);
//        _mesh.rotationY = 170;
        _view.scene.addChild(_mesh);

//        var sphereGeometry:SphereGeometry = new SphereGeometry(512, 40, 40); // Local var which we will be free up after
//        _mesh = new Mesh(sphereGeometry); // Everything is a mesh at the end of the day
//        sphereGeometry = null; // Free up the geometry variable
//        _view.scene.addChild(_mesh); // Add the sphere mesh to the Away3D scene
//        _mesh.rotationY = 170;
    };

    private function _computeVerticesAndIndexes() : void {
        Logger.WriteLine("_computeVerticesAndIndexes");

        _vertexPositionData = new Vector.<Number>;
        _textureCoordData = new Vector.<Number>;
        _normalData = new Vector.<Number>;
        _indexData = new Vector.<uint>;

        // Параметры 3D сегмента эллипсоида
        var RadiusX:Number = 1;
        var RadiusY:Number = 1;
        var RadiusZ:Number = 0.66; // По Z нужно ближе к центру, так как у линз искажение такое, что они центр удаляют, а края приближают.

        var NLat:Number = 50;
        var NLong:Number = 150;

        // Параметры растра
        var ImgSizePixU:Number = 2048; // размер растра по U (эквивалент X, но в пространстве текстуры)
        var ImgSizePixV:Number = 2048; // размер растра по V (эквивалент Y, но в пространстве текстуры)

        // Параметры пятна изображения
        var ImgCircleCenterPixU:Number = 1024; // U-координата центра пятна изображения на растре
        var ImgCircleCenterPixV:Number = 1024 + 40; // V-координата центра пятна изображения на растре


        var ImgCircleRadius180:Number = 1750 / 2.0; // Радиус (в пикселях) на растре, где изображена полусфера
        var ImgCircleRadiusMax:Number = 2000 / 2.0;  // Полный радиус (в пикселях) пятна изображения на растре

        var AngleLatStart:Number = -10.0; // Начальная широта сегмента сферы (в градусах), с которого нужно генерировать полусферу (поскольку линза видит больше чем на 180)
        var AngleLatEnd:Number = 90.0; // Конечная широта сегмента сферы  (в градусах), всегда равен 90 градусов

        // для удобства кодирования переведем координаты из градусов в радианы
        var AngleLatStartRad:Number = AngleLatStart * Math.PI / 180.0; // Перевод из градусов в радианы
        var AngleLatEndRad:Number = AngleLatEnd * Math.PI / 180.0; // Перевод из градусов в радианы


        var i:Number = 0;
        for (var iLat:Number = 0; iLat < NLat; iLat++) {
            var tLat:Number = iLat / (NLat - 1);
            var latRad:Number = AngleLatStartRad + tLat * (AngleLatEndRad - AngleLatStartRad); // текущая широта в радианах

            for (var iLong:Number = 0; iLong < NLong; iLong++) {
                var tLong:Number = iLong / NLong;
                var longRad:Number = 2 * tLong * Math.PI;

                // Вычисляем координаты поверхности сферы
                var x:Number = RadiusX * Math.cos(latRad) * Math.cos(longRad);
                var y:Number = RadiusY * Math.cos(latRad) * Math.sin(longRad);
                var z:Number = RadiusZ * Math.sin(latRad);

                // Вычисляем текстурные координаты (предполагаем, что весь растр, это [0,1]x[0,1])

                var txtR:Number; // Радиус в пикселях от центра пятна изображения на растре
                if (z < 0) {
                    txtR = ImgCircleRadius180 * (1 - Math.cos(latRad));
                }
                else {
                    txtR = ImgCircleRadius180 * Math.cos(latRad);
                }
                if (txtR > ImgCircleRadiusMax) {
                    txtR = ImgCircleRadiusMax;
                }

                // Вычисляем позицию пикселя на растре
                var txtPixU:Number = ImgCircleCenterPixU + txtR * Math.cos(longRad);
                var txtPixV:Number = ImgCircleCenterPixV + txtR * Math.sin(longRad);

                // Переводим координаты точки растра в текстурные координаты
                var u:Number = txtPixU / ImgSizePixU;
                var v:Number = txtPixV / ImgSizePixV;

                _textureCoordData.push(u, v);
                if (x > 1) {
                    Logger.WriteLine("X " + x);
                }
                if (y > 1) {
                    Logger.WriteLine("Y " + y);
                }

                if (z > 1) {
                    Logger.WriteLine("Z " + z);
                }
                _vertexPositionData.push(x, y, z);
//                _normalData.push(x, y, z);
//                _textureCoordData[i].push(u);
//                _textureCoordData[i].push(v);
//                _vertexPositionData[i].push(x);
//                _vertexPositionData[i].push(y);
//                _vertexPositionData[i].push(z);
//                textureCoordData.push(u);
//                textureCoordData.push(v);
//                vertexPositionData.push(x);
//                vertexPositionData.push(y);
//                vertexPositionData.push(z);
                i++;
            }
        }

        var idx:Number = 0;
        for (var iy:Number = 0; iy < NLat - 1; iy++) {
            var iyNext:Number = iy + 1;

            for (var ix:Number = 0; ix < NLong; ix++) {
                var ixNext:Number = ix + 1;

                if (ixNext == NLong) ixNext = 0;

                _indexData.push(ix + iy * NLong);
                _indexData.push(ixNext + iyNext * NLong);
                _indexData.push(ix + iyNext * NLong);
//
//                _indexData[idx] = ix + iy * NLong;
//                idx++;
//                _indexData[idx] = ixNext + iyNext * NLong;
//                idx++;
//                _indexData[idx] = ix + iyNext * NLong;
//                idx++;

                _indexData.push(ix + iy * NLong);
                _indexData.push(ixNext + iy * NLong);
                _indexData.push(ixNext + iyNext * NLong);

//                _indexData[idx] = ix + iy * NLong;
//                idx++;
//                _indexData[idx] = ixNext + iy * NLong;
//                idx++;
//                _indexData[idx] = ixNext + iyNext * NLong;
//                idx++;

            }
        }

    }

    private function _updateTexture():void {
        Logger.WriteLine("_updateTexture");

        if (super.getPlayerState() == VideoConnection.PLAYING) {
            // Draw!
            _bmpData = new BitmapData(_origPlayerWidth, _origPlayerHeight);
            _bmpData.draw(super._videoContainer);

            // Try and use as little resources as possible
            if (!_bmpTexture) {
                _bmpTexture = new BitmapTexture(_bmpData);
            } else {
                _bmpTexture = null;
                _bmpTexture = new BitmapTexture(_bmpData);
            }

            if (!_texture) {
                _texture = new TextureMaterial(_bmpTexture, false, false, false);
            } else {
                _texture = null;
                _texture = new TextureMaterial(_bmpTexture, false, false, false);
//                _texture.texture = _bmpTexture;
            }

            _mesh.material = _texture;
            _mesh.material.bothSides = true;
        }
    };


}
}
