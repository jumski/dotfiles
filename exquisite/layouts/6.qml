import QtQuick 2.5

Item {
    property string name: "Four Tile Grid"
    property var windows: [
        {
            x: 0,
            y: 0,
            width: 6,
            height: 6
        },
        {
            x: 0,
            y: 6,
            width: 6,
            height: 6
        },
        {
            x: 6,
            y: 0,
            width: 6,
            height: 6
        },
        {
            x: 6,
            y: 6,
            width: 6,
            height: 6
        }
    ]
}