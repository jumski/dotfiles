import QtQuick 2.6

Item {
    property string name: "Two Fifths and One Fifth"
    property var windows: [
        {
            column: 0,
            rowSpan: 5,
            row: 0, columnSpan: 12 // full height
        },
        {
            column: 5,
            rowSpan: 4,
            row: 0, columnSpan: 12 // full height
        },
        {
            column: 9,
            rowSpan: 3,
            row: 0, columnSpan: 12 // full height
        }
    ]
}
