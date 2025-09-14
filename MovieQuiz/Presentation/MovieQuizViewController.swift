import UIKit

// MARK: - MovieQuizViewController

final class MovieQuizViewController: UIViewController {
    
    // MARK: - IB Outlets
    @IBOutlet private weak var imageView: UIImageView!
    @IBOutlet private weak var counterLabel: UILabel!
    @IBOutlet private weak var questionLabel: UILabel!
    
    // MARK: - Private Properties
    private let questions: [QuizQuestion] = QuizQuestion.mockQuestions
    
    private var currentQuestionIndex = 0
    private var correctAnswersCount = 0
    private var isAnswerBeingProcessed = false
    
    // MARK: - View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        showCurrentQuestion()
    }
    
    private func showCurrentQuestion() {
        let currentQuestion = questions[currentQuestionIndex]
        let viewModel = convert(model: currentQuestion)
        show(quiz: viewModel)
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
        
        let currentQuestion = questions[currentQuestionIndex]
        showAnswerResult(isCorrect: givenAnswer == currentQuestion.correctAnswer)
    }
    
    // MARK: - Private Methods
    private func convert(model: QuizQuestion) -> QuizStep {
        return QuizStep(
            image: UIImage(named: model.image) ?? UIImage(),
            question: model.text,
            questionNumber: "\(currentQuestionIndex + 1)/\(questions.count)"
        )
    }
    
    private func show(quiz step: QuizStep) {
        imageView.image = step.image
        questionLabel.text = step.question
        counterLabel.text = step.questionNumber
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
        
        if currentQuestionIndex == questions.count - 1 {
            let text = "Ваш результат: \(correctAnswersCount)/\(questions.count)"
            let viewModel = QuizResults(
                title: "Этот раунд окончен!",
                text: text,
                buttonText: "Сыграть ещё раз"
            )
            showResult(quiz: viewModel)
        } else {
            self.imageView.layer.borderWidth = 0
            self.imageView.layer.borderColor = nil
            currentQuestionIndex += 1
            let nextQuestion = questions[currentQuestionIndex]
            let viewModel = convert(model: nextQuestion)
            show(quiz: viewModel)
        }
    }
    
    private func showResult(quiz result: QuizResults) {
        let alert = UIAlertController(title: result.title, message: result.text, preferredStyle: .alert)
        
        let action = UIAlertAction(title: result.buttonText, style: .default) { [weak self] _ in
            self?.restartGame()
        }
        
        alert.addAction(action)
        present(alert, animated: true, completion: nil)
    }
    
    // MARK: - Game Restart
    private func restartGame() {
        currentQuestionIndex = 0
        correctAnswersCount = 0
        imageView.layer.borderWidth = 0
        imageView.layer.borderColor = nil
        isAnswerBeingProcessed = false
        
        let firstQuestion = questions[currentQuestionIndex]
        let viewModel = convert(model: firstQuestion)
        show(quiz: viewModel)
    }
}
