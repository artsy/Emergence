import Foundation

let nsdateMonthFormatter = NSDateFormatter()

extension NSDate {

    /// Generates an "Art World Certified" :tm:
    /// date range for between two dates

    func ausstellungsdauerToDate(endDate: NSDate) -> String {

        // NSDate -> "Jan"
        func month(date: NSDate) -> String {
            return nsdateMonthFormatter.stringFromDate(date)
        }

        // NSDateComponents -> "2nd"
        func day(date: NSDateComponents) -> String {
            return "\(date.day)\(ordinalForDay(date.day))"
        }

        // returns the bit after the number e.g. st, nd, th
        // Ported from
        // http://stackoverflow.com/questions/1283045/ordinal-month-day-suffix-option-for-nsdateformatter-setdateformat

        func ordinalForDay(day: Int) -> String {
            switch day {
            case 1, 21, 31: return "st";
            case 2, 22: return "nd";
            case 3, 23: return "rd";
            default: return "th";
            }
        }

        // This function will return a string that shows the time that the show is/was open, e.g.  "July 2nd - 12th, 2011"
        // If you can figure a better name for the function, I'd love to hear it, 
        // no-one could come up with it on #irtsy, it turned out the word did exist in German.

        // After a few years this has ended up a running joke in the mobile team, I'm afraid my sense
        // of humour won't let us drop the idea. Thanks Leonard / Jessica ./

        let calendar = NSCalendar(calendarIdentifier: NSCalendarIdentifierGregorian)!
        let desiredComponents = NSCalendarUnit([.Day, .Month, .Year])

        let start = calendar.components(desiredComponents, fromDate:self)
        let end = calendar.components(desiredComponents, fromDate:endDate)

        // Only show the years string if it wasn't this year
        let thisYear = calendar.components(NSCalendarUnit.Year, fromDate:NSDate()).year
        let yearStringPrefix = end.year == thisYear ? ", \(end.year)" : ""

        // Same month - "July 2nd - 12th, 2011"
        if end.month == start.month && end.year == start.year {
            return "\(month(self)) \(day(start)) - \(day(end))\(yearStringPrefix)"

        // Same year - "June 12th - August 20th, 2012"
        } else if end.year == start.year {
            return "\(month(self)) \(day(start)) - \(month(endDate)) \(day(end))\(yearStringPrefix)"

        // Different year - "January 12th, 2011 - April 19th, 2014"
        } else {
            return "\(month(self)) \(day(start)), \(start.year)  - \(month(endDate)) \(day(end)) \(end.year)"
        }
    }

}
