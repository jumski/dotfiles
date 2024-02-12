import QtQuick 2.6

Item {
    property string name: "Equal sides"
    property var windows: [
        {
            column: 0,
            rowSpan: 3,
            row: 0, columnSpan: 12 // full height
        },
        {
            column: 3,
            rowSpan: 6,
            row: 0, columnSpan: 12 // full height
        },
        {
            column: 9,
            rowSpan: 3,
            row: 0, columnSpan: 12 // full height
        }
    ]
}
