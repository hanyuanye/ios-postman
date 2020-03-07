import UIKit
import SnapKit
import RxSwift

enum HTTPMethods: String, Codable {
    case get = "GET"
}

enum Auth: String, Codable {
    case basic
    case oauth1
    case oauth2
}

func MainViewModel(
    networkProvider: Observable<NetworkProvider>,
    fileProvider: Observable<FileProvider>,
    responseParser: Observable<ResponseParser>,
    sendRequest: Observable<Void>,
    baseURL: Observable<String>,
    queryParams: Observable<[(String, String)]>,
    headers: Observable<[(String, String)]>,
    method: Observable<HTTPMethods>
) -> (Observable<Response>){
    
    let request = Observable
        .combineLatest(baseURL, queryParams, headers, method)
        .map { Request(baseURL: $0.0, queryParams: $0.1.toDict, headers: $0.2.toDict, method: $0.3, auth: .basic) }
    
    let networkResponse = sendRequest
        .withLatestFrom(request)
        .map { $0.asURL }
        .withLatestFrom(networkProvider) { ($1, $0) }
        .flatMapLatest { $0.performRequest($1) }
    
    let success = networkResponse.filterMap { $0.left }
    
    let error = networkResponse.filterMap { $0.right }
    
    let failedStatusCode = error
        .map { String($0.statusCodeError) }
        .replaceNilWith("No Status Code")
    
    let statusCode = Observable.merge(
        success.map { _ in "200" },
        failedStatusCode
    )
    
    let successBodyText = success
        .withLatestFrom(responseParser) { ($1, $0) }
        .map { $0.response($1) ?? NSAttributedString() }
    
    let errorFailedBodyText = error
        .map { $0.dataTaskError?.localizedDescription }
        .replaceNilWith("No Response")
        .map { NSAttributedString(string: "Encountered Error: \($0)") }
    
    let bodyText = Observable.merge(
        successBodyText,
        errorFailedBodyText
    )
    
    let time = networkResponse.map { _ in "" }
    
    let response = Observable.zip(
        statusCode,
        bodyText,
        time
    ).map { Response(statusCode: $0.0, bodyText: $0.1, time: $0.2) }
    
    
    return (response)
}

class MainViewController: UIViewController {
    
    private let disposeBag = DisposeBag()
    
    private lazy var urlActionMenuButton: UIButton = {
        let button = UIButton()
        
        button.contentEdgeInsets = .init(top: 5, left: 10, bottom: 5, right: 10)
        button.setTitle(HTTPMethods.get.rawValue, for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = .appButtonColor
        
        button.translatesAutoresizingMaskIntoConstraints = false
        button.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMinXMinYCorner]
        button.layer.cornerRadius = 10
        button.clipsToBounds = true
        
        return button
    }()
    
    private lazy var baseURLTextField: UITextField = {
        let textField = AppTextField()
        
        textField.placeholder = "http://"
        textField.text = "http://"
        textField.textColor = .white
        
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.layer.maskedCorners = [.layerMaxXMaxYCorner, .layerMaxXMinYCorner]
        textField.layer.cornerRadius = 10
        textField.clipsToBounds = true
        
        textField.setContentHuggingPriority(.init(rawValue: 0), for: .horizontal)
        
        return textField
    }()
    
    private lazy var baseURLStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [
            self.urlActionMenuButton,
            self.baseURLTextField
        ])
        
        stackView.distribution = .fill
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        return UIView.insertHeader(stackView, text: "Request")
    }()
    
    private lazy var queryKeyValuesView: AppKeyValuesStackView = {
        let view = AppKeyValuesStackView(addButtonTitle: "Add Param")
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var queryContentView: UIStackView = {
        let view = UIView.insertHeader(self.queryKeyValuesView, text: "Query Params")
        view.translatesAutoresizingMaskIntoConstraints = false
        
        return view
    }()
    
    private lazy var headerKeyValuesView: AppKeyValuesStackView = {
        let view = AppKeyValuesStackView(addButtonTitle: "Add Header")
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var headerContentView: UIStackView = {
        let view = UIView.insertHeader(self.headerKeyValuesView, text: "Headers")
        view.translatesAutoresizingMaskIntoConstraints = false
        
        return view
    }()
    
    private lazy var sendButton: UIButton = {
        let button = UIButton()
        button.setTitle("Send", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = .appButtonColor
        
        button.translatesAutoresizingMaskIntoConstraints = false
        button.layer.masksToBounds = true
        button.layer.cornerRadius = 10
        
        return button
    }()
    
    private lazy var sendButtonContainer: UIView = {
        let view = UIView()
        
        view.addSubview(self.sendButton)
        
        self.sendButton.snp.makeConstraints { (make) in
            make.leading.equalToSuperview().offset(50)
            make.trailing.equalToSuperview().offset(-50)
            make.top.equalToSuperview().offset(10)
            make.bottom.equalToSuperview()
        }
        
        return view
    }()
    
    private lazy var contentStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [
            self.baseURLStackView,
            self.queryContentView,
            self.headerContentView,
            self.sendButtonContainer
        ])
        
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.distribution = .fill
        stackView.axis = .vertical
        stackView.alignment = .fill
        stackView.spacing = 20
        
        return stackView
    }()
    
    private lazy var contentScrollView: UIScrollView = {
        return UIScrollView()
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.title = "Request"
        navigationController?.navigationBar.titleTextAttributes = [
            NSAttributedString.Key.foregroundColor: UIColor.white
        ]
        
        let backButton = UIBarButtonItem(title: "Back", style: .plain, target: self, action: #selector(close))
        navigationItem.leftBarButtonItem = backButton
        
        view.addSubview(contentStackView)
        view.backgroundColor = .black
        
        contentStackView.snp.makeConstraints { (make) in
            make.leading.equalToSuperview().offset(20)
            make.trailing.equalToSuperview().offset(-20)
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(20)
        }
        
        let (response) = MainViewModel(
            networkProvider: .just(NetworkProviderCurrent),
            fileProvider: .just(FileProviderCurrent),
            responseParser: .just(ResponseParserCurrent),
            sendRequest: self.sendButton.rx.controlEvent(.touchUpInside).asObservable(),
            baseURL: self.baseURLTextField.rx.text.orEmpty.asObservable(),
            queryParams: self.queryKeyValuesView.rx.keyValues,
            headers: self.queryKeyValuesView.rx.keyValues,
            method: .just(.get)
        )

        self.disposeBag.insert(
            response.bindOnMain(onNext: { [weak self] (response) in
                self?.presentResponseViewController(response)
            })
        )
    }
    
    @objc func close() {
        navigationController?.popViewController(animated: true)
    }
    
    func presentResponseViewController(_ response: Response) {
        let vc = ResponseViewController(response: response)
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
}

