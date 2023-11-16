import QtQuick 2.5

Item {
    property string name: "Three Vertical Split"
    property var windows: [
        {
            x: 0,
            y: 0,
            width: 4,
            height: 12
        },
        {
            x: 4,
            y: 0,
            width: 4,
            height: 12
        },
        {
            x: 8,
            y: 0,
            width: 4,
            height: 12
        }
    ]
}
