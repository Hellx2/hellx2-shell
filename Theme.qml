import QtQuick

QtObject {
    property bool dark: true

    property color fail
    property color success

    property color extreme

    /*
    property color red//: "#ff7777"
     property color blue//: "#66bbdd"
     property color white//: "#ffffff"

     //property string alternate//: "#ffffff"
     //property string accent//: "#5232b7"

     property string grey0//: "#0c0c0c"
     property string grey1//: "#1c1c1c"
     property string grey2//: "#252525"
     property string grey3//: "#353535"
     property string grey4//: "#454545"
     property string grey5//: "#505050"
     property string grey6//: "#656565"
     */

    property color pomodoro_normal
    property color pomodoro_break

    property color active_item
    property color inactive_item

    property color spacer
    property color accent//: "#55aa77"
    property color accent1//: "#55aa77"

    property string bgcol//: grey1
    property string border//: grey2

    property string button_bg//: grey4
    property string button_bg_down//: grey1
    property string button_bg_hover//: grey6
    property double button_sidepad//: 2.5

    property string text_fg//: white
    property string text_font: "JetBrainsMono Nerd Font"
    property int text_size//: 14

    property string input_bg//: grey1
    property int input_text_size//: 16
    property int input_radius//: 10
}
