import QtQuick 2.6

Item {
    property string name: "Two Vertical Split"
    property var windows: [
        {
            x: 0,
            y: 0,
            width: 6,
            height: 12
        },
        {
            x: 6,
            y: 0,
            width: 6,
            height: 12
        }
    ]
}
