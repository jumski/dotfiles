import QtQuick 2.6

Item {
    property string name: "Half and Half"
    property var windows: [
        {
            column: 0,
            rowSpan: 6,
            row: 0, columnSpan: 12 // full height
        },
        {
            column: 6,
            rowSpan: 6,
            row: 0, columnSpan: 12 // full height
        }
    ]
}
