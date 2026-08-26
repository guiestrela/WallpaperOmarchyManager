import QtQuick
import QtMultimedia
import qs.Commons

// Renders both image wallpapers and video wallpapers through one small API.
// The parent controls the final size, so all existing scaling modes continue
// to work for either kind of media.
Item {
  id: root

  property string sourcePath: ""
  property string fillModeName: "zoom"
  property bool ready: false
  readonly property bool videoMode: /\.(mp4|webm|mkv|mov|avi)$/i.test(sourcePath)

  signal wallpaperReady()
  signal wallpaperError(string path)

  implicitWidth: renderer.item ? renderer.item.implicitWidth : 0
  implicitHeight: renderer.item ? renderer.item.implicitHeight : 0

  Loader {
    id: renderer
    anchors.fill: parent
    active: root.sourcePath !== ""
    sourceComponent: root.videoMode ? videoComponent : imageComponent
  }

  onSourcePathChanged: ready = false

  Component {
    id: imageComponent

    AnimatedImage {
      anchors.fill: parent
      source: Util.fileUrl(root.sourcePath)
      fillMode: root.fillModeName === "zoom" ? Image.PreserveAspectCrop : Image.Stretch
      asynchronous: true
      cache: false
      smooth: true
      playing: true
      onStatusChanged: {
        if (status === Image.Ready) { root.ready = true; root.wallpaperReady() }
        else if (status === Image.Error) root.wallpaperError(root.sourcePath)
      }
    }
  }

  Component {
    id: videoComponent

    Video {
      anchors.fill: parent
      source: Util.fileUrl(root.sourcePath)
      fillMode: root.fillModeName === "zoom"
        ? VideoOutput.PreserveAspectCrop : VideoOutput.Stretch
      autoPlay: true
      loops: MediaPlayer.Infinite
      muted: true
      onPlaybackStateChanged: {
        if (playbackState === MediaPlayer.PlayingState) { root.ready = true; root.wallpaperReady() }
      }
      onErrorChanged: {
        if (error !== MediaPlayer.NoError) root.wallpaperError(root.sourcePath)
      }
    }
  }
}
