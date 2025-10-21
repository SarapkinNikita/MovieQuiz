import UIKit

// MARK: - StatisticService
final class StatisticService {
    
    // MARK: - Private Properties
    private let storage: UserDefaults = .standard
    
    // MARK: - Keys
    private enum Keys: String {
        case gamesCount          // Счётчик сыгранных игр
        case bestGameCorrect     // Количество правильных ответов в лучшей игре
        case bestGameTotal       // Общее количество вопросов в лучшей игре
        case bestGameDate        // Дата лучшей игры
        case totalCorrectAnswers // Общее количество правильных ответов за все игры
        case totalQuestionsAsked // Общее количество заданных вопросов
    }
}

// MARK: - StatisticServiceProtocol
extension StatisticService: StatisticServiceProtocol {
    
    // MARK: - Public Computed Properties
    var gamesCount: Int {
        get { storage.integer(forKey: Keys.gamesCount.rawValue) }
        set { storage.set(newValue, forKey: Keys.gamesCount.rawValue) }
    }
    
    var bestGame: GameResult {
        get {
            let correct = storage.integer(forKey: Keys.bestGameCorrect.rawValue)
            let total = storage.integer(forKey: Keys.bestGameTotal.rawValue)
            let date = storage.object(forKey: Keys.bestGameDate.rawValue) as? Date ?? Date()
            return GameResult(correct: correct, total: total, date: date)
        }
        set {
            storage.set(newValue.correct, forKey: Keys.bestGameCorrect.rawValue)
            storage.set(newValue.total, forKey: Keys.bestGameTotal.rawValue)
            storage.set(newValue.date, forKey: Keys.bestGameDate.rawValue)
        }
    }
    
    var totalAccuracy: Double {
        guard totalQuestionsAsked > 0 else { return 0 }
        return (Double(totalCorrectAnswers) / Double(totalQuestionsAsked)) * 100
    }
    
    // MARK: - Private Computed Properties
    private var totalCorrectAnswers: Int {
        get { storage.integer(forKey: Keys.totalCorrectAnswers.rawValue) }
        set { storage.set(newValue, forKey: Keys.totalCorrectAnswers.rawValue) }
    }
    
    private var totalQuestionsAsked: Int {
        get { storage.integer(forKey: Keys.totalQuestionsAsked.rawValue) }
        set { storage.set(newValue, forKey: Keys.totalQuestionsAsked.rawValue) }
    }
    
    // MARK: - Public Methods
    func store(correct count: Int, total amount: Int) {
        totalCorrectAnswers += count
        totalQuestionsAsked += amount
        gamesCount += 1
        
        let currentGame = GameResult(correct: count, total: amount, date: Date())
        
        if currentGame.isBetterThan(bestGame) {
            bestGame = currentGame
        }
    }
}
