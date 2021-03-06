//
//  MusicTheoryTests.swift
//  MusicTheoryTests
//
//  Created by Cem Olcay on 30/12/2016.
//  Copyright © 2016 prototapp. All rights reserved.
//

import XCTest
import MusicTheory

class MusicTheoryTests: XCTestCase {

  override func setUp() {
    super.setUp()
    // Put setup code here. This method is called before the invocation of each test method in the class.
  }
  
  override func tearDown() {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    super.tearDown()
  }
}

extension MusicTheoryTests {

  func testHalfstep() {
    let noteType: NoteType = .c
    XCTAssert(noteType + 1 == .dFlat)
    XCTAssert(noteType + 11 == .b)
    XCTAssert(noteType + 12 == .c)
    let note: Note = Note(type: noteType, octave: 1)
    XCTAssert((note + 12).octave == note.octave + 1)
    XCTAssert((note + 1).type == .dFlat)
    XCTAssert((note - 1) == Note(type: .b, octave: 0))
  }

  func testNote() {
    var note = Note(midiNote: 127)
    XCTAssert(note.type == .g)
    note = Note(midiNote: 0)
    XCTAssert(note.type == .c)
    note = Note(midiNote: 66)
    XCTAssert(note.type == .gFlat)
  }

  func testFrequency() {
    let note = Note(type: .a, octave: 4)
    XCTAssertEqual(note.frequency, 440.0)
  }

  func testInterval() {
    let note: NoteType = .c
    XCTAssert(note + .P8 == note)
    XCTAssert(note + .M2 == .d)
    XCTAssert(note + .m2 == .dFlat)

    let b = Note(type: .b, octave: 1)
    let d = Note(type: .d, octave: 2)
    XCTAssert(b - d == .m3)
    XCTAssert(d - b == .m3)
  }

  func testMidiNote() {
    XCTAssert(Note(type: .c, octave: -1).midiNote == 0)
    XCTAssert(Note(type: .c, octave: 0).midiNote == 12)
    XCTAssert(Note(type: .b, octave: 7).midiNote == 107)
    XCTAssert(Note(type: .g, octave: 9).midiNote == 127)
  }

  func testScale() {
    let cMaj: [NoteType] = [.c, .d, .e, .f, .g, .a, .b]
    let cMajScale = Scale(type: .major, key: .c)
    XCTAssert(cMajScale.noteTypes == cMaj)
    let cMin: [NoteType] = [.c, .d, .eFlat, .f, .g, .aFlat, .bFlat]
    let cMinScale = Scale(type: .minor, key: .c)
    XCTAssert(cMinScale.noteTypes == cMin)
  }

  func testHarmonicFields() {
    let cmaj = Scale(type: .major, key: .c)
    let triads = cmaj.harmonicField(for: .triad)
    let triadsExpected = [
      Chord(type: ChordType(third: .major), key: .c),
      Chord(type: ChordType(third: .minor), key: .d),
      Chord(type: ChordType(third: .minor), key: .e),
      Chord(type: ChordType(third: .major), key: .f),
      Chord(type: ChordType(third: .major), key: .g),
      Chord(type: ChordType(third: .minor), key: .a),
      Chord(type: ChordType(third: .minor, fifth: .diminished), key: .b),
    ]
    XCTAssert(triads.enumerated().map({ $1 == triadsExpected[$0] }).filter({ $0 == false }).count == 0)
  }

