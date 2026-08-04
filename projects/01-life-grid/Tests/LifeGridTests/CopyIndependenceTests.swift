// The load bearing suite for project 01.
//
// Nothing in the spec says "use a struct". This file does not say it either.
// It just copies a grid, mutates one of them, and asks the other what it
// holds. A `class Grid` passes exactly zero of these tests, because the copy
// and the original are one object, and no amount of care inside `step()`
// changes that.
//
// This file will not compile until `Grid` exists with the shape the spec's
// "Pinned API" section names. That is the intended state of an unstarted
// project: this package is standalone, so its failure to build cannot red a
// single chapter.

import Testing

@testable import LifeGrid

@Suite("P01 copy independence")
struct CopyIndependenceTests {

    // Two assertions, two distinct expected values, in one test. A `Grid`
    // that always reports `false`, and a `Grid` that always reports `true`,
    // both fail here.
    @Test("mutating the original leaves the copy alone")
    func originalDoesNotReachTheCopy() {
        var original = Grid(width: 3, height: 3)
        original[0, 0] = true

        let copy = original
        original[1, 1] = true

        #expect(copy[0, 0] == true)
        #expect(copy[1, 1] == false)
        #expect(original[1, 1] == true)
    }

    // The other direction. A design that copies on write in one direction and
    // aliases in the other is a real bug and this is the test that finds it.
    @Test("mutating the copy leaves the original alone")
    func copyDoesNotReachTheOriginal() {
        let original = Grid(width: 3, height: 3)

        var copy = original
        copy[2, 2] = true

        #expect(original[2, 2] == false)
        #expect(copy[2, 2] == true)
    }

    // Passing a grid to a function that takes it by value. The parameter is a
    // copy even when the function makes it mutable, and this is the shape the
    // bug actually arrives in: a renderer or a rule function that was not
    // supposed to be able to write anything.
    @Test("a grid handed to a function is a copy")
    func handingItOverIsACopy() {
        func lightUpCorner(_ grid: Grid) -> Grid {
            var local = grid
            local[0, 0] = true
            return local
        }

        var board = Grid(width: 4, height: 4)
        board[3, 3] = true

        let returned = lightUpCorner(board)

        #expect(board[0, 0] == false)
        #expect(returned[0, 0] == true)
        #expect(returned[3, 3] == true)
    }

    // `step()` is a mutating func, so it writes into the receiver and nothing
    // else. The blinker is the cheapest pattern that actually changes under
    // the rules, so a `step()` that does nothing at all fails this too.
    @Test("stepping a copy does not advance the original")
    func steppingACopyLeavesTheOriginal() {
        var original = Grid(width: 5, height: 5)
        // A vertical blinker at column 2, rows 1 through 3.
        original[2, 1] = true
        original[2, 2] = true
        original[2, 3] = true

        var copy = original
        copy.step()

        // The original still holds the vertical bar.
        #expect(original[2, 1] == true)
        #expect(original[2, 3] == true)
        #expect(original[1, 2] == false)

        // The copy holds the horizontal bar it oscillated into.
        #expect(copy[2, 1] == false)
        #expect(copy[1, 2] == true)
        #expect(copy[3, 2] == true)
    }

    // A grid inside a collection is a value too. Appending stores a copy, so
    // a later mutation of the local cannot reach back into the array. This is
    // the assertion that catches a `final class Grid` wrapped in a struct.
    @Test("a grid stored in an array is stored by value")
    func storedInACollection() {
        var board = Grid(width: 2, height: 2)
        var history: [Grid] = []

        history.append(board)
        board[1, 1] = true
        history.append(board)

        #expect(history[0][1, 1] == false)
        #expect(history[1][1, 1] == true)
        #expect(history.count == 2)
    }

    // Equality is about contents, not about storage. Two separately built
    // grids holding the same cells are equal, and one changed cell is enough
    // to separate them. An `Equatable` synthesized over an identity carrying
    // stored property fails the first assertion.
    @Test("equality compares cells, not storage")
    func equalityIsAboutContents() {
        var left = Grid(width: 3, height: 2)
        var right = Grid(width: 3, height: 2)

        #expect(left == right)

        left[1, 0] = true
        #expect(left != right)

        right[1, 0] = true
        #expect(left == right)
    }

    // Dimensions are part of identity for equality. Two all dead grids of
    // different sizes hold the same cells and are not the same board.
    @Test("grids of different sizes are never equal")
    func dimensionsCount() {
        let small = Grid(width: 2, height: 3)
        let wide = Grid(width: 3, height: 2)

        #expect(small != wide)
        #expect(small == Grid(width: 2, height: 3))
    }
}
