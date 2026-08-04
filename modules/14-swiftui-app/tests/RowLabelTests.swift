import Foundation
import Testing

@testable import Chapter14

@Suite("14 What VoiceOver reads")
struct RowLabelTests {
    private let epoch = Date(timeIntervalSince1970: 1_700_000_000)

    private func note(_ title: String, archived: Bool = false) -> StoredNote {
        StoredNote(id: UUID(), title: title, isArchived: archived, updatedAt: epoch)
    }

    @Test("a row with no date says so instead of trailing off")
    func aRowWithNoDateSaysSo() {
        #expect(RowLabel.spoken(for: note("Buy milk"), dueInDays: nil) == "Buy milk, no due date")
        #expect(RowLabel.spoken(for: note("Call the vet"), dueInDays: nil) == "Call the vet, no due date")
    }

    @Test("today and tomorrow are words, not counts")
    func todayAndTomorrowAreWords() {
        #expect(RowLabel.spoken(for: note("Buy milk"), dueInDays: 0) == "Buy milk, due today")
        #expect(RowLabel.spoken(for: note("Buy milk"), dueInDays: 1) == "Buy milk, due tomorrow")
    }

    @Test("the day after tomorrow starts counting, in the plural")
    func countingStartsAtTwo() {
        #expect(RowLabel.spoken(for: note("Buy milk"), dueInDays: 2) == "Buy milk, due in 2 days")
        #expect(RowLabel.spoken(for: note("Buy milk"), dueInDays: 14) == "Buy milk, due in 14 days")
    }

    @Test("one day late is singular and two days late is plural")
    func latenessIsPluralizedOnItsOwnSideOfZero() {
        #expect(RowLabel.spoken(for: note("Buy milk"), dueInDays: -1) == "Buy milk, overdue by 1 day")
        #expect(RowLabel.spoken(for: note("Buy milk"), dueInDays: -3) == "Buy milk, overdue by 3 days")
    }

    @Test("an archived row stops reporting dates it no longer has an opinion about")
    func anArchivedRowDropsTheDate() {
        let filed = note("Buy oats", archived: true)
        #expect(RowLabel.spoken(for: filed, dueInDays: -3) == "Buy oats, archived")
        #expect(RowLabel.spoken(for: filed, dueInDays: nil) == "Buy oats, archived")
        #expect(RowLabel.spoken(for: filed, dueInDays: 0) == "Buy oats, archived")
    }

    @Test("the title is read first, whatever it is")
    func theTitleComesFirst() {
        #expect(RowLabel.spoken(for: note("Renew passport"), dueInDays: 7).hasPrefix("Renew passport, "))
        #expect(RowLabel.spoken(for: note("Zzz"), dueInDays: -1) == "Zzz, overdue by 1 day")
    }
}
