//
//  LogFormatter.swift
//  BillionWallet
//
//  Created by Evolution Group Ltd on 11.09.17.
//  Copyright © 2017 Evolution Group Ltd. All rights reserved.
//

import Foundation
import os.log

class Logger {
    
    enum LogLevel: String {
        case debug = "DEBUG"
        case info = "INFO"
        case warning = "WARNING"
        case error = "ERROR"
        case fatal = "FATAL"
    }
    
    static let defaultLevel: LogLevel = .warning
    static var dateFormat = "yyyy-MM-dd HH:mm:ss"
    static var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = dateFormat
        formatter.locale = Locale.current
        formatter.timeZone = TimeZone.current
        return formatter
    }
    
    private class func sourceFileName(filePath: String) -> String {
        let components = filePath.components(separatedBy: "/")
        return components.isEmpty ? "" : components.last!
    }
    
    class func configureFileLogging() {
        // If using release builds, log everything in a file instead of stderr
        #if ENABLE_FILE_LOGGING
        let url = getLogFile()
        let pathStr = url.relativePath.cString(using: .ascii)!
        freopen(pathStr, "a+", stderr)
        #endif
    }
    
    class func flushFileBuffer() {
        #if ENABLE_FILE_LOGGING
        fflush(stderr)
        #endif
    }
    
    class func getLogFile() -> URL {
        let urls = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        let date = Calendar.current.startOfDay(for: Date())
        let fileName = "\(formatter.string(from: date)).log"
        
        let url = urls.first!.appendingPathComponent(fileName)
        return url
    }
    
    class func log(_ message: String,
        level: LogLevel = defaultLevel,
        fileName: String = #file,
        line: Int = #line,
        funcName: String = #function) {
//        os_log("[%{public}@] [%{public}@:%ld] %{public}@ -> %{public}@", level.rawValue, sourceFileName(filePath: fileName), line, funcName, message)
//        #if !DEBUG
//        if level == .debug {
//            return
//        }
//        #endif
        NSLog("[%@] [%@:%ld] %@ -> %@", level.rawValue, sourceFileName(filePath: fileName), line, funcName, message)
    }

    class func debug(_ text: String,
                     fileName: String = #file,
                     line: Int = #line,
                     funcName: String = #function) {
        log(text, level: .debug, fileName: fileName, line: line, funcName: funcName)
    }
    
    class func info(_ text: String,
                    fileName: String = #file,
                    line: Int = #line,
                    funcName: String = #function) {
        log(text, level: .info, fileName: fileName, line: line, funcName: funcName)
    }
    
    class func warn(_ text: String,
                    fileName: String = #file,
                    line: Int = #line,
                    funcName: String = #function) {
        log(text, level: .warning, fileName: fileName, line: line, funcName: funcName)
    }
    
    class func error(_ text: String,
                     fileName: String = #file,
                     line: Int = #line,
                     funcName: String = #function) {
        log(text, level: .error, fileName: fileName, line: line, funcName: funcName)
    }
    
    class func fatal(_ text: String,
                     fileName: String = #file,
                     line: Int = #line,
                     funcName: String = #function) {
        log(text, level: .fatal, fileName: fileName, line: line, funcName: funcName)
    }
}

fileprivate extension Date {
    func toString() -> String {
        return Logger.dateFormatter.string(from: self as Date)
    }
}
