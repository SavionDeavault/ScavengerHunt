//
//  DataManager.swift
//  ScavengerHunt
//
//  Created by Savion DeaVault on 11/4/19.
//  Copyright © 2019 Savion DeaVault. All rights reserved.
//
import SQLite

class DataManager{
    
    static let instance = DataManager()
    private let db: Connection?
    private let table = Table("Inventory")
    private let item = Expression<String>("item")
    private let id = Expression<Int64>("id")
    private let steps = Expression<Int>("steps")
    var counter = 1
    
    private init() {
        let path = NSSearchPathForDirectoriesInDomains(
            .documentDirectory, .userDomainMask, true
            ).first!

        do {
            db = try Connection("\(path)/Database.sqlite3")
        } catch {
            db = nil
            print ("Unable to open database")
        }
        createTable()
    }
    
    func createTable() {
        do {
            try db!.run(table.create { t in
                t.column(id, primaryKey: true)
                t.column(item)
                t.column(steps)
            })
        } catch {
            print("Unable to create table")
        }
    }
    
    func updateSteps(stepsInt: Int){
        do{
            for tableIndex in try db!.prepare(table){
                let currentSteps = tableIndex[steps]
                let insert = table.insert(steps <- (stepsInt + currentSteps))
                try db!.run(insert)
            }
            for tableIndex in try db!.prepare(table){
                print("Steps!!!!: \(tableIndex[steps])")
            }
        }catch{
            print("Couldnt run updateSteps!")
        }
    }
    
    func insertIntoInventory(Item: String) {
        let insert = table.insert(item <- Item)
        do {
            try db?.run(insert)
        }catch{
            print("Failed to insert into database!")
        }
    }
    
    func getInventory() -> String {
        do {
           for itemRow in try db!.prepare(self.table){
                print(try itemRow.get(item))
                let itemName = try itemRow.get(item)
                return itemName
            }
        } catch {
            print("Select failed")
            return ""
        }
        return ""
    }
    
    func getInventoryCount() -> Int {
        counter = 1
        do {
            for _ in try db!.prepare(self.table){
                counter += 1
            }
            return counter
        }catch{
            print("Unknown error occured")
        }
        return 1
    }
}
