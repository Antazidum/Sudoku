import QtQuick
import QtQuick.Layouts
import QtQuick.Controls

Window {
  id: root
  width: 640
  height: width + 39
  visible: true
  title: 'Sudoku'

  palette.highlightedText: 'red'

  color: palette.window

  Item { id: eatFocusItem }

  property var model: {
    let m1 = []
    for (let r = 0; r < 9; ++r) {
      let m2 = []
      for (let c = 0; c < 9; ++c) {
        m2[c] = { v: 0, i:false, p:[1,2,3,4,5,6,7,8,9], vp:[0,0,0,0,0,0,0,0,0] };
      }
      m1[r] = m2;
    }
    return m1;
  }

  function removeFromRow(r, v) {
    for (let c = 0; c < model[r].length; ++c) {
      model[r][c].p[v - 1] = 0;
    }
  }

  function removeFromCol(c, v) {
    for (let r = 0; r < model.length; ++r) {
      model[r][c].p[v - 1] = 0;
    }
  }

  function removeFromCell(r, c, v) {
    r -= r % 3; c -= c % 3;
    for (let _r = 0; _r < 3; ++_r) {
      for (let _c = 0; _c < 3; ++_c) {
        model[r + _r][c + _c].p[v - 1] = 0;
      }
    }
  }

  function checkRowsFor(v) {
    for (let r = 0; r < 9; ++r) {
      let _c = -1;
      for (let c = 0; c < 9; ++c) {
        if (model[r][c].p[v]) {
          if (_c === -1) {
            model[r][c].vp[v]++;
            _c = c;
          } else {
            model[r][_c].vp[v]--;
            break;
          }
        }
      }
    }
  }

  function checkColsFor(v) {
    for (let c = 0; c < 9; ++c) {
      let _r = -1;
      for (let r = 0; r < 9; ++r) {
        if (model[r][c].p[v]) {
          if (_r === -1) {
            model[r][c].vp[v]++;
            _r = r;
          } else {
            model[_r][c].vp[v]--;
            break;
          }
        }
      }
    }
  }

  function checkCellFor(v) {
    for (let r1 = 0; r1 < 3; ++r1) {
      for (let c1 = 0; c1 < 3; ++c1) {
        let _r = -1, _c = -1;
        for (let r2 = 0; r2 < 3; ++r2) {
          for (let c2 = 0; c2 < 3; ++c2) {
            let r = r1 * 3 + r2, c = c1 * 3 + c2;
            if (model[r][c].p[v]) {
              if (_r === -1 && _c === -1) {
                model[r][c].vp[v]++;
                _r = r; _c = c;
              } else {
                model[_r][_c].vp[v]--;
                // double break
                r2 = 3; c2 = 3;
              }
            }
          }
        }
      }
    }
  }

  function updateModel() {
    model.forEach((rm) => rm.forEach((cm) => cm.p = cm.v ? [0,0,0,0,0,0,0,0,0] : [1,2,3,4,5,6,7,8,9]));
    for (let r = 0; r < model.length; ++r) {
      for (let c = 0; c < model[r].length; ++c) {
        let m = model[r][c];
        if (m.v) {
          removeFromRow(r, m.v);
          removeFromCol(c, m.v);
          removeFromCell(r, c, m.v);
        }
      }
    }
    model.forEach((rm) => rm.forEach((cm) => cm.vp = [0,0,0,0,0,0,0,0,0]));
    for (let i = 0; i < 9; ++i) {
      checkRowsFor(i);
      checkColsFor(i);
      checkCellFor(i);
    }
    modelChanged()
  }

  // Test values
  // Component.onCompleted: {
  //   model[0][0].v = 1; model[0][0].i = true;
  //   model[0][6].v = 7; model[0][6].i = true;
  //   model[1][1].v = 9; model[1][1].i = true;
  //   model[1][3].v = 6; model[1][3].i = true;
  //   model[2][4].v = 4; model[2][4].i = true;
  //   model[2][6].v = 8; model[2][6].i = true;
  //   model[3][3].v = 5; model[3][3].i = true;
  //   model[3][5].v = 7; model[3][5].i = true;
  //   model[5][0].v = 8; model[5][0].i = true;
  //   model[5][1].v = 6; model[5][1].i = true;
  //   model[5][2].v = 4; model[5][2].i = true;
  //   model[6][0].v = 3; model[6][0].i = true;
  //   model[6][5].v = 8; model[6][5].i = true;
  //   model[7][7].v = 9; model[7][7].i = true;
  //   model[8][1].v = 2; model[8][1].i = true;
  //   model[8][7].v = 5; model[8][7].i = true;
  //   model[8][8].v = 6; model[8][8].i = true;
  //   updateModel();
  // }

  Timer {
    running: solveSwitch.checked
    repeat: true
    interval: 1
    onTriggered: {
      for (let r = 0; r < model.length; ++r) {
        for (let c = 0; c < model[r].length; ++c) {
          let i = model[r][c].vp.findIndex((v) => v);
          if (i !== -1) {
            model[r][c].v = i + 1;
            updateModel();
            return;
          }
        }
      }
      solveSwitch.checked = false;
    }
  }

  Timer {
    running: clearSwitch.checked
    repeat: true
    interval: 1
    onTriggered: {
      for (let r = 0; r < model.length; ++r) {
        for (let c = 0; c < model[r].length; ++c) {
          let m = model[r][c];
          if (m.v && (!m.i || initSwitch.checked)) {
            m.v = 0;
            updateModel();
            return;
          }
        }
      }
      clearSwitch.checked = false;
    }
  }

  Rectangle {
    anchors.fill: parent

    color: palette.windowText

    GridLayout {
      id: gl1
      anchors.fill: parent

      columns: 3
      rows: 3
      columnSpacing: 3
      rowSpacing: 3

      Repeater {
        model: parent.columns * parent.rows

        Rectangle {
          id: r1
          Layout.fillWidth: true
          Layout.fillHeight: true

          property int r: index / parent.rows
          property int c: index % parent.columns

          color: palette.windowText

          GridLayout {
            id: gl2
            anchors.fill: parent

            columns: 3
            rows: 3
            columnSpacing: 1
            rowSpacing: 1

            Repeater {
              model: parent.columns * parent.rows

              Rectangle {
                id: r2
                Layout.fillWidth: true
                Layout.fillHeight: true

                property int r: r1.r * gl1.rows + index / parent.rows
                property int c: r1.c * gl1.columns + index % parent.columns
                property var m: root.model[r][c]

                color: palette.window

                GridLayout {
                  anchors.fill: parent
                  visible: hintsSwitch.checked && !ti.focus
                  columns: 3
                  rows: 3
                  columnSpacing: 0
                  rowSpacing: 0
                  Repeater {
                    model: r2.m.p.length
                    Text {
                      id: t
                      Layout.fillWidth: true
                      Layout.fillHeight: true
                      Layout.column: index % 3
                      Layout.row: index / 3
                      text: r2.m.p[index] || ' '
                      color: palette.windowText
                      horizontalAlignment: Text.AlignHCenter
                      verticalAlignment: Text.AlignVCenter
                      states: State {
                        when: r2.m.vp[index]
                        PropertyChanges {
                          target: t
                          color: palette.highlightedText
                          font.bold: true
                        }
                      }
                    }
                  }
                }

                TextInput {
                  id: ti
                  anchors.fill: parent

                  // fancy animation of value while solving or clearing
                  property int value: r2.m.v
                  Behavior on value { enabled: solveSwitch.checked || clearSwitch.checked; NumberAnimation { duration: 500 } }

                  validator: RegularExpressionValidator { regularExpression: /[0-9]?/ }
                  horizontalAlignment: TextInput.AlignHCenter
                  verticalAlignment: TextInput.AlignVCenter
                  font.pixelSize: height * 2 / 3
                  text: value || ''
                  color: palette.windowText
                  enabled: !r2.m.i || initSwitch.checked
                  font.bold: r2.m.i
                  onAccepted: eatFocusItem.forceActiveFocus()
                  onTextEdited: {
                    r2.m.v = Number(text);
                    r2.m.i = initSwitch.checked;
                    updateModel();
                  }
                }
              }
            }
          }
        }
      }
    }
  }
  Item {
    width: parent.width
    height: childrenRect.height
    Rectangle {
      id: menu
      height: childrenRect.height
      width: parent.width
      y: +!hover.hovered * -height
      Behavior on y { SequentialAnimation { PauseAnimation { duration: +!menu.y * 500 } NumberAnimation {} } }
      color: palette.window
      RowLayout {
        Switch { id: initSwitch; text: 'INIT'; checked: true }
        Switch { id: hintsSwitch; text: 'HINTS' }
        Switch { id: solveSwitch; text: 'SOLVE'; enabled: !initSwitch.checked }
        Switch { id: clearSwitch; text: 'CLEAR' }
      }
    }
    HoverHandler { id: hover }
  }
}