  func testChords() {
    let cmajNotes: [NoteType] = [.c, .e, .g]
    let cmaj = Chord(type: ChordType(third: .major), key: .c)
    XCTAssert(cmajNotes == cmaj.noteTypes)
    
    let cminNotes: [NoteType] = [.c, .eFlat, .g]
    let cmin = Chord(type: ChordType(third: .minor), key: .c)
    XCTAssert(cminNotes == cmin.noteTypes)

    let c13Notes: [Note] = [
      Note(type: .c, octave: 1),
      Note(type: .e, octave: 1),
      Note(type: .g, octave: 1),
      Note(type: .bFlat, octave: 1),
      Note(type: .d, octave: 2),
      Note(type: .f, octave: 2),
      Note(type: .a, octave: 2)]
    let c13 = Chord(
      type: ChordType(
        third: .major,
        seventh: .dominant,
        extensions: [
          ChordExtensionType(type: .thirteenth)
        ]),
      key: .c)
    XCTAssert(c13.notes(octave: 1) == c13Notes)

    let cm13Notes: [Note] = [
      Note(type: .c, octave: 1),
      Note(type: .eFlat, octave: 1),
      Note(type: .g, octave: 1),
      Note(type: .bFlat, octave: 1),
      Note(type: .d, octave: 2),
      Note(type: .f, octave: 2),
      Note(type: .a, octave: 2)]
    let cm13 = Chord(
      type: ChordType(
        third: .minor,
        seventh: .dominant,
        extensions: [
          ChordExtensionType(type: .thirteenth)
        ]),
      key: .c)
    XCTAssert(cm13.notes(octave: 1) == cm13Notes)

    let minorIntervals: [Interval] = [.P1, .m3, .P5]
    guard let minorChord = ChordType(intervals: minorIntervals) else { return XCTFail() }
    XCTAssert(minorChord == ChordType(third: .minor))

    let majorIntervals: [Interval] = [.P1, .M3, .P5]
    guard let majorChord = ChordType(intervals: majorIntervals) else { return XCTFail() }
    XCTAssert(majorChord == ChordType(third: .major))

    let cmadd13Notes: [Note] = [
      Note(type: .c, octave: 1),
      Note(type: .eFlat, octave: 1),
      Note(type: .g, octave: 1),
      Note(type: .a, octave: 2)]
    let cmadd13 = Chord(
      type: ChordType(
        third: .minor,
        extensions: [ChordExtensionType(type: .thirteenth)]),
      key: .c)
    XCTAssert(cmadd13.notes(octave: 1) == cmadd13Notes)
  }

  func testNoteValueConversions() {
    let noteValue = NoteValue(type: .half, modifier: .dotted)
    XCTAssertEqual(noteValue / NoteValueType.sixteenth, 12)
    XCTAssertEqual(noteValue / NoteValueType.whole, 0.75)
  }

  func testDurations() {
    let timeSignature = TimeSignature(beats: 4, noteValue: .quarter) // 4/4
    let tempo = Tempo(timeSignature: timeSignature, bpm: 120) // 120BPM
    var noteValue = NoteValue(type: .quarter)
    var duration = tempo.duration(of: noteValue)
    XCTAssert(duration == 0.5)

    noteValue.modifier = .dotted
    duration = tempo.duration(of: noteValue)
    XCTAssert(duration == 0.75)
  }

  func testInversions() {
    let c7 = Chord(
      type: ChordType(third: .major, seventh: .dominant),
      key: .c)
    let c7Inversions = [
      [Note(type: .c, octave: 1), Note(type: .e, octave: 1), Note(type: .g, octave: 1), Note(type: .bFlat, octave: 1)],
      [Note(type: .e, octave: 1), Note(type: .g, octave: 1), Note(type: .bFlat, octave: 1), Note(type: .c, octave: 2)],
      [Note(type: .g, octave: 1), Note(type: .bFlat, octave: 1), Note(type: .c, octave: 2), Note(type: .e, octave: 2)],
      [Note(type: .bFlat, octave: 1), Note(type: .c, octave: 2), Note(type: .e, octave: 2), Note(type: .g, octave: 2)],
    ]
    for (index, chord) in c7.inversions.enumerated() {
      XCTAssert(chord.notes(octave: 1) == c7Inversions[index])
    }
  }

  func testSampleLengthCalcuation() {
    let rates = [
      NoteValue(type: .whole, modifier: .default),
      NoteValue(type: .half, modifier: .default),
      NoteValue(type: .half, modifier: .dotted),
      NoteValue(type: .half, modifier: .triplet),
      NoteValue(type: .quarter, modifier: .default),
      NoteValue(type: .quarter, modifier: .dotted),
      NoteValue(type: .quarter, modifier: .triplet),
      NoteValue(type: .eighth, modifier: .default),
      NoteValue(type: .eighth, modifier: .dotted),
      NoteValue(type: .sixteenth, modifier: .default),
      NoteValue(type: .sixteenth, modifier: .dotted),
      NoteValue(type: .thirtysecond, modifier: .default),
      NoteValue(type: .sixtyfourth, modifier: .default),
    ]

    let tempo = Tempo()
    let sampleLengths = rates
      .map({ tempo.sampleLength(of: $0) })
      .map({ round(100 * $0) / 100 })

    let expected: [Double] = [
      88200.0,
      44100.0,
      66150.0,
      29401.47,
      22050.0,
      33075.0,
      14700.73,
      11025.0,
      16537.5,
      5512.5,
      8268.75,
      2756.25,
      1378.13,
    ]

    XCTAssertEqual(sampleLengths, expected)
  }
}
