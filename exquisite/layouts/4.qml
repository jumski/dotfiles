import QtQuick 2.6

Item {
    property string name: "One Fifth and Two Fifths"
    property var windows: [
        {
            column: 0,
            rowSpan: 2,
            row: 0, columnSpan: 12 // full height
        },
        {
            column: 2,
            rowSpan: 7,
            row: 0, columnSpan: 12 // full height
        },
        {
            column: 9,
            rowSpan: 3,
            row: 0, columnSpan: 12 // full height
        }
    ]
}
