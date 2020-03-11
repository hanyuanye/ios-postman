//
//  RequestsTableViewController.swift
//  ios-postman
//
//  Created by Hanyuan Ye on 2020-03-08.
//  Copyright © 2020 hanyuanye. All rights reserved.
//

import UIKit
import RxSwift
import RxDataSources

fileprivate let reuseIdentifier = "RequestsTableViewCell"

struct RequestRxDataSourceModel: AnimatableSectionModelType, Equatable {

    typealias Identity = String

    typealias Item = Request
    
    let identity: String
    
    var items: [Item]
    
    init(items: [Item], id: String) {
        self.items = items
        self.identity = id
    }
    
    init(original: RequestRxDataSourceModel, items: [Item]) {
        self = original
        self.items = items
    }
    
    static func == (lhs: RequestRxDataSourceModel, rhs: RequestRxDataSourceModel) -> Bool {
        lhs.identity == rhs.identity
    }
    
}

class RequestTableViewCell: UITableViewCell {
    
    private lazy var label: UILabel = {
        let label = UILabel()
        
        label.font = .systemFont(ofSize: 20)
        label.textColor = .white
        
        return label
    }()
    
    private func setup() {
        backgroundColor = .black
        
        addSubview(label)
        
        label.snp.makeConstraints { (make) in
            make.centerY.equalToSuperview()
            make.leading.equalToSuperview().offset(10)
            make.trailing.equalToSuperview().offset(10)
        }
    }
    
    func configure(text: String) {
        setup()
        label.text = text
    }
    
}


class RequestsTableViewController: UIViewController {
    
    let disposeBag = DisposeBag()
 
    let addPublisher = PublishSubject<Void>()
    let collectionBehavior: BehaviorSubject<Collection>
    let initialState: RequestRxDataSourceModel
    
    init(collection: Collection) {
        self.collectionBehavior = BehaviorSubject<Collection>(value: collection)
        self.initialState = RequestRxDataSourceModel(items: collection.requests, id: collection.identity)
        
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private lazy var tableView: UITableView = {
        let tableView = UITableView()
        
        tableView.register(RequestTableViewCell.self, forCellReuseIdentifier: reuseIdentifier)
        
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
        
        navigationItem.title = "Request"

        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Add", style: .plain, target: self, action: #selector(addRequest))
        
        let dataSource = RxTableViewSectionedAnimatedDataSource<RequestRxDataSourceModel>(
            animationConfiguration: AnimationConfiguration(insertAnimation: .top,
                                                           reloadAnimation: .fade,
                                                           deleteAnimation: .left),
            configureCell: { dataSource, tableView, indexPath, request in
                guard let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier) as? RequestTableViewCell else {
                    return UITableViewCell()
                }
                
                cell.configure(text: request.identity)
                
                return cell
            },
            canEditRowAtIndexPath: { _, _ in true },
            canMoveRowAtIndexPath: { _, _ in true }
        )
        
        let (newCollection,
            saveState,
            updateTable,
            shouldPresentRequest) =
        RequestsTableViewModel(
            initial: initialState,
            collection: collectionBehavior,
            add: addPublisher,
            delete: tableView.rx.delete,
            move: tableView.rx.move,
            itemSelected: tableView.rx.itemSelected.asObservable())
        
        disposeBag.insert([
            newCollection.bind(to: collectionBehavior),
            saveState.bindOnMain(onNext: { [weak self] (collection) in
                Current.saveCollectionPublisher.onNext(collection)
                self?.collectionBehavior.onNext(collection)
            }),
            updateTable.bind(to: tableView.rx.items(dataSource: dataSource)),
            shouldPresentRequest.bindOnMain(onNext: { [weak self] (vc) in
                let nc = UINavigationController.standard(vc)
                self?.navigationController?.present(nc, animated: true, completion: nil)
            })
        ])
    }
    
    @objc
    func addRequest() {
        addPublisher.onNext(())
    }
}
