import QtQuick 2.6

Item {
    property string name: "Thirds"
    property var windows: [
        {
            column: 0,
            rowSpan: 4,
            row: 0, columnSpan: 12 // full height
        },
        {
            column: 4,
            rowSpan: 4,
            row: 0, columnSpan: 12 // full height
        },
        {
            column: 8,
            rowSpan: 4,
            row: 0, columnSpan: 12 // full height
        }
    ]
}
