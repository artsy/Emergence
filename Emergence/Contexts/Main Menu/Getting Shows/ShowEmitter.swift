import Foundation

/// A simple pattern for saying "I take some shows and will occasionally get more"

typealias EmitterUpdateCallback = ((shows: [Show]) -> ())

protocol ShowEmitter {
    var title: String { get }
    var numberOfShows: Int { get }
    var shows: [Show] { get }

    func showAtIndexPath(index: NSIndexPath) -> Show
    func getShows()
    func onUpdate( callback: EmitterUpdateCallback )
    
    func isEqualTo(show: ShowEmitter) -> Bool
}

extension ShowEmitter {
    func isEqualTo(show: ShowEmitter) -> Bool {
        return title == show.title
    }
}

class StubbyEmitter: NSObject, ShowEmitter {
    let title:String
    var numberOfShows = 0
    var shows = [Show]()

    init(title: String) {
        self.title = title
        super.init()
    }

    func showAtIndexPath(index: NSIndexPath) -> Show {
        return shows[index.row]
    }

    func getShows() {
        shows = [Show.stubbedShow(),Show.stubbedShow(),Show.stubbedShow(),Show.stubbedShow()]
        numberOfShows = shows.count
    }

    func onUpdate( callback: EmitterUpdateCallback ) {
        callback(shows:shows)
    }
}
