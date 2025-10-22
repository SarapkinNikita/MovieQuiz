import UIKit

// MARK: - MovieQuizViewController

final class MovieQuizViewController: UIViewController {
    
    // MARK: - IB Outlets
    @IBOutlet private weak var imageView: UIImageView!
    @IBOutlet private weak var counterLabel: UILabel!
    @IBOutlet private weak var questionLabel: UILabel!
    @IBOutlet private weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet private weak var yesButton: UIButton!
    @IBOutlet private weak var noButton: UIButton!
    
    // MARK: - Private Properties
    
    private var alertPresenter = AlertPresenter()
    private var presenter: MovieQuizPresenter!
    
    // MARK: - View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        presenter = MovieQuizPresenter(viewController: self)
        imageView.layer.cornerRadius = 20
        //       statisticService = StatisticService()
        
        showLoadingIndicator()
    }
    
    // MARK: - IB Actions
    @IBAction private func yesButtonClicked(_ sender: UIButton) {
        presenter.yesButtonClicked()
    }
    
    @IBAction private func noButtonClicked(_ sender: UIButton) {
        presenter.noButtonClicked()
    }
    
    // MARK: - Private Methods
    func setButtonsEnabled(_ isEnabled: Bool) {
        yesButton.isEnabled = isEnabled
        noButton.isEnabled = isEnabled
    }
    
    func show(quiz step: QuizStep) {
        imageView.layer.borderWidth = 0
        imageView.layer.borderColor = UIColor.clear.cgColor
        
        imageView.image = step.image
        questionLabel.text = step.question
        counterLabel.text = step.questionNumber
        
        setButtonsEnabled(true)
    }
    
    func showLoadingIndicator() {
        activityIndicator.isHidden = false
        activityIndicator.startAnimating()
    }
    
    func hideLoadingIndicator() {
        activityIndicator.isHidden = true
    }
    
    
    func showNetworkError(message: String) {
        hideLoadingIndicator()
        
        let model = AlertModel(title: "Ошибка",
                               message: message,
                               buttonText: "Попробовать еще раз") { [weak self] in
            guard let self else { return }
            
            self.presenter.restartGame()
        }
        
        alertPresenter.show(in: self, model: model)
    }
    
    func highlightImageBorder(isCorrectAnswer: Bool) {
        imageView.layer.masksToBounds = true
        imageView.layer.borderWidth = 8
        imageView.layer.borderColor = isCorrectAnswer ? UIColor.ypGreenIOS.cgColor : UIColor.ypRedIOS.cgColor
    }
    
    func showResults(quiz result: QuizResults) {
        let message = presenter.makeResultsMessage()
        
        let alert = UIAlertController(
            title: result.title,
            message: message,
            preferredStyle: .alert)
        
        let action = UIAlertAction(title: result.buttonText, style: .default) { [weak self] _ in
            guard let self = self else { return }
            
            self.presenter.restartGame()
        }
        
        alert.addAction(action)
        
        self.present(alert, animated: true, completion: nil)
    }
    
    // MARK: - Game Restart
    private func restartGame() {
        self.presenter.restartGame()
        imageView.layer.borderWidth = 0
        imageView.layer.borderColor = nil
    }
}
