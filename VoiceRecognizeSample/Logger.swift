//
//  Logger.swift
//  SampleCodes
//
//  Created by 伊志嶺朝輝 on 2019/04/28.
//  Copyright © 2019 TomRock. All rights reserved.
//

import UIKit

/// ロガークラス
class Logger: NSObject {
	/// 現在時刻文字列
	private class var dateString: String {
		let date = Date()
		let formatter = DateFormatter()
		
		formatter.dateFormat = "HH:mm:ss.SSS"
		formatter.locale = Locale(identifier: "en_US_POSIX")
		formatter.calendar = Calendar(identifier: .gregorian)
		
		return formatter.string(from: date)
	}
	
	/// 詳細な現在時刻文字列
	private class var detaileDateString: String{
		let date = Date()
		let formatter = DateFormatter()
		
		formatter.dateFormat = "yyyy-MM-dd HH:mm:ss.SSS"
		formatter.locale = Locale(identifier: "en_US_POSIX")
		formatter.calendar = Calendar(identifier: .gregorian)
		
		return formatter.string(from: date)
	}
	
	/// コミットハッシュ
	private class var commitHash:String?{
		let kCommitHashKey:String = "CommitHash"
		guard let path = Bundle.main.path(forResource: "Info", ofType: "plist") else{
			return nil
		}
		
		let plist = NSDictionary(contentsOfFile: path)
		
		return plist?[kCommitHashKey] as? String
	}
	
	/// ログレベル
	///
	/// - INFO: インフォ
	/// - DEBUG: デバッグ
	/// - ERROR: エラー
	/// - TEMP: 一時的なログ
	private enum LogLevel:String{
		case INFO
		case DEBUG
		case TRACE
		case ERROR
		case TEMP
	}

	static var needsPrintCommitHashWhenError:Bool = true
	
	static var needInfoLog = true
	static var needDebugLog = true
	static var needErrorLog = true
	static var needTempLog = true
	
	/// インフォログ
	///
	/// - Parameters:
	///   - file: ファイル名(指定しない)
	///   - function: 関数名(指定しない)
	///   - line: 行番号(指定しない)
	///   - message: メッセージ
	class func info(file: String = #file, function: String = #function, line: Int = #line, _ message: String = ""){
		guard needInfoLog else{
			return
		}
		
		printToConsole(logLevel: .INFO, file: file, function: function, line: line, message: message)
	}
	
	/// デバッグログ
	///
	/// - Parameters:
	///   - file: ファイル名(指定しない)
	///   - function: 関数名(指定しない)
	///   - line: 行番号(指定しない)
	///   - message: メッセージ
	class func debug(file: String = #file, function: String = #function, line: Int = #line, _ message: String = ""){
		guard needDebugLog else{
			return
		}
		
		printToConsole(logLevel: .DEBUG, file: file, function: function, line: line, message: message)
	}
	
	/// トレースログ
	///
	/// - Parameters:
	///   - file: ファイル名(指定しない)
	///   - function: 関数名(指定しない)
	///   - line: 行番号(指定しない)
	///   - message: メッセージ
	class func trace(file: String = #file, function: String = #function, line: Int = #line, _ message: String = ""){
		guard needDebugLog else{
			return
		}
		
		printToConsole(logLevel: .TRACE, file: file, function: function, line: line, message: message)
	}
	
	/// エラーログ
	///
	/// - Parameters:
	///   - file: ファイル名(指定しない)
	///   - function: 関数名(指定しない)
	///   - line: 行番号(指定しない)
	///   - message: メッセージ
	class func error(file: String = #file, function: String = #function, line: Int = #line, _ message: String = ""){
		guard needErrorLog else{
			return
		}
		
		if needsPrintCommitHashWhenError, let commitHash = commitHash {
			#if DEBUG
			print("Occur Error in Commit:\(commitHash)")
			#endif
		}
		printToConsole(logLevel: .ERROR, file: file, function: function, line: line, message: message)
	}
	
	/// 一時ログ
	///
	/// - Parameters:
	///   - file: ファイル名(指定しない)
	///   - function: 関数名(指定しない)
	///   - line: 行番号(指定しない)
	///   - message: メッセージ
	class func temp(file: String = #file, function: String = #function, line: Int = #line, _ message: String = ""){
		guard needTempLog else{
			return
		}
		
		printToConsole(logLevel: .TEMP, file: file, function: function, line: line, message: message)
	}
	
	/// クラス名を抽出する関数
	///
	/// - Parameter filePath: ファイルパス
	/// - Returns: クラス名
	private class func className(from filePath: String) -> String {
		let fileName = filePath.components(separatedBy: "/").last
		return fileName?.components(separatedBy: ".").first ?? ""
	}
	
	/// ログをコンソールに出力する関数
	///
	/// - Parameters:
	///   - logLevel: ログレベル
	///   - file: ファイル名
	///   - function: 関数名
	///   - line: 行番号
	///   - message: メッセージ
	private class func printToConsole(logLevel:LogLevel, file:String, function:String, line:Int, message:String){
		#if DEBUG
		if logLevel == .ERROR {
			print("\(detaileDateString) [\(logLevel.rawValue.uppercased())] [\(commitHash ?? "CommitHash is None")] \(className(from: file)).\(function) #\(line): \(message)")
		}else{
			print("\(dateString) [\(logLevel.rawValue.uppercased())] \(className(from: file)).\(function) #\(line): \(message)")
		}
		#endif
	}
	
	/// コミット情報を出力する関数
	class func commitInfo(){
		#if DEBUG
		print("\(detaileDateString) [COMMIT] \(commitHash ?? "None")")
		#endif
	}
}
