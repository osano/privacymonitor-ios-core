//
//  DatabaseManager.swift
//  PrivacyMonitor
//
//  Created by Christian Roman on 1/10/19.
//  Copyright © 2019 Osano. All rights reserved.
//

import CleanroomLogger
import Foundation
import SQLite

public class DatabaseManager {

    fileprivate var db: Connection?
    fileprivate let table = Table("domains")

    fileprivate let rootDomainColumn = Expression<String>("rootDomain")
    fileprivate let nameColumn = Expression<String?>("name")
    fileprivate let scoreColumn = Expression<Int>("score")
    fileprivate let previousScoreColumn = Expression<Int>("previousScore")
    fileprivate let lastVisitedColumn = Expression<Date>("lastVisited")

    public static var defaultDatabaseLocation: Connection.Location {
        #if os(OSX)
        let path = NSSearchPathForDirectoriesInDomains(
            .applicationSupportDirectory, .userDomainMask, true
            ).first! + "/" + Bundle.main.bundleIdentifier!

        do {
            try FileManager.default.createDirectory(atPath: path, withIntermediateDirectories: true, attributes: nil)
        }
        catch {}

        #else
        let path = NSSearchPathForDirectoriesInDomains(
            .documentDirectory, .userDomainMask, true
            ).first!
        #endif
        return .uri("\(path)/db.sqlite3")
    }

    public init(location: Connection.Location = defaultDatabaseLocation) {
        do {
            db = try Connection(location)
            try createTableIfNeeded()
        }
        catch {
            Log.error?.message(error.localizedDescription)
        }
    }

    private func createTableIfNeeded() throws {
        try db?.run(table.create(ifNotExists: true) { t in
            t.column(rootDomainColumn, primaryKey: true)
            t.column(nameColumn)
            t.column(scoreColumn)
            t.column(previousScoreColumn)
            t.column(lastVisitedColumn, defaultValue: Date())
        })
    }

    func storeURL(withRootDomain rootDomain: String, date: Date = .init()) -> Bool {
        do {
            let setters = [rootDomainColumn <- rootDomain,
                           lastVisitedColumn <- date]

            guard let rowId = try db?.run(table.insert(setters)) else { return false }

            return (rowId as NSNumber).boolValue
        }
        catch {
            Log.error?.message(error.localizedDescription)
            return false
        }

    }

    func storeDomain(_ domain: Domain) -> Bool {
        guard let rootDomain = domain.rootDomain else { return false }

        do {
            var setters = [rootDomainColumn <- rootDomain,
                           nameColumn <- domain.name,
                           scoreColumn <- domain.score,
                           previousScoreColumn <- domain.previousScore]
            if let lastVisited = domain.lastVisited {
                setters.append(lastVisitedColumn <- lastVisited)
            }

            guard let rowId = try db?.run(table.insert(setters)) else { return false }

            return (rowId as NSNumber).boolValue
        }
        catch {
            Log.error?.message(error.localizedDescription)
            return false
        }
    }

    func retrieve(with rootDomain: String) -> Domain? {
        let query = table.filter(rootDomainColumn == rootDomain)
        do {
            if let domain = try db?.pluck(query) {
                let tld = domain[rootDomainColumn]
                let name = domain[nameColumn]
                let score = domain[scoreColumn]
                let previousScore = domain[previousScoreColumn]
                let lastVisited = domain[lastVisitedColumn]

                var domain = Domain(rootDomain: tld)
                domain.name = name
                domain.score = score
                domain.previousScore = previousScore
                domain.lastVisited = lastVisited

                return domain
            }
        }
        catch {
            print(error)
        }

        return nil
    }

    func update(rootDomain: String, score: Int? = nil, previousScore: Int? = nil, lastVisitedDate: Date = .init()) -> Bool {
        let domain = table.filter(rootDomainColumn == rootDomain)
        do {
            var setters = [lastVisitedColumn <- lastVisitedDate]

            if let score = score {
                setters.append(scoreColumn <- score)
            }

            if let previousScore = previousScore {
                setters.append(previousScoreColumn <- previousScore)
            }

            if let count = try db?.run(domain.update(setters)), count > 0 {
                return true
            }
            else {
                return false
            }
        }
        catch {
            Log.error?.message(error.localizedDescription)
            return false
        }
    }

    func delete(rootDomain: String) -> Bool {
        let domain = table.filter(rootDomainColumn == rootDomain)
        do {
            if let count = try db?.run(domain.delete()), count > 0 {
                return true
            }
            else {
                return false
            }
        }
        catch {
            print(error)
            return false
        }
    }

    func deleteAll() -> Int {
        do {
            return try db?.run(table.delete()) ?? 0
        }
        catch {
            Log.error?.message(error.localizedDescription)
            return 0
        }
    }
}
