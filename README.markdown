#  Draggable Test

This test app reproduces an issue related to SwiftData, SwiftUI and animations that results in the UI completely locking up.

The main focus of this test app is the sidebar elements, which has a number of card elements each with a `Int32` `sortIndex` parameter. Mock data is populated on first launch.

Tapping the bug button will start the test, and then once each second two of the sidebar cards will swap `sortIndex`s. When the issues occurs isn't consistent, but eventually (usually between 30-120 seconds) the UI will completely freeze.

<a href="https://youtu.be/dbtQewjDoug" target="_blank"><img src="http://img.youtube.com/vi/dbtQewjDoug/0.jpg" 
alt="IMAGE ALT TEXT HERE" width="240" height="180" border="10" /></a>
