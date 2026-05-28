import QtQuick
import Quickshell

import qs.common

Row {
    property var currwin: NiriService.windows.filter(w => w.is_focused)[0]
    height: 20
    Image {
    	mipmap: true
        source: Quickshell.iconPath(DesktopEntries.byId(currwin?.app_id)?.icon, true)
        width: 20
        height: 20
    }
    NText {
        rightPadding: 2.5
        leftPadding: 2.5
        text: currwin?.title
        color: Styles.text_fg
    }
    visible: currwin != undefined
}
