import QtQuick 2.6

Item {
    property string name: "Right Big Half"
    property var windows: [
        {
            column: 0,
            rowSpan: 3,
            row: 0, columnSpan: 12 // full height
        },
        {
            column: 3,
            rowSpan: 3,
            row: 0, columnSpan: 12 // full height
        },
        {
            column: 6,
            rowSpan: 6,
            row: 0, columnSpan: 12 // full height
        }
    ]
}
