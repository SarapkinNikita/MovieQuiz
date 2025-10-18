import UIKit

// MARK: - MovieQuizViewController

final class MovieQuizViewController: UIViewController, QuestionFactoryDelegate {
    
    // MARK: - IB Outlets
    @IBOutlet private weak var imageView: UIImageView!
    @IBOutlet private weak var counterLabel: UILabel!
    @IBOutlet private weak var questionLabel: UILabel!
    @IBOutlet private weak var activityIndicator: UIActivityIndicatorView!
    
    // MARK: - Private Properties
    
    private var currentQuestionIndex = 0
    private var correctAnswersCount = 0
    private var isAnswerBeingProcessed = false
    private let questionsAmount: Int = 10
    private var questionFactory: QuestionFactoryProtocol?
    private var currentQuestion: QuizQuestion?
    private var alertPresenter = AlertPresenter()
    private var statisticService: StatisticServiceProtocol = StatisticService()
    
    // MARK: - View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
       
       imageView.layer.cornerRadius = 20
        questionFactory = QuestionFactory(moviesLoader: MoviesLoader(), delegate: self)
        statisticService = StatisticService()

        showLoadingIndicator()
        questionFactory?.loadData()
    } 
    
    // MARK: - QuestionFactoryDelegate
    func didReceiveNextQuestion(question: QuizQuestion?) {
        guard let question = question else {
            return
        }
        
        currentQuestion = question
        let viewModel = convert(model: question)
        DispatchQueue.main.async { [weak self] in
            self?.show(quiz: viewModel)
        }
    }
    // MARK: - IB Actions
    @IBAction private func yesButtonClicked(_ sender: Any) {
        handleAnswer(givenAnswer: true)
    }
    
    @IBAction private func noButtonClicked(_ sender: Any) {
        handleAnswer(givenAnswer: false)
    }
    
    private func handleAnswer(givenAnswer: Bool) {
        guard !isAnswerBeingProcessed else { return }
        isAnswerBeingProcessed = true
        
        guard let currentQuestion = currentQuestion else { return }
        showAnswerResult(isCorrect: givenAnswer == currentQuestion.correctAnswer)
    }
    
    // MARK: - Private Methods
    private func convert(model: QuizQuestion) -> QuizStep {
        return QuizStep(
            image: UIImage(data: model.image) ?? UIImage(),
            question: model.text,
            questionNumber: "\(currentQuestionIndex + 1)/\(questionsAmount)")
    }
    
    private func show(quiz step: QuizStep) {
        imageView.image = step.image
        questionLabel.text = step.question
        counterLabel.text = step.questionNumber
    }
    
    private func showLoadingIndicator() {
        activityIndicator.isHidden = false
        activityIndicator.startAnimating()
    }

    private func hideLoadingIndicator() {
        activityIndicator.isHidden = true
        activityIndicator.stopAnimating()
    }
    
    private func showNetworkError(message: String) {
        hideLoadingIndicator()
        
        let model = AlertModel(title: "Ошибка",
                               message: message,
                               buttonText: "Попробовать еще раз") { [weak self] in
            guard let self = self else { return }
            
            self.currentQuestionIndex = 0
            self.correctAnswersCount = 0
            
            self.questionFactory?.requestNextQuestion()
        }
        
        alertPresenter.show(in: self, model: model)
    }
    
    func didLoadDataFromServer() {
        activityIndicator.isHidden = true
            questionFactory?.requestNextQuestion()
    }

    func didFailToLoadData(with error: Error) {
        showNetworkError(message: error.localizedDescription)
    }
    
    private func showAnswerResult(isCorrect: Bool) {
        if isCorrect {
            correctAnswersCount += 1
        }
        
        imageView.layer.masksToBounds = true
        imageView.layer.borderWidth = 8
        imageView.layer.cornerRadius = 20
        imageView.layer.borderColor = isCorrect ? UIColor.ypGreenIOS.cgColor : UIColor.ypRedIOS.cgColor
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in self?.showNextQuestionOrResults()
        }
    }
    
    private func showNextQuestionOrResults() {
        isAnswerBeingProcessed = false
        
        if currentQuestionIndex == questionsAmount - 1 {
            statisticService.store(correct: correctAnswersCount, total: questionsAmount)
            
            let resultText = """
            Ваш результат: \(correctAnswersCount)/\(questionsAmount)
            Количество сыгранных квизов: \(statisticService.gamesCount)
            Рекорд: \(statisticService.bestGame.correct)/\(statisticService.bestGame.total) (\(statisticService.bestGame.date.dateTimeString))
            Средняя точность: \(String(format: "%.2f", statisticService.totalAccuracy))%
            """
            
            let viewModel = QuizResults(
                title: "Этот раунд окончен!",
                text: resultText,
                buttonText: "Сыграть ещё раз"
            )
            
            showResult(quiz: viewModel, massage: resultText)
        } else {
            self.imageView.layer.borderWidth = 0
            self.imageView.layer.borderColor = nil
            currentQuestionIndex += 1
            
            self.questionFactory?.requestNextQuestion()
        }
    }
    
    private func showResult(quiz result: QuizResults, massage resultText: String) {
        let model = AlertModel(title: result.title, message: resultText, buttonText: result.buttonText) { [weak self] in
            self?.restartGame()
        }
        
        alertPresenter.show(in: self, model: model)
    }
    
    // MARK: - Game Restart
    private func restartGame() {
        currentQuestionIndex = 0
        correctAnswersCount = 0
        imageView.layer.borderWidth = 0
        imageView.layer.borderColor = nil
        isAnswerBeingProcessed = false
        
        self.questionFactory?.requestNextQuestion()
    }
}
