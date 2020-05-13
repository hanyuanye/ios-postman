//
//  CollectionsTableViewController.swift
//  ios-postman
//
//  Created by Hanyuan Ye on 2020-03-06.
//  Copyright © 2020 hanyuanye. All rights reserved.
//

import UIKit
import SnapKit
import RxSwift
import RxDataSources

fileprivate let reuseIdentifier = "CollectionsTableViewCell"

struct CollectionRxDataSourceModel: AnimatableSectionModelType, Equatable {

    typealias Identity = String

    typealias Item = Collection
    
    let identity: String
    
    var items: [Item]
    
    init(items: [Item], id: String) {
        self.items = items
        self.identity = id
    }
    
    init(original: CollectionRxDataSourceModel, items: [Item]) {
        self = original
        self.items = items
    }
    
    static func == (lhs: CollectionRxDataSourceModel, rhs: CollectionRxDataSourceModel) -> Bool {
        lhs.identity == rhs.identity
    }
    
}

class CollectionTableViewCell: UITableViewCell {
    
    let disposeBag = DisposeBag()
    
    private lazy var leftImageView: UIImageView = {
        let image = #imageLiteral(resourceName: "hamburger-icon").withRenderingMode(.alwaysTemplate)
        let imageView = UIImageView(image: image)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        imageView.tintColor = .white
        
        return imageView
    }()
    
    private lazy var titleTextField: UITextField = {
        let textField = UITextField()
        
        textField.font = .systemFont(ofSize: 20)
        textField.textColor = .white
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.isUserInteractionEnabled = false
        
        return textField
    }()
    
    private lazy var countLabel: UILabel = {
        let label = UILabel()
        
        label.font = .systemFont(ofSize: 12)
        label.textColor = .lightGray
        label.translatesAutoresizingMaskIntoConstraints = false
        
        return label
    }()
    
    private lazy var labelStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [
            titleTextField,
            countLabel
        ])
        
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.alignment = .leading
        stackView.distribution = .fillProportionally
        
        return stackView
    }()
    
    private lazy var editButton: UIButton = {
        let button = UIButton()
        let image = #imageLiteral(resourceName: "edit").withRenderingMode(.alwaysTemplate)
        
        button.setImage(image, for: .normal)
        button.tintColor = .white
        button.imageView?.contentMode = .scaleAspectFit
        
        return button
    }()
    
    private func setup() {
        backgroundColor = .black
        
        addSubview(leftImageView)
        addSubview(editButton)
        addSubview(labelStackView)
        
        leftImageView.snp.makeConstraints { (make) in
            make.leading.equalToSuperview().offset(10)
            make.centerY.equalToSuperview()
            make.height.equalTo(20)
            make.width.equalTo(20)
        }
        
        editButton.snp.makeConstraints { (make) in
            make.trailing.equalToSuperview().offset(-15)
            make.height.equalTo(20)
            make.width.equalTo(editButton.snp.height)
            make.centerY.equalTo(leftImageView.snp.centerY)
        }
        
        labelStackView.snp.makeConstraints { (make) in
            make.leading.equalTo(leftImageView.snp.trailing).offset(20)
            make.trailing.lessThanOrEqualTo(editButton.snp.leading)
            make.centerY.equalToSuperview()
            make.height.equalTo(40)
        }
        
        disposeBag.insert([
            editButton.rx.controlEvent(.touchUpInside).bindOnMain { [weak self] _ in
                self?.titleTextField.isUserInteractionEnabled = true
                self?.titleTextField.becomeFirstResponder()
            },
            titleTextField
                .rx
                .controlEvent(.editingDidEnd)
                .withLatestFrom(titleTextField.rx.text)
                .bindOnMain { (text) in
                    print(text)
                }
        ])
    }
    
    func configure(collection: Collection) {
        setup()
        titleTextField.text = "COLLECTION"//collection.name
        countLabel.text = "Number of items: \(collection.requests.count)"
    }
    
}


class CollectionTableViewController: UIViewController {
    
    let disposeBag = DisposeBag()
 
    let addPublisher = PublishSubject<Collection>()
    let collectionsPublisher: BehaviorSubject<[Collection]>
    
    init(collections: BehaviorSubject<[Collection]>) {
        self.collectionsPublisher = collections
        
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private lazy var tableView: UITableView = {
        let tableView = UITableView()
        
        tableView.register(CollectionTableViewCell.self, forCellReuseIdentifier: reuseIdentifier)
        
        return tableView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .black
        tableView.backgroundColor = .black
        
        view.addSubview(tableView)
        
        tableView.snp.makeConstraints { (make) in
            make.edges.equalTo(view.safeAreaLayoutGuide.snp.edges)
        }
        
        navigationItem.title = "Collections"

        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Add", style: .plain, target: self, action: #selector(addCollection))
        
        let dataSource = RxTableViewSectionedAnimatedDataSource<CollectionRxDataSourceModel>(
            animationConfiguration: AnimationConfiguration(insertAnimation: .top,
                                                           reloadAnimation: .fade,
                                                           deleteAnimation: .left),
            configureCell: { dataSource, tableView, indexPath, collection in
                guard let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier) as? CollectionTableViewCell else {
                    return UITableViewCell()
                }
                
                cell.configure(collection: collection)
                
                return cell
            },
            canEditRowAtIndexPath: { _, _ in true },
            canMoveRowAtIndexPath: { _, _ in true }
        )
        
        let (updateTable,
            shouldPresentRequestVC) =
        CollectionTableViewModel(
            collections: collectionsPublisher,
            itemSelected: tableView.rx.itemSelected.asObservable())

        disposeBag.insert([
            updateTable.bind(to: tableView.rx.items(dataSource: dataSource)),
            shouldPresentRequestVC.bindOnMain(onNext: { [weak self] (vc) in
                self?.navigationController?.pushViewController(vc, animated: true)
            }),
            addPublisher.bind(to: Current.addCollectionPublisher),
            tableView.rx.itemDeleted.map { $0.row }.bind(to: Current.removeCollectionPublisher),
            tableView.rx.itemMoved.map { ($0.row, $1.row) }.bind(to: Current.movePublisher)
        ])
    }
    
    @objc
    func addCollection() {
        addPublisher.onNext(.empty)
    }
}
